import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_pay/app/theme/app_colors.dart';
import 'package:stream_pay/core/providers/data_providers.dart';
import 'package:stream_pay/features/projects/presentation/screens/measurement_screen.dart';
import 'package:stream_pay/features/quotes/domain/calculation_engine.dart';
import 'package:stream_pay/features/quotes/presentation/widgets/material_picker_modal.dart';
import 'package:stream_pay/core/responsive/constrained_body.dart';

class QuoteGenerationScreen extends ConsumerStatefulWidget {
  final String sessionId;
  final String projectId;
  final String customerId;

  const QuoteGenerationScreen({
    super.key,
    required this.sessionId,
    required this.projectId,
    required this.customerId,
  });

  @override
  ConsumerState<QuoteGenerationScreen> createState() => _QuoteGenerationScreenState();
}

class _QuoteGenerationScreenState extends ConsumerState<QuoteGenerationScreen> {
  // Mapping of Wall ID to Assigned Material Info
  final Map<String, Map<String, dynamic>> _wallMaterials = {};
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(sessionTreeProvider(widget.sessionId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('إصدار عرض سعر'),
      ),
      body: ConstrainedBody(
        child: sessionAsync.when(
          data: (session) {
            if (session == null) return const Center(child: Text('الجلسة غير موجودة'));
          final rooms = session['rooms'] as List? ?? [];
          
          if (rooms.isEmpty) {
             return const Center(child: Text('لا توجد غرف أو قياسات في هذه الجلسة'));
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: rooms.length,
                  itemBuilder: (ctx, i) {
                    final room = rooms[i] as Map<String, dynamic>;
                    final walls = room['walls'] as List? ?? [];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              room['name'] ?? 'غرفة',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                            const Divider(),
                            ...walls.map((w) => _buildWallItem(w as Map<String, dynamic>)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              _buildBottomBar(),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('خطأ: $e')),
        ),
      ),
    );
  }

  Widget _buildWallItem(Map<String, dynamic> wall) {
    final wallId = wall['id'] as String;
    final assigned = _wallMaterials[wallId];
    
    // Calculate net area
    final wl = (wall['length'] as num?)?.toDouble() ?? 0;
    final wh = (wall['height'] as num?)?.toDouble() ?? 0;
    final wallArea = wl * wh;
    double openingsArea = 0;
    final openings = wall['wall_openings'] as List? ?? [];
    for (final o in openings) {
      final op = o as Map<String, dynamic>;
      if (op['deduct'] == true) {
        openingsArea += ((op['width'] as num?)?.toDouble() ?? 0) *
            ((op['height'] as num?)?.toDouble() ?? 0);
      }
    }
    final netArea = wallArea - openingsArea;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wall['name'] ?? 'حائط',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text('صافي: ${netArea.toStringAsFixed(2)} م²', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: assigned == null
                ? OutlinedButton(
                    onPressed: () => _assignMaterial(wallId, wl, wh, netArea),
                    child: const Text('اختيار خامة'),
                  )
                : InkWell(
                    onTap: () => _assignMaterial(wallId, wl, wh, netArea),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          assigned['product']['name'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.accent),
                          textAlign: TextAlign.left,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'الكمية: ${assigned['calc_result'].primaryQty} ${assigned['product']['unit_type'] ?? 'م'}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: FilledButton.icon(
          onPressed: _isGenerating || _wallMaterials.isEmpty ? null : _generateQuote,
          icon: _isGenerating ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.receipt_long),
          label: const Text('توليد عرض السعر'),
          style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
        ),
      ),
    );
  }

  void _assignMaterial(String wallId, double wallLength, double wallHeight, double netArea) async {
    final result = await MaterialPickerModal.show(context);
    if (result != null) {
      final waste = result['waste_percent'] as double;
      final calcMode = result['calc_mode'] as String;
      final variant = result['variant'] as Map<String, dynamic>;

      final calcResult = CalculationEngine.calculateMaterialRequirements(
        wallLength: wallLength,
        wallHeight: wallHeight,
        netArea: netArea,
        variant: variant,
        calcMode: calcMode,
        wastePercent: waste,
      );
      
      setState(() {
        _wallMaterials[wallId] = {
          ...result,
          'calc_result': calcResult,
          'net_area': netArea,
        };
      });
    }
  }

  Future<void> _generateQuote() async {
    setState(() => _isGenerating = true);
    
    try {
      final items = <Map<String, dynamic>>[];
      _wallMaterials.forEach((wallId, data) {
        final variantId = data['variant']['id'];
        final calcResult = data['calc_result'] as CalculationResult;
        
        // Ensure standard QuoteItem structure for the main material
        items.add({
          'product_variant_id': variantId,
          'qty': calcResult.primaryQty,
          'unit': data['product']['unit_type'] ?? 'متر',
          'waste_percent': data['waste_percent'],
          'notes': 'تغطية حائط صافي مساحة ${data['net_area'].toStringAsFixed(2)} م²',
          'unit_price': calcResult.primaryUnitPrice,
          'final_unit_price': calcResult.primaryUnitPrice,
          'final_line_total': calcResult.primaryLineTotal,
        });

        // Add accessories as separate line items
        for (final acc in calcResult.accessories) {
           // We might not have a specific product_variant_id for the accessory, 
           // but we assume accessoryProduct has an ID and we use its default variant if available,
           // or we just save it. The schema expects product_variant_id.
           // For now, if we don't have it, we might leave it null or map it correctly.
           // Assuming we just store the product name in notes if ID fails.
           items.add({
             'product_variant_id': null, // Need exact variant ID for accessories ideally
             'qty': acc.qty,
             'unit': acc.accessoryProduct['unit_type'] ?? 'قطعة',
             'notes': 'ملحق: ${acc.accessoryProduct['name']}',
             'unit_price': acc.unitPrice,
             'final_unit_price': acc.unitPrice,
             'final_line_total': acc.lineTotal,
           });
        }
      });

      final repo = ref.read(quoteRepositoryProvider);
      final quote = await repo.createQuoteFromSession(
        customerId: widget.customerId,
        projectId: widget.projectId,
        items: items,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم إصدار عرض السعر ${quote['quote_number'] ?? ''} بنجاح'), backgroundColor: AppColors.success),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في إنشاء العرض: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }
}

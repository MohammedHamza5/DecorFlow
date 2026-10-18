import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_pay/app/theme/app_colors.dart';
import 'package:stream_pay/core/providers/data_providers.dart';
import 'package:stream_pay/features/catalog/providers/discount_provider.dart';
import 'package:stream_pay/features/catalog/data/catalog_hub.dart';
import 'package:uuid/uuid.dart';
import 'package:stream_pay/core/responsive/constrained_body.dart';

class DiscountManagementScreen extends ConsumerStatefulWidget {
  const DiscountManagementScreen({super.key});

  @override
  ConsumerState<DiscountManagementScreen> createState() => _DiscountManagementScreenState();
}

class _DiscountManagementScreenState extends ConsumerState<DiscountManagementScreen> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final campaignsAsync = ref.watch(discountCampaignsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الخصومات الذكية', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      body: _isProcessing
          ? const Center(child: CircularProgressIndicator())
          : ConstrainedBody(
              child: campaignsAsync.when(
                data: (campaigns) {
                if (campaigns.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.discount_rounded, size: 80, color: AppColors.borderDark),
                        const SizedBox(height: 16),
                        Text('لا توجد خصومات نشطة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: campaigns.length,
                  separatorBuilder: (ctx, i) => const SizedBox(height: 16),
                  itemBuilder: (ctx, i) => _CampaignCard(
                    campaign: campaigns[i],
                    onDelete: () => _confirmDeleteCampaign(campaigns[i]),
                  ),
                );
              },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, st) => Center(child: Text('خطأ: $err')),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isProcessing ? null : () => _showCreateCampaignSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('خصم جديد', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Future<void> _confirmDeleteCampaign(DiscountCampaign campaign) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(children: [
          Icon(Icons.warning_rounded, color: AppColors.error),
          SizedBox(width: 8),
          Text('حذف الخصم', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.error)),
        ]),
        content: Text(
          'هل أنت متأكد من حذف وإلغاء "${campaign.title}"؟\nسيتم إرجاع جميع أسعار المنتجات المتأثرة إلى وضعها الأصلي.',
          style: const TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('نعم، حذف وإلغاء'),
          ),
        ],
      ),
    ) ?? false;

    if (!confirmed || !mounted) return;

    setState(() => _isProcessing = true);
    try {
      final repo = ref.read(productRepositoryProvider);
      await repo.revertDiscount(categories: campaign.targetType == 'categories' ? campaign.categories : null);
      await ref.read(discountCampaignsProvider.notifier).removeCampaign(campaign.id);
      ref.invalidate(productsProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حذف الخصم واسترجاع الأسعار بنجاح'), backgroundColor: AppColors.success));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e'), backgroundColor: AppColors.error));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showCreateCampaignSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _CreateCampaignSheet(),
    );
  }
}

class _CampaignCard extends StatelessWidget {
  final DiscountCampaign campaign;
  final VoidCallback onDelete;

  const _CampaignCard({required this.campaign, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20, bottom: -20,
            child: Icon(Icons.percent_rounded, size: 100, color: Colors.white.withValues(alpha: 0.15)),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        campaign.title,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white),
                      onPressed: onDelete,
                      tooltip: 'إلغاء الخصم',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                      child: Text(
                        '-${campaign.discountPercent.toStringAsFixed(0)}%',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        campaign.targetType == 'all' ? 'جميع المنتجات' : 'فئات: ${campaign.categories.join('، ')}',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.9)),
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateCampaignSheet extends ConsumerStatefulWidget {
  const _CreateCampaignSheet();
  @override
  ConsumerState<_CreateCampaignSheet> createState() => _CreateCampaignSheetState();
}

class _CreateCampaignSheetState extends ConsumerState<_CreateCampaignSheet> {
  final _titleCtrl = TextEditingController();
  final _discountCtrl = TextEditingController();
  String _targetType = 'categories';
  final List<String> _selectedCategories = [];
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final allProducts = ref.watch(catalogHubProvider).allProducts;
    
    // Live Preview Logic
    double? discountVal = double.tryParse(_discountCtrl.text);
    List previewItems = [];
    if (discountVal != null && discountVal > 0 && discountVal <= 100) {
      previewItems = allProducts.where((p) {
        if (_targetType == 'all') return true;
        return _selectedCategories.contains(p.category);
      }).take(3).toList();
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: ConstrainedBody(
        child: Column(
          children: [
            const SizedBox(height: 12),
          Container(width: 50, height: 6, decoration: BoxDecoration(color: AppColors.borderDark, borderRadius: BorderRadius.circular(10))),
          const SizedBox(height: 20),
          const Text('إنشاء خصم عبقري', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _titleCtrl,
                    decoration: InputDecoration(
                      labelText: 'اسم حملة الخصم (مثال: عروض الصيف)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      filled: true,
                      fillColor: AppColors.surface,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('كل المنتجات', style: TextStyle(fontWeight: FontWeight.bold)),
                          value: 'all',
                          groupValue: _targetType,
                          onChanged: (v) => setState(() => _targetType = v!),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('تحديد فئات', style: TextStyle(fontWeight: FontWeight.bold)),
                          value: 'categories',
                          groupValue: _targetType,
                          onChanged: (v) => setState(() => _targetType = v!),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                  if (_targetType == 'categories') ...[
                    const SizedBox(height: 16),
                    categoriesAsync.when(
                      data: (cats) => Wrap(
                        spacing: 8, runSpacing: 8,
                        children: cats.map((c) {
                          final isSelected = _selectedCategories.contains(c);
                          return FilterChip(
                            label: Text(c),
                            selected: isSelected,
                            onSelected: (val) => setState(() {
                              val ? _selectedCategories.add(c) : _selectedCategories.remove(c);
                            }),
                            selectedColor: AppColors.primary.withValues(alpha: 0.2),
                            checkmarkColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: isSelected ? AppColors.primary : AppColors.textPrimary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          );
                        }).toList(),
                      ),
                      loading: () => const LinearProgressIndicator(),
                      error: (e, s) => const Text('خطأ في الفئات'),
                    ),
                  ],
                  const SizedBox(height: 24),
                  TextField(
                    controller: _discountCtrl,
                    keyboardType: TextInputType.number,
                    onChanged: (v) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: 'نسبة الخصم (%)',
                      prefixIcon: const Icon(Icons.local_offer_rounded, color: AppColors.primary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      filled: true,
                      fillColor: AppColors.surface,
                    ),
                  ),
                  
                  if (previewItems.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    const Text('معاينة حية (Test Preview)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primary)),
                    const SizedBox(height: 12),
                    ...previewItems.map((p) {
                      double listPrice = p.minNetPrice; // We assume the current price is list price if no discount is applied yet, or the user already has list price. Actually catalogHub uses net_price.
                      // For a true preview, we just show what a X% drop looks like on the current price.
                      double previewPrice = listPrice * (1 - (discountVal! / 100));
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: AppColors.surfaceVariant.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            Expanded(child: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
                            Text(listPrice.toStringAsFixed(0), style: TextStyle(decoration: TextDecoration.lineThrough, color: AppColors.textSecondary)),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.success),
                            const SizedBox(width: 8),
                            Text('${previewPrice.toStringAsFixed(0)} ج.م', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.success)),
                          ],
                        ),
                      );
                    }),
                  ],
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: _isSaving
                ? const CircularProgressIndicator()
                : FilledButton.icon(
                    onPressed: _saveCampaign,
                    icon: const Icon(Icons.bolt_rounded),
                    label: const Text('تطبيق الخصم الآن', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
          ),
        ],
      ),
      ),
    );
  }

  Future<void> _saveCampaign() async {
    final title = _titleCtrl.text.trim();
    final discountStr = _discountCtrl.text.trim();
    
    if (title.isEmpty) {
      _showError('يرجى إدخال اسم للحملة'); return;
    }
    final discount = double.tryParse(discountStr);
    if (discount == null || discount <= 0 || discount > 100) {
      _showError('يرجى إدخال نسبة خصم صحيحة'); return;
    }
    if (_targetType == 'categories' && _selectedCategories.isEmpty) {
      _showError('يرجى تحديد فئة واحدة على الأقل'); return;
    }

    setState(() => _isSaving = true);
    try {
      final repo = ref.read(productRepositoryProvider);
      await repo.bulkUpdateDiscount(
        categories: _targetType == 'categories' ? _selectedCategories : null,
        discountPercent: discount,
      );

      final campaign = DiscountCampaign(
        id: const Uuid().v4(),
        title: title,
        targetType: _targetType,
        categories: _targetType == 'categories' ? List.from(_selectedCategories) : [],
        discountPercent: discount,
        createdAt: DateTime.now(),
      );

      await ref.read(discountCampaignsProvider.notifier).addCampaign(campaign);
      ref.invalidate(productsProvider);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم تطبيق "$title" بنجاح'), backgroundColor: AppColors.success));
      }
    } catch (e) {
      if (mounted) _showError('خطأ: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.error));
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stream_pay/app/theme/app_colors.dart';
import 'package:stream_pay/core/providers/supabase_providers.dart';
import 'package:stream_pay/core/auth/rbac/app_permissions.dart';
import 'package:stream_pay/core/auth/providers/auth_state_provider.dart';
import 'package:stream_pay/features/catalog/data/catalog_hub.dart';
import 'package:stream_pay/features/catalog/data/catalog_hub_state.dart';
import 'package:stream_pay/core/providers/data_providers.dart';
import 'package:stream_pay/core/responsive/constrained_body.dart';

/// Premium Product detail screen with sleek segmented tabs and floating bottom sheets.
class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;
  final String? variantId;
  const ProductDetailScreen({super.key, required this.productId, this.variantId});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = ref.watch(enrichedProductProvider(widget.productId));
    final role = ref.watch(currentUserRoleProvider);
    final canEdit = RolePermissions.hasPermission(role, AppPermission.editProduct);

    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('تفاصيل المنتج')),
        body: const Center(child: Text('المنتج غير موجود أو لم يتم تحميله')),
      );
    }

    final groupColor = product.group?.color ?? AppColors.primary;
    final selectedVariant = widget.variantId != null 
        ? product.variants.where((v) => v.id.toString() == widget.variantId).firstOrNull 
        ?? (product.variants.isNotEmpty ? product.variants.first : null)
        : (product.variants.isNotEmpty ? product.variants.first : null);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ConstrainedBody(
        child: Stack(
          children: [
          // Full bleed hero image
          Positioned(
            top: 0, left: 0, right: 0, height: MediaQuery.of(context).size.height * 0.42,
            child: _buildHeroImage(product, groupColor, selectedVariant),
          ),
          
          // Back button and actions
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16, right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCircleBtn(Icons.arrow_back_ios_new_rounded, () => context.pop()),
                if (canEdit)
                  _buildCircleBtn(Icons.edit_rounded, () async {
                    final ok = await context.push<bool>('/product/${widget.productId}/edit');
                    if (ok == true) ref.read(catalogHubProvider.notifier).invalidate();
                  }),
              ],
            ),
          ),

          // Bottom Sheet Content
          Positioned.fill(
            top: MediaQuery.of(context).size.height * 0.39,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 25, offset: const Offset(0, -8))],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  // Drag handle
                  Container(width: 40, height: 5, decoration: BoxDecoration(color: AppColors.borderDark.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10))),
                  const SizedBox(height: 14),
                  
                  // Title and Code
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(product.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, height: 1.2, color: AppColors.textPrimary)),
                              if (selectedVariant != null && selectedVariant.variantName.isNotEmpty && selectedVariant.variantName != product.name) ...[
                                const SizedBox(height: 4),
                                Text(selectedVariant.variantName, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: groupColor)),
                              ],
                            ],
                          ),
                        ),
                        if (product.code.isNotEmpty) ...[
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: groupColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: groupColor.withValues(alpha: 0.3), width: 1.2),
                            ),
                            child: Text(product.code, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: groupColor)),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Quick Metric Strip (Key differentiator for workers)
                  _buildQuickMetricStrip(product, selectedVariant, groupColor),
                  const SizedBox(height: 16),

                  // Custom Segmented Tab Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.border)),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(color: groupColor, borderRadius: BorderRadius.circular(24)),
                        labelColor: Colors.white,
                        unselectedLabelColor: AppColors.textSecondary,
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        tabs: const [
                          Tab(text: 'التفاصيل'),
                          Tab(text: 'الأصناف'),
                          Tab(text: 'المخزون'),
                          Tab(text: 'الحساب'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tab Views
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _DetailsTab(product: product, groupColor: groupColor, selectedVariant: selectedVariant),
                        _VariantsTab(product: product, groupColor: groupColor),
                        _InventoryTab(product: product, groupColor: groupColor, canEdit: canEdit),
                        _CalculationsTab(product: product, groupColor: groupColor),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Sticky Bottom Action Bar (if calculable)
          if (product.calcConfig != null)
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter, end: Alignment.topCenter,
                    colors: [AppColors.background, AppColors.background.withValues(alpha: 0.9), AppColors.background.withValues(alpha: 0.0)],
                  ),
                ),
                child: FilledButton.icon(
                  onPressed: () => context.go('/calculator', extra: {
                    'product': product.toRawMap(),
                    if (selectedVariant != null)
                      'variant': {
                        'id': selectedVariant.id,
                        'product_id': selectedVariant.productId,
                        'variant_name': selectedVariant.variantName,
                        'color': selectedVariant.color,
                        'dimensions': selectedVariant.dimensions,
                        'piece_length': selectedVariant.pieceLength,
                        'piece_width': selectedVariant.pieceWidth,
                        'thickness': selectedVariant.thickness,
                        'net_price': selectedVariant.netPrice,
                        'list_price': selectedVariant.listPrice,
                      },
                  }),
                  icon: const Icon(Icons.calculate_rounded),
                  label: const Text('إضافة إلى الحاسبة السريعة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  style: FilledButton.styleFrom(
                    backgroundColor: groupColor, foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 8, shadowColor: groupColor.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickMetricStrip(EnrichedProduct product, EnrichedVariant? selectedVariant, Color groupColor) {
    final chips = <Widget>[];

    // 1. Category Chip
    if (product.category.isNotEmpty) {
      chips.add(_buildMetricChip(Icons.category_outlined, product.category, AppColors.primary));
    }

    // 2. Brand Chip
    if (product.brand != null && product.brand!.isNotEmpty) {
      chips.add(_buildMetricChip(Icons.verified_outlined, product.brand!, AppColors.accent));
    }

    // 3. Unit Type Chip
    final unitLabel = switch (product.unitType) {
      'linear_meter' => 'متر طولي',
      'panel' => 'لوح',
      'rod' => 'عود',
      'piece' => 'قطعة',
      'square_meter' => 'متر مربع',
      _ => product.unitType,
    };
    if (unitLabel.isNotEmpty) {
      chips.add(_buildMetricChip(Icons.straighten_rounded, unitLabel, Colors.teal));
    }

    // 4. Dimensions Chip (from variant or product)
    final dim = selectedVariant?.dimensions;
    if (dim != null && dim.isNotEmpty) {
      chips.add(_buildMetricChip(Icons.aspect_ratio_rounded, dim, Colors.deepOrange));
    } else if (selectedVariant != null && selectedVariant.pieceLength > 0 && selectedVariant.pieceWidth > 0) {
      final len = (selectedVariant.pieceLength * 100).toStringAsFixed(0);
      final w = (selectedVariant.pieceWidth * 100).toStringAsFixed(0);
      chips.add(_buildMetricChip(Icons.aspect_ratio_rounded, '$len×$w سم', Colors.deepOrange));
    } else if (selectedVariant != null && selectedVariant.pieceLength > 0) {
      final len = selectedVariant.pieceLength.toStringAsFixed(2);
      chips.add(_buildMetricChip(Icons.height_rounded, 'طول $len م', Colors.deepOrange));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: chips.map((c) => Padding(padding: const EdgeInsets.only(left: 8), child: c)).toList(),
      ),
    );
  }

  Widget _buildMetricChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage(EnrichedProduct product, Color groupColor, EnrichedVariant? selectedVariant) {
    final imageUrl = selectedVariant?.imageUrl ?? product.imageUrl;
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF141416), // Dark Luxury Studio Box for maximum contrast on white PU/Futec
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl != null && imageUrl.isNotEmpty) ...[
            // Centered crisp uncropped image
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 40, 16, 32),
              child: Center(
                child: Hero(
                  tag: 'product_img_${product.id}',
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (ctx, err, stack) => const Icon(Icons.image_not_supported_rounded, size: 64, color: Colors.white24),
                    loadingBuilder: (ctx, child, progress) {
                      if (progress == null) return child;
                      return const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54));
                    },
                  ),
                ),
              ),
            ),
            // Tap for fullscreen zoom pill
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 64,
              child: GestureDetector(
                onTap: () => _openZoomDialog(imageUrl),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24, width: 1),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.zoom_in_rounded, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text('فحص وتكبير', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
          ] else
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(product.group?.icon ?? Icons.category_rounded, size: 64, color: Colors.white24),
                  const SizedBox(height: 8),
                  const Text('لا توجد صورة مسجلة', style: TextStyle(color: Colors.white38, fontSize: 13)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _openZoomDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black.withValues(alpha: 0.95),
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 6.0,
                child: Center(
                  child: Image.network(imageUrl, fit: BoxFit.contain),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: Material(
                color: Colors.black54,
                shape: const CircleBorder(),
                child: IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white, size: 26),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.4), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

// ─── Utils ───────────────────────────────────────────────────────

String _formatDim(double d) {
  if (d <= 0) return '';
  double cm = d * 100;
  return '${cm == cm.roundToDouble() ? cm.toInt() : cm.toStringAsFixed(1)} سم';
}

// ─── Tabs ────────────────────────────────────────────────────────

class _DetailsTab extends StatelessWidget {
  final EnrichedProduct product;
  final Color groupColor;
  final EnrichedVariant? selectedVariant;
  const _DetailsTab({required this.product, required this.groupColor, this.selectedVariant});

  @override
  Widget build(BuildContext context) {
    // Gather base dimensions from selected variant (or first variant)
    final firstVariant = selectedVariant;
    final hasLength = firstVariant != null && firstVariant.pieceLength > 0;
    final hasWidth = firstVariant != null && firstVariant.pieceWidth > 0;
    final hasThickness = firstVariant != null && firstVariant.thickness > 0;
    final hasDimensions = hasLength || hasWidth || hasThickness;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
      physics: const BouncingScrollPhysics(),
      children: [
        // ─── Basic Info Card ───────────────────────────────
        _buildInfoCard([
          _InfoRow(label: 'التصنيف الأساسي', value: product.category, icon: Icons.category_rounded),
          if (product.subcategory != null && product.subcategory!.isNotEmpty) ...[
            const Divider(height: 24),
            _InfoRow(label: 'التصنيف الفرعي', value: product.subcategory!, icon: Icons.subdirectory_arrow_right_rounded),
          ],
          if (product.brand != null && product.brand!.isNotEmpty) ...[
            const Divider(height: 24),
            _InfoRow(label: 'العلامة التجارية', value: product.brand!, icon: Icons.branding_watermark_rounded),
          ],
          const Divider(height: 24),
          _InfoRow(label: 'وحدة القياس', value: _unitLabel(product.unitType), icon: Icons.straighten_rounded),
          if (product.material != null && product.material!.isNotEmpty) ...[
            const Divider(height: 24),
            _InfoRow(label: 'الخامة', value: product.material!, icon: Icons.layers_rounded),
          ],
          if (product.installationMethod != null && product.installationMethod!.isNotEmpty) ...[
            const Divider(height: 24),
            _InfoRow(label: 'طريقة التركيب', value: product.installationMethod!, icon: Icons.construction_rounded),
          ],
        ]),
        
        // ─── Dimensions Card ─────────────────────────────────
        if (hasDimensions) ...[
          const SizedBox(height: 20),
          Text('الأبعاد الأساسية', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                if (hasLength) ...[
                  Expanded(child: _DimBlock(
                    icon: Icons.height_rounded,
                    label: 'الطول',
                    value: _formatDim(firstVariant.pieceLength),
                    color: groupColor,
                  )),
                ],
                if (hasLength && (hasWidth || hasThickness))
                  Container(width: 1, height: 50, color: AppColors.border),
                if (hasWidth) ...[
                  Expanded(child: _DimBlock(
                    icon: Icons.width_normal_rounded,
                    label: 'العرض',
                    value: _formatDim(firstVariant.pieceWidth),
                    color: groupColor,
                  )),
                ],
                if (hasWidth && hasThickness)
                  Container(width: 1, height: 50, color: AppColors.border),
                if (hasThickness) ...[
                  Expanded(child: _DimBlock(
                    icon: Icons.layers_rounded,
                    label: 'السُمك',
                    value: '${firstVariant.thickness} مم',
                    color: groupColor,
                  )),
                ],
              ],
            ),
          ),
          if (product.variants.length > 1) ...[
            const SizedBox(height: 8),
            Text(
              '* قد تختلف الأبعاد بين الأصناف، راجع تبويب "الأصناف" للتفاصيل',
              style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
            ),
          ],
        ],

        // ─── Notes ─────────────────────────────────────────
        if (product.notes != null && product.notes!.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Text('ملاحظات إضافية', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
            child: Text(product.notes!, style: TextStyle(color: AppColors.textSecondary, height: 1.6, fontSize: 14)),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
      child: Column(children: children),
    );
  }

  String _unitLabel(String type) {
    const map = {'rod': 'عود', 'panel': 'لوح', 'linear_meter': 'متر طولي', 'square_meter': 'متر مربع', 'roll': 'رول', 'box': 'كرتونة', 'piece': 'قطعة', 'tube': 'أنبوبة', 'container': 'عبوة'};
    return map[type] ?? type;
  }
}

/// Beautiful dimension display block
class _DimBlock extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _DimBlock({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 22, color: color),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: color)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _InfoRow({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.background, shape: BoxShape.circle), child: Icon(icon, size: 20, color: AppColors.textSecondary)),
      const SizedBox(width: 16),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 12, color: AppColors.textTertiary, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
      ]),
    ]);
  }
}

class _VariantsTab extends ConsumerWidget {
  final EnrichedProduct product;
  final Color groupColor;
  const _VariantsTab({required this.product, required this.groupColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (product.variants.isEmpty) return Center(child: Text('لا توجد أصناف', style: TextStyle(color: AppColors.textSecondary)));
    final suppliersAsync = ref.watch(suppliersProvider);
    final suppliers = suppliersAsync.value ?? [];
    final role = ref.watch(currentUserRoleProvider);
    final isSeller = role == AppRole.seller;

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
      physics: const BouncingScrollPhysics(),
      itemCount: product.variants.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (ctx, i) {
        final v = product.variants[i];
        return Container(
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))]),
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              _ColorRing(colorString: v.color, ringColor: groupColor),
              const SizedBox(width: 16),
              Expanded(child: Text(v.variantName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
              if (v.hasPrice && !isSeller)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: groupColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${(v.sellingPrice > 0 ? v.sellingPrice : v.netPrice).toStringAsFixed(0)} ج.م قطاعي',
                        style: TextStyle(fontWeight: FontWeight.w900, color: groupColor, fontSize: 13),
                      ),
                    ),
                    if (v.technicianPrice > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${v.technicianPrice.toStringAsFixed(0)} ج فنيين',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                      ),
                    ],
                  ],
                )
              else if (v.hasPrice && isSeller)
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: const Text('نشط', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 12)))
              else
                const Text('بدون سعر', style: TextStyle(color: AppColors.error, fontSize: 12)),
            ]),
            const SizedBox(height: 16),
            Wrap(spacing: 8, runSpacing: 8, children: [
              if (v.priceSourceLabel.isNotEmpty)
                _DimPill(Icons.auto_awesome, v.priceSourceLabel),
              if (!isSeller && v.costPrice > 0)
                _DimPill(Icons.receipt_outlined, 'تكلفة: ${v.costPrice.toStringAsFixed(0)} ج.م'),
              if (v.dimensions != null && v.dimensions!.isNotEmpty) _DimPill(Icons.aspect_ratio_rounded, v.dimensions!),
              if (v.pieceLength > 0) _DimPill(Icons.height_rounded, 'طول: ${_formatDim(v.pieceLength)}'),
              if (v.pieceWidth > 0) _DimPill(Icons.width_normal_rounded, 'عرض: ${_formatDim(v.pieceWidth)}'),
              if (v.thickness > 0) _DimPill(Icons.layers_rounded, 'سُمك: ${v.thickness}مم'),
              if (v.effectiveCoverageWidth > 0) _DimPill(Icons.width_normal_rounded, 'تغطية: ${_formatDim(v.effectiveCoverageWidth)}'),
              _DimPill(Icons.delete_outline_rounded, 'هالك: ${(v.defaultWastePercent * 100).toStringAsFixed(0)}%'),
              if (v.minSellingPrice > 0)
                _DimPill(Icons.money_off_rounded, 'الحد الأدنى: ${v.minSellingPrice.toStringAsFixed(0)} ج.م'),
              if (!isSeller && v.supplierId != null) ...[
                () {
                  final supplier = suppliers.firstWhere(
                    (s) => s['id']?.toString() == v.supplierId,
                    orElse: () => <String, dynamic>{},
                  );
                  final name = supplier['name'] as String?;
                  if (name != null) {
                    return _DimPill(Icons.local_shipping_rounded, 'المورد: $name');
                  }
                  return const SizedBox.shrink();
                }(),
              ],
              if (!isSeller && v.supplierCode != null && v.supplierCode!.isNotEmpty)
                _DimPill(Icons.tag_rounded, 'كود المورد: ${v.supplierCode}'),
            ]),
          ]),
        );
      },
    );
  }
}

// ─── Smart Inventory Tab ──────────────────────────────────────────

class _InventoryTab extends ConsumerWidget {
  final EnrichedProduct product;
  final Color groupColor;
  final bool canEdit;
  const _InventoryTab({required this.product, required this.groupColor, required this.canEdit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (product.variants.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.textTertiary.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text('لا توجد أصناف في هذا المنتج', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    // Compute totals
    final totalQty = product.variants.fold(0.0, (s, v) => s + v.availableQty);
    final totalReserved = product.variants.fold(0.0, (s, v) => s + v.reservedQty);
    final inStockCount = product.variants.where((v) => v.stockStatus == StockStatus.inStock).length;
    final lowCount = product.variants.where((v) => v.stockStatus == StockStatus.lowStock).length;
    final outCount = product.variants.where((v) => v.stockStatus == StockStatus.outOfStock).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
      physics: const BouncingScrollPhysics(),
      children: [
        // ─── Summary Card ─────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [groupColor.withValues(alpha: 0.15), groupColor.withValues(alpha: 0.05)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: groupColor.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(Icons.warehouse_rounded, color: groupColor, size: 20),
                const SizedBox(width: 8),
                Text('ملخص المخزون', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: groupColor)),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                _StatChip(totalQty.toStringAsFixed(0), 'إجمالي متاح', groupColor),
                const SizedBox(width: 8),
                _StatChip(totalReserved.toStringAsFixed(0), 'محجوز', Colors.orange),
                const SizedBox(width: 8),
                _StatChip('$inStockCount✓ $lowCount⚠ $outCount✗', 'حالة الأصناف', AppColors.textSecondary),
              ]),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ─── Each Variant ─────────────────────────────────
        ...product.variants.map((v) => _VariantStockCard(
          variant: v,
          groupColor: groupColor,
          canEdit: canEdit,
          unitLabel: _unitLabel(product.unitType),
          onUpdate: () => ref.read(catalogHubProvider.notifier).invalidate(),
        )),
      ],
    );
  }

  String _unitLabel(String type) {
    const map = {'rod': 'عود', 'panel': 'لوح', 'linear_meter': 'م.ط', 'square_meter': 'م²', 'roll': 'رول', 'box': 'كرتونة', 'piece': 'قطعة', 'tube': 'أنبوبة', 'container': 'عبوة'};
    return map[type] ?? type;
  }
}

class _StatChip extends StatelessWidget {
  final String value, label;
  final Color color;
  const _StatChip(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(color: AppColors.background.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: color)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 10, color: AppColors.textTertiary), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

/// A card for one variant's stock with smart actions
class _VariantStockCard extends ConsumerStatefulWidget {
  final EnrichedVariant variant;
  final Color groupColor;
  final bool canEdit;
  final String unitLabel;
  final VoidCallback onUpdate;

  const _VariantStockCard({
    required this.variant,
    required this.groupColor,
    required this.canEdit,
    required this.unitLabel,
    required this.onUpdate,
  });

  @override
  ConsumerState<_VariantStockCard> createState() => _VariantStockCardState();
}

class _VariantStockCardState extends ConsumerState<_VariantStockCard> {
  bool _isUpdating = false;

  Color get _statusColor {
    switch (widget.variant.stockStatus) {
      case StockStatus.inStock: return AppColors.success;
      case StockStatus.lowStock: return const Color(0xFFF59E0B);
      case StockStatus.outOfStock: return AppColors.error;
    }
  }

  String get _statusLabel {
    switch (widget.variant.stockStatus) {
      case StockStatus.inStock: return 'متاح';
      case StockStatus.lowStock: return 'منخفض';
      case StockStatus.outOfStock: return 'نفد';
    }
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.variant;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _statusColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(children: [
              _ColorRing(colorString: v.color, ringColor: _statusColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(v.variantName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: _statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                    child: Text(_statusLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: _statusColor)),
                  ),
                ]),
              ),
              if (widget.canEdit && !_isUpdating)
                IconButton.filledTonal(
                  icon: const Icon(Icons.tune_rounded, size: 20),
                  style: IconButton.styleFrom(backgroundColor: widget.groupColor.withValues(alpha: 0.1), foregroundColor: widget.groupColor),
                  tooltip: 'إدارة المخزون',
                  onPressed: () => _showSmartStockDialog(context),
                )
              else if (_isUpdating)
                const SizedBox(width: 40, height: 40, child: CircularProgressIndicator(strokeWidth: 2)),
            ]),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Stock numbers row
            Row(children: [
              _StockMetric(
                value: v.availableQty.toStringAsFixed(v.availableQty == v.availableQty.roundToDouble() ? 0 : 1),
                unit: widget.unitLabel,
                label: 'متاح',
                color: _statusColor,
              ),
              Container(width: 1, height: 40, color: AppColors.border, margin: const EdgeInsets.symmetric(horizontal: 12)),
              _StockMetric(
                value: v.reservedQty.toStringAsFixed(0),
                unit: widget.unitLabel,
                label: 'محجوز',
                color: Colors.orange,
              ),
              Container(width: 1, height: 40, color: AppColors.border, margin: const EdgeInsets.symmetric(horizontal: 12)),
              _StockMetric(
                value: v.reorderPoint > 0 ? v.reorderPoint.toStringAsFixed(0) : '—',
                unit: v.reorderPoint > 0 ? widget.unitLabel : '',
                label: 'حد إعادة الطلب',
                color: AppColors.textSecondary,
              ),
            ]),

            // Quick action buttons
            if (widget.canEdit) ...[
              const SizedBox(height: 12),
              Row(children: [
                _QuickActionBtn(
                  icon: Icons.add_rounded,
                  label: 'استلام',
                  color: AppColors.success,
                  onTap: () => _showSmartStockDialog(context, initialMode: _StockMode.add),
                ),
                const SizedBox(width: 8),
                _QuickActionBtn(
                  icon: Icons.remove_rounded,
                  label: 'صرف',
                  color: AppColors.error,
                  onTap: () => _showSmartStockDialog(context, initialMode: _StockMode.subtract),
                ),
                const SizedBox(width: 8),
                _QuickActionBtn(
                  icon: Icons.edit_rounded,
                  label: 'تعيين',
                  color: widget.groupColor,
                  onTap: () => _showSmartStockDialog(context, initialMode: _StockMode.set),
                ),
              ]),
            ],
          ],
        ),
      ),
    );
  }

  void _showSmartStockDialog(BuildContext context, {_StockMode initialMode = _StockMode.add}) {
    showDialog(
      context: context,
      builder: (ctx) => _SmartStockDialog(
        variant: widget.variant,
        unitLabel: widget.unitLabel,
        groupColor: widget.groupColor,
        initialMode: initialMode,
        onSave: (mode, qty, reorderPoint, notes) async {
          setState(() => _isUpdating = true);
          try {
            final client = ref.read(supabaseProvider);
            // Find inventory_item id
            final existing = await client
                .from('inventory_items')
                .select('id, available_qty')
                .eq('product_variant_id', widget.variant.id)
                .maybeSingle();

            double newQty;
            final currentQty = widget.variant.availableQty;

            if (mode == _StockMode.add) {
              newQty = currentQty + qty;
            } else if (mode == _StockMode.subtract) {
              newQty = (currentQty - qty).clamp(0, double.infinity);
            } else {
              newQty = qty;
            }

            if (existing != null) {
              final invId = existing['id'] as String;
              // Update quantity
              await client.from('inventory_items').update({
                'available_qty': newQty,
                'reorder_point': reorderPoint,
                'updated_at': DateTime.now().toIso8601String(),
              }).eq('id', invId);

              // Record movement
              final movType = mode == _StockMode.add ? 'in' : mode == _StockMode.subtract ? 'out' : 'adjustment';
              await client.from('inventory_movements').insert({
                'inventory_item_id': invId,
                'movement_type': movType,
                'quantity': mode == _StockMode.set ? (newQty - currentQty).abs() : qty,
                'reference_type': 'manual',
                'notes': notes.isNotEmpty ? notes : _defaultNote(mode),
              });
            } else {
              // Create inventory item + initial movement
              final newItem = await client.from('inventory_items').insert({
                'product_variant_id': widget.variant.id,
                'available_qty': newQty,
                'reserved_qty': 0,
                'reorder_point': reorderPoint ?? 0,
              }).select().single();

              await client.from('inventory_movements').insert({
                'inventory_item_id': newItem['id'],
                'movement_type': 'initial',
                'quantity': newQty,
                'reference_type': 'manual',
                'notes': notes.isNotEmpty ? notes : 'رصيد افتتاحي',
              });
            }

            // Optimistic update
            ref.read(catalogHubProvider.notifier).updateLocalStock(widget.variant.id, newQty);
            widget.onUpdate();
          } catch (e) {
            final errMsg = e.toString();
            if (mounted && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('خطأ: $errMsg'), backgroundColor: AppColors.error),
              );
            }
          } finally {
            if (mounted) setState(() => _isUpdating = false);
          }
        },
      ),
    );
  }

  String _defaultNote(_StockMode mode) {
    switch (mode) {
      case _StockMode.add: return 'استلام بضاعة - يدوي';
      case _StockMode.subtract: return 'صرف بضاعة - يدوي';
      case _StockMode.set: return 'تعديل رصيد - جرد';
    }
  }
}

class _StockMetric extends StatelessWidget {
  final String value, unit, label;
  final Color color;
  const _StockMetric({required this.value, required this.unit, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(text: value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: color)),
              if (unit.isNotEmpty)
                TextSpan(text: ' $unit', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: color.withValues(alpha: 0.7))),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 10, color: AppColors.textTertiary), textAlign: TextAlign.center),
      ]),
    );
  }
}

class _QuickActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickActionBtn({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(height: 2),
              Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Smart Stock Dialog ─────────────────────────────────────────

enum _StockMode { add, subtract, set }

class _SmartStockDialog extends StatefulWidget {
  final EnrichedVariant variant;
  final String unitLabel;
  final Color groupColor;
  final _StockMode initialMode;
  final Future<void> Function(_StockMode mode, double qty, double? reorderPoint, String notes) onSave;

  const _SmartStockDialog({
    required this.variant,
    required this.unitLabel,
    required this.groupColor,
    required this.initialMode,
    required this.onSave,
  });

  @override
  State<_SmartStockDialog> createState() => _SmartStockDialogState();
}

class _SmartStockDialogState extends State<_SmartStockDialog> {
  late _StockMode _mode;
  final _qtyCtrl = TextEditingController();
  final _reorderCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _isSaving = false;

  double get _qty => double.tryParse(_qtyCtrl.text) ?? 0;
  double get _currentQty => widget.variant.availableQty;
  double get _previewQty {
    switch (_mode) {
      case _StockMode.add: return _currentQty + _qty;
      case _StockMode.subtract: return (_currentQty - _qty).clamp(0, double.infinity);
      case _StockMode.set: return _qty;
    }
  }

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    if (widget.variant.reorderPoint > 0) {
      _reorderCtrl.text = widget.variant.reorderPoint.toStringAsFixed(0);
    }
    if (_mode == _StockMode.set) {
      _qtyCtrl.text = _currentQty.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _reorderCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Color get _modeColor {
    switch (_mode) {
      case _StockMode.add: return AppColors.success;
      case _StockMode.subtract: return AppColors.error;
      case _StockMode.set: return widget.groupColor;
    }
  }

  String get _modeLabel {
    switch (_mode) {
      case _StockMode.add: return 'استلام بضاعة';
      case _StockMode.subtract: return 'صرف / خصم';
      case _StockMode.set: return 'تعيين رصيد';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: _modeColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.inventory_2_rounded, color: _modeColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('إدارة المخزون', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  Text(widget.variant.variantName, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ]),
              ),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded), style: IconButton.styleFrom(foregroundColor: AppColors.textSecondary)),
            ]),
            const SizedBox(height: 20),

            // Mode Selector
            Container(
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
              padding: const EdgeInsets.all(4),
              child: Row(children: [
                _ModeTab(label: '➕ استلام', mode: _StockMode.add, selected: _mode, color: AppColors.success, onTap: (m) => setState(() { _mode = m; _qtyCtrl.clear(); })),
                _ModeTab(label: '➖ صرف', mode: _StockMode.subtract, selected: _mode, color: AppColors.error, onTap: (m) => setState(() { _mode = m; _qtyCtrl.clear(); })),
                _ModeTab(label: '✏️ تعيين', mode: _StockMode.set, selected: _mode, color: widget.groupColor, onTap: (m) => setState(() { _mode = m; _qtyCtrl.text = _currentQty.toStringAsFixed(0); })),
              ]),
            ),
            const SizedBox(height: 20),

            // Current Stock Display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(14)),
              child: Row(
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('الرصيد الحالي', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                    Row(children: [
                      Text(_currentQty.toStringAsFixed(0), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22)),
                      const SizedBox(width: 4),
                      Text(widget.unitLabel, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ]),
                  ]),
                  const Spacer(),
                  Icon(Icons.arrow_forward_rounded, color: AppColors.textSecondary),
                  const Spacer(),
                  // Preview (reads from parent state, updated by onChanged)
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text('الرصيد الجديد', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                    Row(children: [
                      Text(_previewQty.toStringAsFixed(0), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: _modeColor)),
                      const SizedBox(width: 4),
                      Text(widget.unitLabel, style: TextStyle(color: _modeColor.withValues(alpha: 0.7), fontSize: 13)),
                    ]),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Quantity Input
            TextField(
              controller: _qtyCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: _mode == _StockMode.set ? 'الكمية الجديدة' : 'الكمية',
                hintText: '0',
                suffixText: widget.unitLabel,
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: _modeColor, width: 2)),
              ),
            ),
            const SizedBox(height: 12),

            // Reorder Point
            TextField(
              controller: _reorderCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'حد إعادة الطلب (اختياري)',
                hintText: 'مثال: 5',
                suffixText: widget.unitLabel,
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 12),

            // Notes
            TextField(
              controller: _notesCtrl,
              decoration: InputDecoration(
                labelText: 'ملاحظات (اختياري)',
                hintText: _modeLabel,
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 20),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: (_qty <= 0 && _mode != _StockMode.set) || _isSaving ? null : () async {
                  setState(() => _isSaving = true);
                  final reorder = double.tryParse(_reorderCtrl.text);
                  await widget.onSave(_mode, _qty, reorder, _notesCtrl.text.trim());
                  // ignore: use_build_context_synchronously
                  if (mounted) Navigator.pop(context);
                },
                icon: _isSaving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.check_rounded),
                label: Text(_isSaving ? 'جارٍ الحفظ...' : 'حفظ', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                style: FilledButton.styleFrom(
                  backgroundColor: _modeColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  final String label;
  final _StockMode mode;
  final _StockMode selected;
  final Color color;
  final void Function(_StockMode) onTap;
  const _ModeTab({required this.label, required this.mode, required this.selected, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSelected = mode == selected;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _CalculationsTab extends StatelessWidget {
  final EnrichedProduct product;
  final Color groupColor;
  const _CalculationsTab({required this.product, required this.groupColor});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: AppColors.surface, shape: BoxShape.circle), child: Icon(Icons.calculate_rounded, size: 64, color: AppColors.textTertiary.withValues(alpha: 0.5))),
          const SizedBox(height: 24),
          Text('لا توجد حسابات سابقة', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 8),
          Text('احسب الكميات والتكلفة لهذا المنتج مباشرة.', style: TextStyle(color: AppColors.textTertiary)),
        ],
      ),
    );
  }
}

class _ColorRing extends StatelessWidget {
  final String? colorString;
  final Color ringColor;
  const _ColorRing({required this.colorString, required this.ringColor});

  @override
  Widget build(BuildContext context) {
    Color c = Colors.grey.shade300;
    if (colorString != null) {
      final parts = colorString!.split('|');
      final hex = (parts.length > 1 ? parts[1] : parts[0]).replaceAll('#', '');
      if (hex.length == 6 || hex.length == 8) c = Color(int.parse('FF$hex', radix: 16));
    }
    return Container(
      width: 48, height: 48,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: ringColor.withValues(alpha: 0.3), width: 2)),
      child: Container(decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
    );
  }
}

class _DimPill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _DimPill(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

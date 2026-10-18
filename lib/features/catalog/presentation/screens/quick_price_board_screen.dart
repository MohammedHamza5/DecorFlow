import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stream_pay/app/theme/app_colors.dart';
import 'package:stream_pay/core/local_db/app_database.dart';
import 'package:stream_pay/features/catalog/data/catalog_hub.dart';
import 'package:stream_pay/features/catalog/data/catalog_hub_state.dart';
import 'package:stream_pay/features/catalog/data/pricing_repository.dart';
import 'package:stream_pay/core/providers/data_providers.dart';
import 'package:stream_pay/shared/widgets/app_modals.dart';
import 'package:stream_pay/shared/widgets/glass_container.dart';
import 'package:stream_pay/core/responsive/constrained_body.dart';
import 'package:stream_pay/features/catalog/presentation/widgets/unified_category_pricing_modal.dart';

// ─── Normalized Category Group Helper ────────────────────────────────────────

class _CategoryGroup {
  final String key;
  final String title;
  final IconData icon;
  final List<String> aliases;

  const _CategoryGroup({
    required this.key,
    required this.title,
    required this.icon,
    required this.aliases,
  });

  bool matches(String productCategory) {
    final lower = productCategory.trim().toLowerCase();
    return aliases.any((a) => lower.contains(a.toLowerCase()));
  }
}

const List<_CategoryGroup> _standardGroups = [
  _CategoryGroup(
    key: 'بديل الرخام',
    title: 'بديل الرخام',
    icon: Icons.layers_rounded,
    aliases: ['بديل الرخام', 'بديل رخام', 'ألواح رخام', 'رخام'],
  ),
  _CategoryGroup(
    key: 'بديل الخشب',
    title: 'بديل الخشب',
    icon: Icons.view_column_rounded,
    aliases: ['بديل الخشب', 'بديل خشب', 'شرائح خشب', 'wood'],
  ),
  _CategoryGroup(
    key: 'شيبورد',
    title: 'شيبورد',
    icon: Icons.table_restaurant_rounded,
    aliases: ['شيبورد', 'ألواح شيبورد', 'chipboard'],
  ),
  _CategoryGroup(
    key: 'بديل الحجر',
    title: 'بديل الحجر',
    icon: Icons.terrain_rounded,
    aliases: ['بديل الحجر', 'بديل حجر', 'حجر بو فوم', 'stone'],
  ),
  _CategoryGroup(
    key: 'بانوهات',
    title: 'بانوهات',
    icon: Icons.crop_square_rounded,
    aliases: ['بانوهات', 'بانوه', 'أعواد بانوهات', 'molding'],
  ),
  _CategoryGroup(
    key: 'كرانيش وفيوتك',
    title: 'كرانيش وفيوتك',
    icon: Icons.line_style_rounded,
    aliases: ['كرانيش', 'فيوتك', 'كرنيشة', 'كرانيش فيوتك السويدي'],
  ),
  _CategoryGroup(
    key: 'وزرات واستيل',
    title: 'وزرات واستيل',
    icon: Icons.border_bottom_rounded,
    aliases: ['وزرات', 'وزرة', 'استيل', 'استانلس', 'فواصل'],
  ),
  _CategoryGroup(
    key: 'إكسسوارات ومواد لاصقة',
    title: 'إكسسوارات ولاصق',
    icon: Icons.handyman_rounded,
    aliases: ['إكسسوارات', 'اكسسوارات', 'لاصق', 'سيليكون', 'معجون', 'صر', 'بت لور'],
  ),
];

// ─── Main Screen ─────────────────────────────────────────────────────────────

class QuickPriceBoardScreen extends ConsumerStatefulWidget {
  const QuickPriceBoardScreen({super.key});

  @override
  ConsumerState<QuickPriceBoardScreen> createState() => _QuickPriceBoardScreenState();
}

class _QuickPriceBoardScreenState extends ConsumerState<QuickPriceBoardScreen> {
  final _searchController = TextEditingController();
  String? _selectedCategoryGroupKey;
  String? _selectedSpecFilter;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showBatchPricingDialog({
    required BuildContext context,
    required String categoryTitle,
    String? defaultDimension,
    String? defaultMaterial,
    int affectedCount = 0,
  }) {
    final group = resolveCategoryGroup(categoryTitle);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => UnifiedCategoryPricingModal(
        categoryTitle: group.title,
        categoryAliases: group.aliases,
        icon: group.icon,
        affectedCount: affectedCount,
        onSuccess: () {
          ref.read(catalogHubProvider.notifier).invalidate();
          ref.read(catalogHubProvider.notifier).load(forceRefresh: true);
        },
      ),
    );
  }

  void _showCategoryRulesSheet(BuildContext context, String categoryTitle) async {
    final pricingRepo = ref.read(pricingRepositoryProvider);
    final rules = await pricingRepo.getRulesForCategory(categoryTitle);

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CategoryRulesModal(
        category: categoryTitle,
        initialRules: rules,
        onRulesChanged: () {
          ref.read(catalogHubProvider.notifier).invalidate();
        },
      ),
    );
  }

  void _showVariantOverrideDialog(
    BuildContext context,
    EnrichedProduct product,
    EnrichedVariant variant,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => _VariantOverrideDialog(
        product: product,
        variant: variant,
        onSaved: () {
          ref.read(catalogHubProvider.notifier).invalidate();
        },
      ),
    );
  }

  void _showSmartPriceActionSheet(
    BuildContext context,
    EnrichedProduct product,
    EnrichedVariant variant,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _SmartPriceActionModal(
        product: product,
        variant: variant,
        onPriceCategorySpec: () {
          Navigator.pop(ctx);
          _showBatchPricingDialog(
            context: context,
            categoryTitle: product.category,
            defaultDimension: variant.dimensions,
            defaultMaterial: product.material,
          );
        },
        onCustomOverride: () {
          Navigator.pop(ctx);
          _showVariantOverrideDialog(context, product, variant);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hub = ref.watch(catalogHubProvider);
    final suppliersAsync = ref.watch(suppliersProvider);
    final suppliers = suppliersAsync.value ?? [];

    // Derive active category groups present in products
    final activeGroups = <_CategoryGroup>[];
    for (final g in _standardGroups) {
      final hasItems = hub.allProducts.any((p) => g.matches(p.category));
      if (hasItems) {
        activeGroups.add(g);
      }
    }

    // Add any categories in DB not covered by standard groups
    for (final cat in hub.availableCategories) {
      final isCovered = _standardGroups.any((g) => g.matches(cat));
      if (!isCovered && cat.trim().isNotEmpty) {
        activeGroups.add(
          _CategoryGroup(
            key: cat,
            title: cat,
            icon: Icons.category_rounded,
            aliases: [cat],
          ),
        );
      }
    }

    // Auto-select initial category
    if (_selectedCategoryGroupKey == null && activeGroups.isNotEmpty) {
      _selectedCategoryGroupKey = activeGroups.first.key;
    }

    final currentGroup = activeGroups.firstWhere(
      (g) => g.key == _selectedCategoryGroupKey,
      orElse: () => activeGroups.isNotEmpty
          ? activeGroups.first
          : const _CategoryGroup(
              key: 'الكل',
              title: 'الكل',
              icon: Icons.apps_rounded,
              aliases: [],
            ),
    );

    // Products matching selected group
    final matchingProducts = hub.allProducts.where((p) {
      if (_selectedCategoryGroupKey == null) return true;
      return currentGroup.matches(p.category);
    }).toList();

    // Flatten variants
    final List<Map<String, dynamic>> allVariants = [];
    for (final p in matchingProducts) {
      for (final v in p.variants) {
        allVariants.add({
          'product': p,
          'variant': v,
        });
      }
    }

    // Extract dynamic specifications for sub-filtering
    final Map<String, int> specCounts = {};
    for (final item in allVariants) {
      final p = item['product'] as EnrichedProduct;
      final v = item['variant'] as EnrichedVariant;
      String spec = '';
      if (v.dimensions != null && v.dimensions!.trim().isNotEmpty) {
        spec = v.dimensions!.trim();
      } else if (v.pieceLength > 0) {
        spec = '${v.pieceLength}م'
            '${v.pieceWidth > 0 ? ' × ${v.pieceWidth}م' : ''}';
      } else if (p.material != null && p.material!.isNotEmpty) {
        spec = p.material!;
      } else {
        spec = 'مقاس افتراضي';
      }
      specCounts[spec] = (specCounts[spec] ?? 0) + 1;
    }

    // Unpriced count in this group
    final unpricedInGroup = allVariants.where((item) {
      final v = item['variant'] as EnrichedVariant;
      final price = v.sellingPrice;
      return price <= 0;
    }).length;

    // Filter by search query & spec
    final filtered = allVariants.where((item) {
      final p = item['product'] as EnrichedProduct;
      final v = item['variant'] as EnrichedVariant;

      // Spec filter
      if (_selectedSpecFilter != null) {
        final matchesDim = v.dimensions?.contains(_selectedSpecFilter!) ?? false;
        final matchesMat = p.material?.contains(_selectedSpecFilter!) ?? false;
        final matchesName = v.variantName.contains(_selectedSpecFilter!);
        if (!matchesDim && !matchesMat && !matchesName) return false;
      }

      // Search query
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase().trim();

      final supplier = suppliers.firstWhere(
        (s) => s['id']?.toString() == v.supplierId,
        orElse: () => <String, dynamic>{},
      );
      final supplierName = supplier['name']?.toString() ?? '';

      final searchableText = [
        p.name,
        p.code,
        v.variantName,
        v.color ?? '',
        v.dimensions ?? '',
        v.supplierCode ?? '',
        supplierName,
      ].map((s) => s.toLowerCase()).join(' ');

      return query.split(' ').every((term) => searchableText.contains(term));
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('لوحة الأسعار السريعة', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'تحديث ومزامنة الأسعار',
            onPressed: () {
              ref.read(catalogHubProvider.notifier).invalidate();
              ref.invalidate(suppliersProvider);
              AppToast.showSuccess(context, 'تم تحديث قائمة الأسعار ومطابقة القواعد');
            },
          ),
        ],
      ),
      body: ConstrainedBody(
        child: Column(
          children: [
            // ─── Search Bar ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: GlassContainer(
                blur: 10,
                color: AppColors.surface.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(16),
                child: TextField(
                  controller: _searchController,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    hintText: 'البحث بالألوان، الأكواد، أو الموردين...',
                    hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 13),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),
            ),

            // ─── Normalized Category Chips ──────────────────────────────
            if (activeGroups.isNotEmpty)
              Container(
                height: 48,
                margin: const EdgeInsets.only(bottom: 6),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: activeGroups.length,
                  itemBuilder: (context, index) {
                    final group = activeGroups[index];
                    final isSelected = group.key == _selectedCategoryGroupKey;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        avatar: Icon(
                          group.icon,
                          size: 16,
                          color: isSelected ? Colors.white : AppColors.primary,
                        ),
                        label: Text(
                          group.title,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                            fontSize: 12,
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.surface,
                        checkmarkColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : AppColors.border,
                          ),
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedCategoryGroupKey = group.key;
                              _selectedSpecFilter = null;
                            });
                          }
                        },
                      ),
                    );
                  },
                ),
              ),

            // ─── Dynamic Specification Sub-Chips (if available) ──────────
            if (specCounts.length > 1)
              Container(
                height: 38,
                margin: const EdgeInsets.only(bottom: 8),
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: FilterChip(
                        label: Text('الكل (${allVariants.length})', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        selected: _selectedSpecFilter == null,
                        selectedColor: AppColors.primary.withValues(alpha: 0.15),
                        labelStyle: TextStyle(
                          color: _selectedSpecFilter == null ? AppColors.primary : AppColors.textSecondary,
                        ),
                        side: BorderSide(
                          color: _selectedSpecFilter == null ? AppColors.primary : AppColors.border,
                        ),
                        onSelected: (_) => setState(() => _selectedSpecFilter = null),
                      ),
                    ),
                    ...specCounts.entries.map((entry) {
                      final isSelected = _selectedSpecFilter == entry.key;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilterChip(
                          label: Text(
                            '${entry.key} (${entry.value})',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          selected: isSelected,
                          selectedColor: AppColors.primary.withValues(alpha: 0.15),
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.primary : AppColors.textSecondary,
                          ),
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : AppColors.border,
                          ),
                          onSelected: (_) => setState(() {
                            _selectedSpecFilter = isSelected ? null : entry.key;
                          }),
                        ),
                      );
                    }),
                  ],
                ),
              ),

            // ─── Hero Smart Batch Pricing Banner ─────────────────────────
            if (_selectedCategoryGroupKey != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: GlassContainer(
                  color: unpricedInGroup > 0
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : AppColors.surface,
                  border: Border.all(
                    color: unpricedInGroup > 0
                        ? AppColors.primary.withValues(alpha: 0.35)
                        : AppColors.border,
                    width: unpricedInGroup > 0 ? 1.5 : 1,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (unpricedInGroup > 0 ? AppColors.primary : AppColors.success).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          unpricedInGroup > 0 ? Icons.auto_awesome : Icons.check_circle_rounded,
                          color: unpricedInGroup > 0 ? AppColors.primary : AppColors.success,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              unpricedInGroup > 0
                                  ? 'تسعير موحد لقسم: ${currentGroup.title}'
                                  : 'قسم ${currentGroup.title} مسعر بالكامل ✓',
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                            ),
                            Text(
                              unpricedInGroup > 0
                                  ? 'يوجد $unpricedInGroup صنفاً غير مسعر - اضغط لتسعير القسم بالكامل دفعة واحدة 🚀'
                                  : 'إجمالي الأصناف: ${allVariants.length} صنف - مربوط بقواعد التسعير الذكي',
                              style: TextStyle(
                                fontSize: 11,
                                color: unpricedInGroup > 0 ? AppColors.primary : AppColors.textSecondary,
                                fontWeight: unpricedInGroup > 0 ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: () => _showBatchPricingDialog(
                          context: context,
                          categoryTitle: currentGroup.title,
                          affectedCount: unpricedInGroup > 0 ? unpricedInGroup : allVariants.length,
                        ),
                        icon: const Icon(Icons.flash_on_rounded, size: 16),
                        label: Text(
                          unpricedInGroup > 0 ? 'تسعير الكل' : 'تعديل السعر',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: unpricedInGroup > 0 ? AppColors.primary : AppColors.surfaceVariant,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        onPressed: () => _showCategoryRulesSheet(context, currentGroup.title),
                        tooltip: 'إدارة قواعد التسعير',
                        icon: const Icon(Icons.tune_rounded, size: 18),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.background,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: AppColors.border),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // ─── Price Grid List ────────────────────────────────────────
            Expanded(
              child: hub.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off_rounded, size: 48, color: AppColors.textTertiary),
                              const SizedBox(height: 12),
                              Text('لا توجد أصناف مطابقة للبحث', style: TextStyle(color: AppColors.textSecondary)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final item = filtered[index];
                            final p = item['product'] as EnrichedProduct;
                            final v = item['variant'] as EnrichedVariant;

                            final supplier = suppliers.firstWhere(
                              (s) => s['id']?.toString() == v.supplierId,
                              orElse: () => <String, dynamic>{},
                            );
                            final supplierName = supplier['name'] as String?;

                            Color colorPreview = Colors.transparent;
                            if (v.color != null) {
                              final parts = v.color!.split('|');
                              final hexPart = parts.length > 1 ? parts[1] : parts[0];
                              if (hexPart.startsWith('#')) {
                                final hex = hexPart.replaceAll('#', '');
                                if (hex.length == 6 || hex.length == 8) {
                                  colorPreview = Color(int.parse('FF$hex', radix: 16));
                                }
                              }
                            }

                            return _PriceBoardCard(
                              product: p,
                              variant: v,
                              supplierName: supplierName,
                              colorPreview: colorPreview,
                              onQuickPrice: () => _showSmartPriceActionSheet(context, p, v),
                              onEditPrice: () => _showVariantOverrideDialog(context, p, v),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Modern Price Board Card ─────────────────────────────────────────────────

class _PriceBoardCard extends StatelessWidget {
  final EnrichedProduct product;
  final EnrichedVariant variant;
  final String? supplierName;
  final Color colorPreview;
  final VoidCallback onQuickPrice;
  final VoidCallback onEditPrice;

  const _PriceBoardCard({
    required this.product,
    required this.variant,
    this.supplierName,
    required this.colorPreview,
    required this.onQuickPrice,
    required this.onEditPrice,
  });

  void _copyToClipboard(BuildContext context) {
    final buffer = StringBuffer();
    buffer.writeln('📋 تفاصيل السعر والمواصفات:');
    buffer.writeln('• المنتج: ${product.name}');
    buffer.writeln('• الصنف: ${variant.variantName}');
    if (product.code.isNotEmpty) buffer.writeln('• كود النظام: ${product.code}');
    if (variant.supplierCode != null && variant.supplierCode!.isNotEmpty) {
      buffer.writeln('• كود المورد: ${variant.supplierCode}');
    }

    final List<String> dims = [];
    if (variant.dimensions != null && variant.dimensions!.isNotEmpty) {
      dims.add(variant.dimensions!);
    } else {
      if (variant.pieceLength > 0) dims.add('طول: ${variant.pieceLength}م');
      if (variant.pieceWidth > 0) dims.add('عرض: ${variant.pieceWidth}م');
      if (variant.thickness > 0) dims.add('سمك: ${variant.thickness}مم');
    }
    if (dims.isNotEmpty) buffer.writeln('• المقاس: ${dims.join(' × ')}');

    final displaySelling = variant.sellingPrice;
    if (displaySelling > 0) {
      buffer.writeln('• سعر البيع (قطاعي): ${displaySelling.toStringAsFixed(0)} ج.م');
      if (variant.technicianPrice > 0) {
        buffer.writeln('• سعر الفنيين والمهندسين: ${variant.technicianPrice.toStringAsFixed(0)} ج.م');
      }
    } else {
      buffer.writeln('• السعر: غير مسعر');
    }

    if (supplierName != null) buffer.writeln('• المورد: $supplierName');

    final stockLabel = variant.stockStatus == StockStatus.inStock
        ? 'متوفر (${variant.availableQty.toStringAsFixed(0)})'
        : variant.stockStatus == StockStatus.lowStock
            ? 'كمية منخفضة (${variant.availableQty.toStringAsFixed(0)})'
            : 'غير متوفر / نفد';
    buffer.writeln('• حالة المخزن: $stockLabel');

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نسخ تفاصيل السعر للحافظة ✓', textDirection: TextDirection.rtl),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Color get _statusColor {
    switch (variant.stockStatus) {
      case StockStatus.inStock:
        return AppColors.success;
      case StockStatus.lowStock:
        return const Color(0xFFF59E0B);
      case StockStatus.outOfStock:
        return AppColors.error;
    }
  }

  String get _statusLabel {
    switch (variant.stockStatus) {
      case StockStatus.inStock:
        return 'متاح';
      case StockStatus.lowStock:
        return 'منخفض';
      case StockStatus.outOfStock:
        return 'نفد';
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupColor = product.group?.color ?? AppColors.primary;
    final displaySelling = variant.sellingPrice;
    final isUnpriced = displaySelling <= 0;
    final profit = (displaySelling - variant.costPrice).clamp(0, double.infinity);
    final profitPercent = displaySelling > 0 ? (profit / displaySelling) * 100 : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: isUnpriced
              ? Colors.amber.withValues(alpha: 0.4)
              : AppColors.border,
          width: isUnpriced ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (colorPreview != Colors.transparent)
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: colorPreview,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border, width: 2),
                      boxShadow: [
                        BoxShadow(color: colorPreview.withValues(alpha: 0.3), blurRadius: 6),
                      ],
                    ),
                  )
                else
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: groupColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.palette_outlined, color: groupColor, size: 22),
                  ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${product.name} - ${variant.variantName.contains('(') ? variant.variantName.split(' (').last.replaceAll(')', '') : variant.variantName}',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        children: [
                          if (product.code.isNotEmpty)
                            Text(
                              'كود: ${product.code}',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          if (variant.supplierCode != null && variant.supplierCode!.isNotEmpty)
                            Text(
                              'مورد: ${variant.supplierCode}',
                              style: TextStyle(color: groupColor, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (isUnpriced)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.error_outline_rounded, size: 14, color: Colors.amber),
                            SizedBox(width: 4),
                            Text(
                              'غير مسعر',
                              style: TextStyle(
                                color: Colors.amber,
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      )
                    else ...[
                      Text(
                        '${displaySelling.toStringAsFixed(0)} ج.م',
                        style: const TextStyle(
                          color: AppColors.success,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (variant.technicianPrice > 0)
                        Text(
                          '${variant.technicianPrice.toStringAsFixed(0)} ج فنيين',
                          style: const TextStyle(
                            color: Color(0xFF2563EB),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      if (variant.costPrice > 0)
                        Text(
                          'تكلفة: ${variant.costPrice.toStringAsFixed(0)} ج'
                          '${profit > 0 ? ' (+${profit.toStringAsFixed(0)}ج)' : ''}',
                          style: TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                    if (variant.priceSourceLabel.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: (variant.isCustomOverride ? Colors.orange : AppColors.primary).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: (variant.isCustomOverride ? Colors.orange : AppColors.primary).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          variant.priceSourceLabel,
                          style: TextStyle(
                            fontSize: 9,
                            color: variant.isCustomOverride ? Colors.orange : AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      Icon(Icons.straighten_rounded, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          variant.dimensions ??
                              ('${variant.pieceLength}م'
                                  '${variant.pieceWidth > 0 ? ' × ${variant.pieceWidth}م' : ''}'
                                  '${variant.thickness > 0 ? ' × ${variant.thickness}مم' : ''}'),
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                if (!isUnpriced && profitPercent > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'هامش ${profitPercent.toStringAsFixed(0)}%',
                      style: const TextStyle(fontSize: 10, color: AppColors.success, fontWeight: FontWeight.bold),
                    ),
                  ),

                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: _statusColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '$_statusLabel (${variant.availableQty.toStringAsFixed(0)})',
                      style: TextStyle(
                        fontSize: 11,
                        color: _statusColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),

            Row(
              children: [
                if (isUnpriced)
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: onQuickPrice,
                      icon: const Icon(Icons.flash_on_rounded, size: 16),
                      label: const Text('تسعير سريع ⚡', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  )
                else
                  IconButton(
                    onPressed: onEditPrice,
                    tooltip: 'تعديل أو تخصيص السعر',
                    icon: const Icon(Icons.edit_note_rounded, size: 22, color: AppColors.primary),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                const SizedBox(width: 8),

                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _copyToClipboard(context),
                    icon: const Icon(Icons.copy_rounded, size: 15),
                    label: const Text('نسخ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      context.go('/calculator', extra: {
                        'product': product.toRawMap(),
                        'variant': {
                          'id': variant.id,
                          'product_id': variant.productId,
                          'variant_name': variant.variantName,
                          'color': variant.color,
                          'dimensions': variant.dimensions,
                          'piece_length': variant.pieceLength,
                          'piece_width': variant.pieceWidth,
                          'thickness': variant.thickness,
                        },
                      });
                    },
                    icon: const Icon(Icons.calculate_rounded, size: 15),
                    label: const Text('الحساب', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    style: FilledButton.styleFrom(
                      backgroundColor: groupColor.withValues(alpha: 0.15),
                      foregroundColor: groupColor,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Smart Action Modal for 1-Click Fast Pricing ──────────────────────────────

class _SmartPriceActionModal extends StatelessWidget {
  final EnrichedProduct product;
  final EnrichedVariant variant;
  final VoidCallback onPriceCategorySpec;
  final VoidCallback onCustomOverride;

  const _SmartPriceActionModal({
    required this.product,
    required this.variant,
    required this.onPriceCategorySpec,
    required this.onCustomOverride,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: AppColors.borderDark, borderRadius: BorderRadius.circular(4)),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'تسعير ذكي: ${product.name}',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'اختر طريقة التسعير الأنسب لسرعة وسهولة العمل:',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),

          InkWell(
            onTap: onPriceCategorySpec,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.flash_on_rounded, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Text(
                              'تسعير موحد للقسم والمواصفة',
                              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                            ),
                            SizedBox(width: 6),
                            Text('⚡ موصى به', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'تحديد سعر موحد يطبق فوراً على هذا الصنف وجميع الأصناف المشابهة في قسم ${product.category}',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: AppColors.primary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          InkWell(
            onTap: onCustomOverride,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Icon(Icons.tune_rounded, color: AppColors.textSecondary, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'سعر استثنائي لهذا الكود فقط',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'تحديد سعر مخصص لصنف (${variant.variantName}) فقط دون التأثير على باقي المعرض',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: AppColors.textTertiary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}


// ─── Category Rules Drawer / Sheet ───────────────────────────────────────────

class _CategoryRulesModal extends ConsumerStatefulWidget {
  final String category;
  final List<LocalPricingRule> initialRules;
  final VoidCallback onRulesChanged;

  const _CategoryRulesModal({
    required this.category,
    required this.initialRules,
    required this.onRulesChanged,
  });

  @override
  ConsumerState<_CategoryRulesModal> createState() => _CategoryRulesModalState();
}

class _CategoryRulesModalState extends ConsumerState<_CategoryRulesModal> {
  late List<LocalPricingRule> _rules;

  @override
  void initState() {
    super.initState();
    _rules = List.from(widget.initialRules);
  }

  Future<void> _refreshRules() async {
    final updated = await ref.read(pricingRepositoryProvider).getRulesForCategory(widget.category);
    if (!mounted) return;
    setState(() => _rules = updated);
    widget.onRulesChanged();
  }

  void _showEditRuleDialog(LocalPricingRule? rule) {
    final isNew = rule == null;
    final subcatCtrl = TextEditingController(text: rule?.subcategory ?? '');
    final materialCtrl = TextEditingController(text: rule?.material ?? '');
    final dimCtrl = TextEditingController(text: rule?.dimensionSpec ?? '');
    final variantTypeCtrl = TextEditingController(text: rule?.variantType ?? '');
    final sellingCtrl = TextEditingController(text: rule != null ? rule.sellingPrice.toStringAsFixed(0) : '');
    final techCtrl = TextEditingController(text: rule != null ? rule.technicianPrice.toStringAsFixed(0) : '');
    final costCtrl = TextEditingController(text: rule != null ? rule.costPrice.toStringAsFixed(0) : '');
    final minCtrl = TextEditingController(text: rule != null ? rule.minSellingPrice.toStringAsFixed(0) : '');

    showDialog(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Icon(isNew ? Icons.add_circle_outline_rounded : Icons.edit_rounded, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              isNew ? 'إضافة قاعدة تسعير ذكية' : 'تعديل قاعدة التسعير',
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isNew) ...[
                  TextField(
                    controller: materialCtrl,
                    decoration: const InputDecoration(
                      labelText: 'الخامة (مثل: PVC أو WPC أو خشب)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: dimCtrl,
                    decoration: const InputDecoration(
                      labelText: 'المقاس / العرض (مثل: 17سم أو 2.80×1.22م)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: variantTypeCtrl,
                    decoration: const InputDecoration(
                      labelText: 'النوع / التشطيب (مثل: عادي أو ريزن أو أوبن بوك)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                TextField(
                  controller: sellingCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'سعر البيع قطاعي (ج.م) *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.shopping_bag_outlined),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: techCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'سعر الفنيين والمهندسين (ج.م) *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.engineering_outlined),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: costCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'سعر التكلفة / الشراء (ج.م)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.receipt_outlined),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: minCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'الحد الأدنى للبيع (ج.م)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.security_outlined),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dlgCtx).pop(),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () async {
              final selling = double.tryParse(sellingCtrl.text) ?? 0.0;
              final tech = double.tryParse(techCtrl.text) ?? (selling * 0.90);
              final cost = double.tryParse(costCtrl.text) ?? 0.0;
              final min = double.tryParse(minCtrl.text) ?? (selling * 0.85);

              if (selling <= 0) {
                AppToast.showError(context, 'يرجى إدخال سعر بيع صحيح');
                return;
              }

              final pricingRepo = ref.read(pricingRepositoryProvider);
              await pricingRepo.upsertRule(
                id: rule?.id,
                category: widget.category,
                subcategory: isNew
                    ? (subcatCtrl.text.trim().isNotEmpty ? subcatCtrl.text.trim() : null)
                    : rule.subcategory,
                material: isNew
                    ? (materialCtrl.text.trim().isNotEmpty ? materialCtrl.text.trim() : null)
                    : rule.material,
                dimensionSpec: isNew
                    ? (dimCtrl.text.trim().isNotEmpty ? dimCtrl.text.trim() : null)
                    : rule.dimensionSpec,
                variantType: isNew
                    ? (variantTypeCtrl.text.trim().isNotEmpty ? variantTypeCtrl.text.trim() : null)
                    : rule.variantType,
                sellingPrice: selling,
                technicianPrice: tech > 0 ? tech : selling,
                costPrice: cost,
                minSellingPrice: min,
              );

              if (!dlgCtx.mounted) return;
              Navigator.of(dlgCtx).pop();
              await _refreshRules();
              if (mounted) {
                AppToast.showSuccess(context, 'تم حفظ قاعدة التسعير وتطبيقها فوراً على أصناف الفئة ✓');
              }
            },
            child: const Text('حفظ القاعدة'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderDark.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'قواعد التسعير الموحد: ${widget.category}',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'أي صنف في هذه الفئة يطابق نفس الخامة والمقاس يأخذ نفس السعر تلقائياً',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _rules.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.rule_folder_outlined, size: 56, color: AppColors.textTertiary),
                        const SizedBox(height: 12),
                        Text(
                          'لا توجد قواعد تسعير مسجلة بعد لهذه الفئة',
                          style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'أضف قاعدة أولى لتحديد سعر موحد بحسب الخامة والمقاس',
                          style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _rules.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (ctx, i) {
                      final r = _rules[i];
                      final specParts = [
                        if (r.material != null && r.material!.isNotEmpty) r.material!,
                        if (r.dimensionSpec != null && r.dimensionSpec!.isNotEmpty) r.dimensionSpec!,
                        if (r.variantType != null && r.variantType!.isNotEmpty) r.variantType!,
                        if (r.subcategory != null && r.subcategory!.isNotEmpty) r.subcategory!,
                      ];
                      final specTitle = specParts.isNotEmpty ? specParts.join(' • ') : 'قاعدة عامة للفئة';

                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.tune_rounded, size: 18, color: AppColors.primary),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    specTitle,
                                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit_rounded, size: 20, color: AppColors.primary),
                                  tooltip: 'تعديل القاعدة',
                                  onPressed: () => _showEditRuleDialog(r),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.error),
                                  tooltip: 'حذف القاعدة',
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (c) => AlertDialog(
                                        title: const Text('حذف قاعدة التسعير'),
                                        content: Text('هل أنت متأكد من حذف قاعدة "$specTitle"؟'),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.of(c).pop(false), child: const Text('إلغاء')),
                                          FilledButton(
                                            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
                                            onPressed: () => Navigator.of(c).pop(true),
                                            child: const Text('حذف'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      await ref.read(pricingRepositoryProvider).deleteRule(r.id);
                                      await _refreshRules();
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                _ruleBadge('🛍️ بيع قطاعي', '${r.sellingPrice.toStringAsFixed(0)} ج.م', AppColors.success),
                                _ruleBadge('👷‍♂️ فنيين', '${r.technicianPrice.toStringAsFixed(0)} ج.م', const Color(0xFF2563EB)),
                                if (r.costPrice > 0)
                                  _ruleBadge('🏷️ تكلفة', '${r.costPrice.toStringAsFixed(0)} ج.م', AppColors.textSecondary),
                                if (r.minSellingPrice > 0)
                                  _ruleBadge('🛑 أدنى مسموح', '${r.minSellingPrice.toStringAsFixed(0)} ج.م', Colors.orange),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton.icon(
              onPressed: () => _showEditRuleDialog(null),
              icon: const Icon(Icons.add_rounded),
              label: const Text('إضافة قاعدة تسعير ذكية جديدة', style: TextStyle(fontWeight: FontWeight.w800)),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ruleBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
          const SizedBox(width: 4),
          Text(value, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

// ─── Individual Variant Override Dialog ──────────────────────────────────────

class _VariantOverrideDialog extends ConsumerStatefulWidget {
  final EnrichedProduct product;
  final EnrichedVariant variant;
  final VoidCallback onSaved;

  const _VariantOverrideDialog({
    required this.product,
    required this.variant,
    required this.onSaved,
  });

  @override
  ConsumerState<_VariantOverrideDialog> createState() => _VariantOverrideDialogState();
}

class _VariantOverrideDialogState extends ConsumerState<_VariantOverrideDialog> {
  late bool _isCustomOverride;
  late final TextEditingController _sellingCtrl;
  late final TextEditingController _techCtrl;
  late final TextEditingController _costCtrl;

  @override
  void initState() {
    super.initState();
    _isCustomOverride = widget.variant.isCustomOverride;
    final activeSelling = widget.variant.sellingPrice;
    _sellingCtrl = TextEditingController(
      text: activeSelling > 0 ? activeSelling.toStringAsFixed(0) : '',
    );
    _techCtrl = TextEditingController(
      text: widget.variant.technicianPrice > 0 ? widget.variant.technicianPrice.toStringAsFixed(0) : '',
    );
    _costCtrl = TextEditingController(
      text: widget.variant.costPrice > 0 ? widget.variant.costPrice.toStringAsFixed(0) : '',
    );
  }

  @override
  void dispose() {
    _sellingCtrl.dispose();
    _techCtrl.dispose();
    _costCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('تخصيص سعر الصنف', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
          const SizedBox(height: 4),
          Text(
            '${widget.product.name} - ${widget.variant.variantName}',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'سعر مخصص استثنائي',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Text(
                            _isCustomOverride
                                ? 'الصنف لا يتبع سعر الفئة ويستخدم أرقاماً مخصصة'
                                : 'الصنف يتبع السعر الموحد الذكي للفئة',
                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isCustomOverride,
                      activeColor: AppColors.primary,
                      onChanged: (v) => setState(() => _isCustomOverride = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (_isCustomOverride) ...[
                TextField(
                  controller: _sellingCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'سعر البيع قطاعي (ج.م) *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.shopping_bag_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _techCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'سعر الفنيين والمهندسين (ج.م)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.engineering_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _costCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'سعر التكلفة / الشراء (ج.م)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.receipt_outlined),
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.variant.priceSourceLabel.isNotEmpty
                              ? widget.variant.priceSourceLabel
                              : 'يتم احتساب السعر تلقائياً من قاعدة الفئة',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          onPressed: () async {
            final productRepo = ref.read(productRepositoryProvider);
            if (_isCustomOverride) {
              final selling = double.tryParse(_sellingCtrl.text);
              final tech = double.tryParse(_techCtrl.text);
              final cost = double.tryParse(_costCtrl.text);
              await productRepo.updateVariantPricingOverrides(
                widget.variant.id,
                sellingPriceOverride: selling,
                technicianPriceOverride: tech,
                costPriceOverride: cost,
              );
            } else {
              await productRepo.updateVariantPricingOverrides(
                widget.variant.id,
                clearOverrides: true,
              );
            }

            if (!context.mounted) return;
            Navigator.of(context).pop();
            widget.onSaved();
            AppToast.showSuccess(
              context,
              _isCustomOverride ? 'تم حفظ السعر المخصص للصنف بنجاح ✓' : 'تمت إعادة الصنف للتسعير الموحد الذكي ✓',
            );
          },
          child: const Text('تأكيد وحفظ'),
        ),
      ],
    );
  }
}

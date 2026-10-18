import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:stream_pay/app/theme/app_colors.dart';
import 'package:stream_pay/features/catalog/data/catalog_hub.dart';
import 'package:stream_pay/features/catalog/data/catalog_hub_state.dart';
import 'package:stream_pay/shared/widgets/app_modals.dart';

/// High-Definition Catalog Picker for Purchase Invoices.
/// Features prominent material imagery, complete technical and financial data,
/// clear stock status, and instant variant/color selection.
class PurchaseCatalogPicker extends ConsumerStatefulWidget {
  final void Function(EnrichedProduct product, EnrichedVariant variant)
      onVariantSelected;

  const PurchaseCatalogPicker({
    super.key,
    required this.onVariantSelected,
  });

  @override
  ConsumerState<PurchaseCatalogPicker> createState() =>
      _PurchaseCatalogPickerState();
}

class _PurchaseCatalogPickerState
    extends ConsumerState<PurchaseCatalogPicker> {
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounceTimer;
  String _searchQuery = '';
  String? _selectedCategory;

  final List<String> _categories = const [
    'الكل',
    'بديل خشب',
    'بديل رخام',
    'شيبورد',
    'فوم ديكوري',
    'وزرات واستيل',
    'بانوهات',
    'سيليكون ولواصق',
  ];

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String val) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => _searchQuery = val.trim().toLowerCase());
    });
  }

  void _toggleCategory(String cat) {
    AppHaptics.selection();
    setState(() {
      if (cat == 'الكل' || _selectedCategory == cat) {
        _selectedCategory = null;
      } else {
        _selectedCategory = cat;
      }
    });
  }

  Color _getCategoryColor(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('خشب')) return const Color(0xFF059669); // Forest Emerald
    if (cat.contains('رخام')) return const Color(0xFF0284C7); // Sky Blue
    if (cat.contains('شيبورد')) return const Color(0xFFD97706); // Amber Gold
    if (cat.contains('فوم')) return const Color(0xFF8B5CF6); // Royal Violet
    if (cat.contains('بانوه')) return const Color(0xFF6366F1); // Electric Indigo
    if (cat.contains('وزر') || cat.contains('استيل')) {
      return const Color(0xFFE11D48); // Rose Bronze
    }
    if (cat.contains('سيليكون') || cat.contains('معجون')) {
      return const Color(0xFFDC2626); // Ruby Red
    }
    return AppColors.primary;
  }

  List<EnrichedProduct> _filter(List<EnrichedProduct> all) {
    var list = all;
    if (_selectedCategory != null && _selectedCategory != 'الكل') {
      final c = _selectedCategory!.toLowerCase();
      list = list
          .where((p) =>
              p.category.toLowerCase().contains(c) ||
              p.name.toLowerCase().contains(c))
          .toList();
    }
    if (_searchQuery.isNotEmpty) {
      list = list.where((p) {
        final matchesName = p.name.toLowerCase().contains(_searchQuery);
        final matchesCat = p.category.toLowerCase().contains(_searchQuery);
        final matchesVariant = p.variants.any((v) =>
            v.variantName.toLowerCase().contains(_searchQuery) ||
            (v.color?.toLowerCase().contains(_searchQuery) ?? false) ||
            (v.supplierCode?.toLowerCase().contains(_searchQuery) ?? false));
        return matchesName || matchesCat || matchesVariant;
      }).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final catalogState = ref.watch(catalogHubProvider);
    final products = _filter(catalogState.allProducts);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Search Box
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _onSearchChanged,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'ابحث عن خامة، كود، أو درجة لون (بديل خشب، 952، رخام...)...',
                hintStyle:
                    TextStyle(fontSize: 12, color: AppColors.textTertiary),
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 16),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.background,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: AppColors.border.withValues(alpha: 0.6)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: AppColors.border.withValues(alpha: 0.6)),
                ),
              ),
            ),
          ),

          // 2. Category Chips Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: _categories.map((cat) {
                final isSelected = cat == 'الكل'
                    ? _selectedCategory == null
                    : _selectedCategory == cat;
                final catColor =
                    cat == 'الكل' ? AppColors.primary : _getCategoryColor(cat);

                return Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: FilterChip(
                    label: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: catColor,
                    backgroundColor: AppColors.background,
                    showCheckmark: false,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isSelected
                            ? catColor
                            : AppColors.border.withValues(alpha: 0.5),
                      ),
                    ),
                    onSelected: (_) => _toggleCategory(cat),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 6),
          Divider(height: 1, color: AppColors.border.withValues(alpha: 0.5)),

          // 3. Grid of Rich Material Cards
          Expanded(
            child: products.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 44,
                            color: AppColors.textTertiary.withValues(alpha: 0.5)),
                        const SizedBox(height: 10),
                        const Text(
                          'لا توجد خامات مطابقة للاستعلام',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'جرّب مسح نص البحث أو اختيار تصنيف آخر',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      int crossAxisCount;
                      double childAspectRatio;

                      if (width >= 1050) {
                        crossAxisCount = 4;
                        childAspectRatio = 0.74;
                      } else if (width >= 720) {
                        crossAxisCount = 3;
                        childAspectRatio = 0.73;
                      } else if (width >= 460) {
                        crossAxisCount = 2;
                        childAspectRatio = 0.74;
                      } else {
                        crossAxisCount = 2;
                        childAspectRatio = 0.67;
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.all(10),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: childAspectRatio,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return _buildProductCard(product);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(EnrichedProduct product) {
    final firstVariant =
        product.variants.isNotEmpty ? product.variants.first : null;
    final imageUrl = firstVariant?.imageUrl ?? product.imageUrl;
    final hasMultipleVariants = product.variants.length > 1;

    // Financial calculations
    final double cost = firstVariant != null
        ? (firstVariant.netPrice > 0
            ? firstVariant.netPrice
            : (firstVariant.costPrice > 0
                ? firstVariant.costPrice
                : firstVariant.listPrice))
        : 0.0;
    final double selling = firstVariant != null
        ? (firstVariant.sellingPrice > 0
            ? firstVariant.sellingPrice
            : firstVariant.listPrice)
        : 0.0;
    final double availableQty = firstVariant?.availableQty ?? 0.0;
    final unit = product.unitType.isNotEmpty ? product.unitType : 'لوح';
    final categoryColor = _getCategoryColor(product.category);

    return InkWell(
      onTap: () => _handleProductTap(product),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Large, Prominent Image Frame
            SizedBox(
              height: 125,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  imageUrl != null && imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          cacheWidth: 360,
                          errorBuilder: (context, error, stackTrace) =>
                              _imagePlaceholder(product, categoryColor),
                        )
                      : _imagePlaceholder(product, categoryColor),

                  // Top-Right Category Tag
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.72),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: categoryColor.withValues(alpha: 0.5),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: categoryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            product.category.isNotEmpty
                                ? product.category
                                : 'خامة',
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Top-Left Variants or Code Badge
                  Positioned(
                    top: 6,
                    left: 6,
                    child: hasMultipleVariants
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '🎨 ${product.variants.length} ألوان',
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : (firstVariant?.color != null &&
                                firstVariant!.color!.isNotEmpty)
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.65),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  firstVariant.color!,
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),

            // 2. Comprehensive Details Section (Auto-fits with zero overflow)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(9),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top: Name & Sub-specs
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          hasMultipleVariants
                              ? 'انقر لاختيار اللون / الدرجة المطلوبة'
                              : (firstVariant?.dimensions != null &&
                                      firstVariant!.dimensions!.isNotEmpty
                                  ? 'مقاس: ${firstVariant.dimensions}'
                                  : (firstVariant?.variantName ?? '')),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 9.5,
                            color: hasMultipleVariants
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            fontWeight: hasMultipleVariants
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),

                    // Middle: Financial Pricing (Cost & Selling)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.border.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'التكلفة',
                                style: TextStyle(
                                    fontSize: 8.5,
                                    color: AppColors.textSecondary),
                              ),
                              Text(
                                cost > 0
                                    ? '${NumberFormat('#,##0', 'ar').format(cost)} ج.م'
                                    : 'غير محدد',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w900,
                                  color: cost > 0
                                      ? const Color(0xFFF59E0B)
                                      : AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'البيع',
                                style: TextStyle(
                                    fontSize: 8.5,
                                    color: AppColors.textSecondary),
                              ),
                              Text(
                                selling > 0
                                    ? '${NumberFormat('#,##0', 'ar').format(selling)} ج.م'
                                    : '-',
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Bottom: Stock Status & Action Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Stock badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: availableQty > 5
                                ? AppColors.success.withValues(alpha: 0.12)
                                : (availableQty > 0
                                    ? const Color(0xFFF59E0B)
                                        .withValues(alpha: 0.12)
                                    : AppColors.error
                                        .withValues(alpha: 0.12)),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            availableQty > 0
                                ? '${availableQty.toStringAsFixed(0)} $unit'
                                : 'نفد ⚠️',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: availableQty > 5
                                  ? AppColors.success
                                  : (availableQty > 0
                                      ? const Color(0xFFF59E0B)
                                      : AppColors.error),
                            ),
                          ),
                        ),

                        // Action Button
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add_rounded,
                                  size: 13, color: Colors.white),
                              SizedBox(width: 2),
                              Text(
                                'توريد +',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder(EnrichedProduct product, Color categoryColor) {
    return Container(
      color: categoryColor.withValues(alpha: 0.08),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.texture_rounded,
              size: 38,
              color: categoryColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 4),
            Text(
              product.category.isNotEmpty ? product.category : 'خامة ديكور',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: categoryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleProductTap(EnrichedProduct product) {
    AppHaptics.selection();
    if (product.variants.isEmpty) return;

    if (product.variants.length == 1) {
      widget.onVariantSelected(product, product.variants.first);
    } else {
      // Multiple variants: show color/code selection sheet
      _showVariantPickerSheet(product);
    }
  }

  void _showVariantPickerSheet(EnrichedProduct product) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final categoryColor = _getCategoryColor(product.category);

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.palette_rounded,
                          color: categoryColor, size: 22),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w900, fontSize: 15),
                          ),
                          Text(
                            'اختر درجة ولون الخامة لإضافتها لبنود فاتورة المشتريات',
                            style: TextStyle(
                                fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.55,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: product.variants.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (ctx, i) {
                      final v = product.variants[i];
                      final double cost = v.netPrice > 0
                          ? v.netPrice
                          : (v.costPrice > 0 ? v.costPrice : v.listPrice);
                      final double selling =
                          v.sellingPrice > 0 ? v.sellingPrice : v.listPrice;

                      return ListTile(
                        dense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 4),
                        leading: CircleAvatar(
                          radius: 16,
                          backgroundColor:
                              categoryColor.withValues(alpha: 0.12),
                          child: Text(
                            '${i + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: categoryColor,
                            ),
                          ),
                        ),
                        title: Text(
                          v.variantName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        subtitle: Row(
                          children: [
                            Text(
                              'المخزن: ${v.availableQty.toStringAsFixed(0)} ${product.unitType}',
                              style: TextStyle(
                                fontSize: 11,
                                color: v.availableQty > 5
                                    ? AppColors.success
                                    : (v.availableQty > 0
                                        ? const Color(0xFFF59E0B)
                                        : AppColors.error),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('•',
                                style: TextStyle(
                                    color: AppColors.textTertiary)),
                            const SizedBox(width: 8),
                            Text(
                              cost > 0
                                  ? 'التكلفة: ${NumberFormat('#,##0', 'ar').format(cost)} ج.م'
                                  : 'غير محدد',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFF59E0B),
                              ),
                            ),
                            if (selling > 0) ...[
                              const SizedBox(width: 8),
                              Text('•',
                                  style: TextStyle(
                                      color: AppColors.textTertiary)),
                              const SizedBox(width: 8),
                              Text(
                                'البيع: ${NumberFormat('#,##0', 'ar').format(selling)} ج.م',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary),
                              ),
                            ],
                          ],
                        ),
                        trailing: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(Icons.add_rounded, size: 16),
                          label: const Text('توريد',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold)),
                          onPressed: () {
                            Navigator.pop(ctx);
                            widget.onVariantSelected(product, v);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

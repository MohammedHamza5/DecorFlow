import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_pay/app/theme/app_colors.dart';
import 'package:stream_pay/core/providers/data_providers.dart';

/// A search-enabled product picker bottom sheet.
///
/// Returns the selected product + variant as a tuple map.
class ProductPickerSheet extends ConsumerStatefulWidget {
  final String? categoryFilter;
  const ProductPickerSheet({super.key, this.categoryFilter});

  @override
  ConsumerState<ProductPickerSheet> createState() => _ProductPickerSheetState();
}

class _ProductPickerSheetState extends ConsumerState<ProductPickerSheet> {
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();
  bool _showAll = false;

  @override
  void initState() {
    super.initState();
    // Invalidate the provider on open to ensure we get freshly added products
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(productsProvider(null));
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider(null));

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.inventory_2_outlined,
                        color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.categoryFilter != null && widget.categoryFilter!.isNotEmpty && !_showAll
                          ? 'اختر ${widget.categoryFilter}'
                          : 'اختر المنتج',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  if (widget.categoryFilter != null && widget.categoryFilter!.isNotEmpty)
                    TextButton.icon(
                      icon: Icon(_showAll ? Icons.filter_alt : Icons.filter_alt_off, size: 16),
                      label: Text(_showAll ? 'تصفية' : 'عرض الكل', style: const TextStyle(fontSize: 12)),
                      onPressed: () => setState(() => _showAll = !_showAll),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchCtrl,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  hintText: 'ابحث بالاسم أو الكود...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                ),
                onChanged: (v) => setState(() => _searchQuery = v.trim()),
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            // Product list
            Expanded(
              child: productsAsync.when(
                data: (products) {
                  final filtered = products.where((p) {
                    if (!_showAll && widget.categoryFilter != null && widget.categoryFilter!.isNotEmpty) {
                      final cat = (p['category'] as String? ?? '').trim();
                      final filter = widget.categoryFilter!.trim();
                      
                      String normalize(String s) => s.replaceAll('ال', '').replaceAll(' ', '').replaceAll('أ', 'ا').replaceAll('إ', 'ا').replaceAll('آ', 'ا').replaceAll('ة', 'ه');
                      
                      final normCat = normalize(cat);
                      final normFilter = normalize(filter);

                      if (normCat != normFilter && !normCat.contains(normFilter) && !normFilter.contains(normCat)) {
                         return false;
                      }
                    }
                    if (_searchQuery.isEmpty) return true;
                    
                    final name = (p['name'] as String? ?? '').toLowerCase();
                    final code = (p['code'] as String? ?? '').toLowerCase();
                    final brand = (p['brand'] as String? ?? '').toLowerCase();
                    final q = _searchQuery.toLowerCase();
                    return name.contains(q) ||
                        code.contains(q) ||
                        brand.contains(q);
                  }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off_outlined,
                              size: 48,
                              color: AppColors.textTertiary),
                          const SizedBox(height: 8),
                          Text('لا توجد نتائج',
                              style: TextStyle(
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) =>
                        _ProductTile(product: filtered[index]),
                  );
                },
                loading: () => const Center(
                    child: CircularProgressIndicator()),
                error: (error, stackTrace) => const Center(
                    child: Text('فشل تحميل المنتجات')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A product tile that expands to show variants.
class _ProductTile extends StatelessWidget {
  final Map<String, dynamic> product;

  const _ProductTile({required this.product});

  @override
  Widget build(BuildContext context) {
    final variants = product['product_variants'] as List? ?? [];
    final category = product['category'] as String? ?? '';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14)),
      elevation: 0,
      child: ExpansionTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.view_in_ar_outlined,
              color: AppColors.accent, size: 22),
        ),
        title: Text(
          product['name'] ?? '',
          style: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Row(
          children: [
            if (product['code'] != null)
              Text(
                product['code'],
                style: TextStyle(
                    fontSize: 11, color: AppColors.textTertiary),
              ),
            if (category.isNotEmpty) ...[
              Text(' • ',
                  style: TextStyle(color: AppColors.textTertiary)),
              Text(category,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.primary)),
            ],
          ],
        ),
        children: [
          if (variants.isEmpty)
            Padding(
              padding: EdgeInsets.all(16),
              child: Text('لا توجد متغيرات لهذا المنتج',
                  style: TextStyle(
                      color: AppColors.textTertiary, fontSize: 12)),
            )
          else
            ...variants.map((v) {
              final variant = v as Map<String, dynamic>;
              final pricing =
                  variant['product_pricing'] as List? ?? [];
              final retailPrice = pricing.isNotEmpty
                  ? (pricing.first['retail_price'] as num?)
                      ?.toStringAsFixed(0)
                  : null;

              final dims = <String>[];
              if (variant['width'] != null) {
                dims.add(
                    'ع: ${(variant['width'] as num).toStringAsFixed(2)}');
              }
              if (variant['height'] != null) {
                dims.add(
                    'ط: ${(variant['height'] as num).toStringAsFixed(2)}');
              }
              if (variant['length'] != null) {
                dims.add(
                    'ل: ${(variant['length'] as num).toStringAsFixed(2)}');
              }

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 2),
                onTap: () {
                  Navigator.of(context).pop({
                    'product': product,
                    'variant': variant,
                  });
                },
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary
                        .withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.check_circle_outline,
                      color: AppColors.primary, size: 18),
                ),
                title: Text(
                  variant['label'] ?? 'الافتراضي',
                  style: const TextStyle(fontSize: 13),
                ),
                subtitle: dims.isNotEmpty
                    ? Text(
                        dims.join(' — '),
                        style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textTertiary),
                      )
                    : null,
                trailing: retailPrice != null
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.success
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$retailPrice ج.م',
                          style: const TextStyle(
                            color: AppColors.success,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : null,
              );
            }),
        ],
      ),
    );
  }
}

/// Shows the product picker bottom sheet and returns selected product+variant.
Future<Map<String, dynamic>?> showProductPicker(BuildContext context, {String? categoryFilter}) {
  return showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ProductPickerSheet(categoryFilter: categoryFilter),
  );
}

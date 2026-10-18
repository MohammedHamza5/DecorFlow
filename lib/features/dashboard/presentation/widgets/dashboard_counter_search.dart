import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:stream_pay/app/theme/app_colors.dart';
import 'package:stream_pay/features/catalog/data/catalog_hub.dart';
import 'package:stream_pay/features/catalog/data/catalog_hub_state.dart';
import 'package:stream_pay/shared/widgets/app_modals.dart';

/// Compact, high-speed Counter Search and live price inquiry widget.
class DashboardCounterSearch extends ConsumerStatefulWidget {
  const DashboardCounterSearch({super.key});

  @override
  ConsumerState<DashboardCounterSearch> createState() =>
      _DashboardCounterSearchState();
}

class _DashboardCounterSearchState
    extends ConsumerState<DashboardCounterSearch> {
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounceTimer;
  String _searchQuery = '';
  String? _selectedCategoryFilter;

  final List<String> _quickCategories = const [
    'بديل خشب',
    'بديل رخام',
    'شيبورد',
    'بانوهات',
    'سيليكون',
  ];

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() {
          _searchQuery = value.trim();
        });
      }
    });
  }

  void _selectCategoryFilter(String category) {
    AppHaptics.selection();
    setState(() {
      if (_selectedCategoryFilter == category) {
        _selectedCategoryFilter = null;
      } else {
        _selectedCategoryFilter = category;
      }
    });
  }

  List<Map<String, dynamic>> _filterProducts(List<EnrichedProduct> allProducts) {
    final hasQuery = _searchQuery.isNotEmpty;
    final hasCategory = _selectedCategoryFilter != null;

    if (!hasQuery && !hasCategory) return [];

    final q = _searchQuery.toLowerCase();
    final catFilter = _selectedCategoryFilter?.toLowerCase();

    final List<Map<String, dynamic>> results = [];

    for (final p in allProducts) {
      final pCat = p.category.toLowerCase();

      // Check category filter
      if (hasCategory && !pCat.contains(catFilter!) && !p.name.toLowerCase().contains(catFilter)) {
        continue;
      }

      for (final v in p.variants) {
        final fullName = '${p.name} ${v.variantName} ${v.color ?? ''}'.toLowerCase();

        if (!hasQuery || fullName.contains(q) || pCat.contains(q)) {
          results.add({
            'product': p,
            'variant': v,
            'displayName': '${p.name} - ${v.variantName}',
            'category': p.category,
            'price': v.sellingPrice > 0 ? v.sellingPrice : (v.netPrice > 0 ? v.netPrice : v.listPrice),
            'availableQty': v.availableQty,
            'unit': p.unitType.isNotEmpty ? p.unitType : 'لوح',
          });

          if (results.length >= 6) break;
        }
      }
      if (results.length >= 6) break;
    }

    return results;
  }

  @override
  Widget build(BuildContext context) {
    final catalogState = ref.watch(catalogHubProvider);
    final matchingItems = _filterProducts(catalogState.allProducts);
    final isSearchingOrFiltered =
        _searchQuery.isNotEmpty || _selectedCategoryFilter != null;

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
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.search_rounded,
                  size: 17,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'استعلام سريع عن خامة أو سعر',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (isSearchingOrFiltered)
                GestureDetector(
                  onTap: () {
                    _searchCtrl.clear();
                    setState(() {
                      _searchQuery = '';
                      _selectedCategoryFilter = null;
                    });
                  },
                  child: Text(
                    'مسح البحث',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Search Field
          TextField(
            controller: _searchCtrl,
            onChanged: _onSearchChanged,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'ابحث بالاسم أو الكود (بديل خشب، 952، رخام...)...',
              hintStyle: TextStyle(fontSize: 12, color: AppColors.textTertiary),
              prefixIcon: const Icon(
                Icons.search_rounded,
                size: 18,
                color: AppColors.primary,
              ),
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Quick Category Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _quickCategories.map((cat) {
                final isSelected = _selectedCategoryFilter == cat;
                return Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: FilterChip(
                    label: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surfaceVariant,
                    checkmarkColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : AppColors.border,
                        width: 1.2,
                      ),
                    ),
                    onSelected: (_) => _selectCategoryFilter(cat),
                  ),
                );
              }).toList(),
            ),
          ),

          // Results Preview
          if (isSearchingOrFiltered) ...[
            const SizedBox(height: 10),
            Divider(height: 1, color: AppColors.border.withValues(alpha: 0.5)),
            const SizedBox(height: 8),
            if (matchingItems.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'لا توجد خامات مطابقة للاستعلام',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: matchingItems.length,
                separatorBuilder: (_, _) => Divider(
                  height: 1,
                  color: AppColors.border.withValues(alpha: 0.3),
                ),
                itemBuilder: (context, idx) {
                  final item = matchingItems[idx];
                  final EnrichedProduct p = item['product'];
                  final EnrichedVariant v = item['variant'];
                  final double price = item['price'];
                  final double qty = item['availableQty'];
                  final String unit = item['unit'];

                  return InkWell(
                    onTap: () {
                      AppHaptics.selection();
                      context.push('/product/${p.id}?variantId=${v.id}');
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['displayName'],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${item['category']} • متاح: ${qty.toStringAsFixed(0)} $unit',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    color: qty > 5 ? AppColors.success : AppColors.error,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              price > 0
                                  ? '${NumberFormat('#,##0', 'ar').format(price)} ج.م'
                                  : 'غير مسعر',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ],
      ),
    );
  }
}

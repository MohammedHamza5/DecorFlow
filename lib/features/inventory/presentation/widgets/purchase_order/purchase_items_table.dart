import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stream_pay/app/theme/app_colors.dart';
import 'package:stream_pay/shared/widgets/app_modals.dart';

/// Interactive table for purchase invoice items with instant quantity and cost editing.
class PurchaseItemsTable extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final void Function(int index, double newQty) onQtyChanged;
  final void Function(int index, double newCost) onCostChanged;
  final void Function(int index) onRemoveItem;

  const PurchaseItemsTable({
    super.key,
    required this.items,
    required this.onQtyChanged,
    required this.onCostChanged,
    required this.onRemoveItem,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_shopping_cart_rounded,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'فاتورة المشتريات فارغة',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'اختر الخامات والألواح من الكتالوج الجانبي لإضافتها وتحديد كميات وسعر التوريد',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final currencyFmt = NumberFormat('#,##0', 'ar');

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Table Column Headers
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Text(
                    'الخامة / الصنف',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Center(
                    child: Text(
                      'الكمية الموردة',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Text(
                      'سعر التكلفة',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'الإجمالي',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ),
                SizedBox(width: 36),
              ],
            ),
          ),
          const Divider(height: 1),

          // Items ListView
          Expanded(
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = items[index];
                final double qty = (item['qty'] as num).toDouble();
                final double cost = (item['cost'] as num).toDouble();
                final double total = qty * cost;
                final String unit = item['unit'] as String? ?? 'لوح';

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    children: [
                      // Item Name & Variant
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'] as String,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12.5,
                              ),
                            ),
                            Text(
                              'الوحدة: $unit',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Quantity Editor (- / input / +)
                      Expanded(
                        flex: 4,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline,
                                  size: 18),
                              color: AppColors.textSecondary,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                  minWidth: 26, minHeight: 26),
                              onPressed: () {
                                if (qty > 1) {
                                  AppHaptics.light();
                                  onQtyChanged(index, qty - 1);
                                } else {
                                  AppHaptics.light();
                                  onRemoveItem(index);
                                }
                              },
                            ),
                            SizedBox(
                              width: 48,
                              child: TextFormField(
                                key: ValueKey('qty_${item['variantId']}_$qty'),
                                initialValue: qty == qty.truncateToDouble()
                                    ? qty.toInt().toString()
                                    : qty.toString(),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 6),
                                  filled: true,
                                  fillColor: AppColors.background,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        BorderSide(color: AppColors.border),
                                  ),
                                ),
                                onFieldSubmitted: (val) {
                                  final parsed = double.tryParse(val);
                                  if (parsed != null && parsed > 0) {
                                    onQtyChanged(index, parsed);
                                  }
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline,
                                  size: 18),
                              color: AppColors.primary,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                  minWidth: 26, minHeight: 26),
                              onPressed: () {
                                AppHaptics.light();
                                onQtyChanged(index, qty + 1);
                              },
                            ),
                          ],
                        ),
                      ),

                      // Cost Price Editor
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: TextFormField(
                            key: ValueKey('cost_${item['variantId']}_$cost'),
                            initialValue: cost == cost.truncateToDouble()
                                ? cost.toInt().toString()
                                : cost.toStringAsFixed(1),
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                    decimal: true),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 6),
                              filled: true,
                              fillColor: AppColors.background,
                              suffixText: 'ج',
                              suffixStyle: const TextStyle(fontSize: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: AppColors.border),
                              ),
                            ),
                            onFieldSubmitted: (val) {
                              final parsed = double.tryParse(val);
                              if (parsed != null && parsed >= 0) {
                                onCostChanged(index, parsed);
                              }
                            },
                          ),
                        ),
                      ),

                      // Row Total Cost
                      Expanded(
                        flex: 3,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${currencyFmt.format(total)} ج',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),

                      // Remove Button
                      IconButton(
                        icon: const Icon(Icons.close_rounded,
                            size: 18, color: AppColors.error),
                        tooltip: 'حذف من الفاتورة',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                            minWidth: 32, minHeight: 32),
                        onPressed: () {
                          AppHaptics.light();
                          onRemoveItem(index);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

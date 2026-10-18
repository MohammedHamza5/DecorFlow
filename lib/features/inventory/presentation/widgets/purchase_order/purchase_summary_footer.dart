import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stream_pay/app/theme/app_colors.dart';
import 'package:stream_pay/shared/widgets/app_modals.dart';

/// Summary footer for the purchase invoice.
/// Displays item counts, total quantity, discount, final net amount, and primary submit button.
class PurchaseSummaryFooter extends StatelessWidget {
  final int itemsCount;
  final double totalQty;
  final double subtotal;
  final double discount;
  final ValueChanged<double> onDiscountChanged;
  final bool isLoading;
  final VoidCallback onSave;

  const PurchaseSummaryFooter({
    super.key,
    required this.itemsCount,
    required this.totalQty,
    required this.subtotal,
    required this.discount,
    required this.onDiscountChanged,
    required this.isLoading,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFmt = NumberFormat('#,##0', 'ar');
    final netTotal = (subtotal - discount).clamp(0.0, double.infinity);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 600;

          final metricsInfo = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _metricChip('البنود', '$itemsCount صنف'),
              const SizedBox(width: 8),
              _metricChip('إجمالي الكمية', '${totalQty.toStringAsFixed(0)} وحدة'),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'الإجمالي الصافي:',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${currencyFmt.format(netTotal)} ج.م',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ],
          );

          final submitButton = SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              icon: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.check_circle_outline_rounded, size: 20),
              label: Text(
                isLoading ? 'جاري التوريد...' : 'حفظ وتوريد الفاتورة للمخزون 📥',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              onPressed: isLoading ? null : () {
                AppHaptics.medium();
                onSave();
              },
            ),
          );

          if (isWide) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                metricsInfo,
                submitButton,
              ],
            );
          } else {
            return Column(
              children: [
                metricsInfo,
                const SizedBox(height: 12),
                SizedBox(width: double.infinity, child: submitButton),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _metricChip(String label, String val) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          Text(val,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:stream_pay/app/theme/app_colors.dart';
import 'package:stream_pay/core/providers/erp_providers.dart';

/// Modal bottom sheet displaying audit history of previous shift closings and reconciliations.
class ShiftHistoryDialog extends ConsumerWidget {
  const ShiftHistoryDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const ShiftHistoryDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(shiftClosingsHistoryProvider);
    final currencyFmt = NumberFormat('#,##0', 'ar');

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),

              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.history_edu_rounded,
                          color: AppColors.primary, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'سجل تقفيل الورديات والجرد السابق',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(height: 1),

              // Content List
              Expanded(
                child: historyAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (e, _) => Center(child: Text('خطأ: $e')),
                  data: (shifts) {
                    if (shifts.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lock_clock_rounded,
                                size: 48, color: AppColors.textTertiary),
                            const SizedBox(height: 10),
                            const Text(
                              'لا توجد ورديات مغلقة مسجلة بعد',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      itemCount: shifts.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final shift = shifts[index];
                        final diff = shift.difference;
                        final isMatched = diff.abs() < 0.01;
                        final isShortage = diff < -0.01;

                        final statusColor = isMatched
                            ? AppColors.success
                            : (isShortage
                                ? AppColors.error
                                : const Color(0xFF0284C7));
                        final statusText = isMatched
                            ? 'مطابق 100% ✅'
                            : (isShortage
                                ? 'عجز ${currencyFmt.format(diff.abs())} ج.م ⚠️'
                                : 'زيادة ${currencyFmt.format(diff)} ج.م ℹ️');

                        final timeStr = DateFormat(
                          'hh:mm a • yyyy/MM/dd',
                          'ar',
                        ).format(shift.closedAt);

                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'وردية رقم #${shift.id}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      statusText,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: statusColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'المستلم: ${shift.closedBy} • $timeStr',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Divider(height: 1),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'المتوقع: ${currencyFmt.format(shift.expectedCash)} ج.م',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    'الفعلي المعدود: ${currencyFmt.format(shift.actualCash)} ج.م',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              if (shift.notes != null &&
                                  shift.notes!.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  'ملاحظات: ${shift.notes}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textTertiary,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

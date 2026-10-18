import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:stream_pay/app/theme/app_colors.dart';
import 'package:stream_pay/core/providers/erp_providers.dart';
import 'package:stream_pay/shared/widgets/app_modals.dart';

/// Shift Closing & Cash Reconciliation Sheet.
/// Computes expected system balance vs actual counted cash, detecting match, shortage, or surplus.
class CloseShiftSheet extends ConsumerStatefulWidget {
  const CloseShiftSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const CloseShiftSheet(),
    );
  }

  @override
  ConsumerState<CloseShiftSheet> createState() => _CloseShiftSheetState();
}

class _CloseShiftSheetState extends ConsumerState<CloseShiftSheet> {
  final TextEditingController _actualCashCtrl = TextEditingController();
  final TextEditingController _closedByCtrl =
      TextEditingController(text: 'الكاشير');
  final TextEditingController _notesCtrl = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _actualCashCtrl.dispose();
    _closedByCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expectedCashAsync = ref.watch(drawerBalanceProvider);
    final currencyFmt = NumberFormat('#,##0', 'ar');

    return Padding(
      padding: EdgeInsets.fromLTRB(
        18,
        14,
        18,
        MediaQuery.of(context).viewInsets.bottom + 18,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 38,
              height: 4,
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          // Title
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_clock_rounded, color: AppColors.error, size: 20),
              SizedBox(width: 8),
              Text(
                'تقفيل الوردية وجرد النقدية بالدرج',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 16),

          expectedCashAsync.when(
            loading: () => const Center(
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (e, _) => Text('خطأ في حساب الرصيد: $e'),
            data: (expected) {
              final actual = double.tryParse(_actualCashCtrl.text) ?? 0.0;
              final hasInput = _actualCashCtrl.text.isNotEmpty;
              final diff = actual - expected;
              final isNegativeExpected = expected < 0;

              return Column(
                children: [
                  // Expected Balance Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isNegativeExpected
                          ? AppColors.error.withValues(alpha: 0.08)
                          : AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isNegativeExpected
                            ? AppColors.error.withValues(alpha: 0.3)
                            : AppColors.primary.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'الرصيد الدفتري المتوقع بالدرج:',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'محسوب تلقائياً من المبيعات والمصاريف',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${currencyFmt.format(expected)} ج.م',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: isNegativeExpected
                                ? AppColors.error
                                : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Real-time Variance Evaluation Banner
                  if (hasInput) ...[
                    const SizedBox(height: 12),
                    _buildVarianceBanner(diff, isNegativeExpected, expected, actual),
                  ],
                ],
              );
            },
          ),

          const SizedBox(height: 14),

          // Actual Counted Cash Input
          TextFormField(
            controller: _actualCashCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'المبلغ الفعلي المعدود بالدرج نقداً *',
              hintText: 'عدّ الفلوس اللي في إيدك واكتبها هنا',
              hintStyle: TextStyle(fontSize: 12, color: AppColors.textTertiary),
              prefixIcon: const Icon(
                Icons.attach_money_rounded,
                color: AppColors.success,
              ),
              suffixText: 'ج.م',
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.border),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Closed By and Handover Notes
          Row(
            children: [
              Expanded(
                flex: 4,
                child: TextFormField(
                  controller: _closedByCtrl,
                  decoration: InputDecoration(
                    labelText: 'اسم الكاشير المستلم *',
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 6,
                child: TextFormField(
                  controller: _notesCtrl,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    labelText: 'ملاحظات الجرد (اختياري)',
                    hintText: 'تم تسليم النقدية لصاحب المحل...',
                    hintStyle: TextStyle(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Submit & Close Shift Button
          FilledButton.icon(
            onPressed: _isSaving ? null : _saveShiftClosing,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.lock_rounded, size: 18),
            label: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'تأكيد إغلاق الوردية وتسليم النقدية',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildVarianceBanner(
    double diff,
    bool isNegativeExpected,
    double expected,
    double actual,
  ) {
    if (isNegativeExpected) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.orange, width: 1.2),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, size: 18, color: Colors.deepOrange),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                actual == 0
                    ? 'سيتم تسوية العجز الدفتري (${expected.abs().toStringAsFixed(0)} ج.م) وتصفير الدرج للوردية القادمة.'
                    : 'سيتم تسوية العجز وتوريد النقدية الفعلية (${actual.toStringAsFixed(0)} ج.م).',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.deepOrange,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final isMatched = diff.abs() < 0.01;
    final isShortage = diff < -0.01;

    final bannerColor = isMatched
        ? AppColors.success
        : (isShortage ? AppColors.error : const Color(0xFF0284C7));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bannerColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: bannerColor, width: 1.3),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                isMatched
                    ? Icons.check_circle_rounded
                    : (isShortage
                        ? Icons.warning_amber_rounded
                        : Icons.add_circle_outline_rounded),
                color: bannerColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isMatched
                    ? '✓ الدرج مطابق 100% تماماً'
                    : (isShortage ? '⚠ يوجد عجز في الدرج:' : 'ℹ توجد زيادة بالدرج:'),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: bannerColor,
                ),
              ),
            ],
          ),
          Text(
            isMatched
                ? 'مضبوط بالقرش'
                : '${diff.abs().toStringAsFixed(0)} ج.م',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 15,
              color: bannerColor,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveShiftClosing() async {
    if (_actualCashCtrl.text.isEmpty) {
      AppToast.showError(context, 'يرجى إدخال المبلغ الفعلي المعدود بالدرج');
      return;
    }

    final actualCash = double.tryParse(_actualCashCtrl.text);
    if (actualCash == null || actualCash < 0) {
      AppToast.showError(context, 'يرجى إدخال مبلغ صحيح');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final engine = ref.read(cashFlowEngineProvider);
      final shiftId = await engine.closeShift(
        closedBy: _closedByCtrl.text.isEmpty ? 'الكاشير' : _closedByCtrl.text,
        actualCash: actualCash,
        notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
      );

      ref.invalidate(drawerBalanceProvider);
      ref.invalidate(dailyCashSummaryProvider);
      ref.invalidate(recentTransactionsProvider);
      ref.invalidate(shiftClosingsHistoryProvider);

      if (mounted) {
        Navigator.pop(context);
        AppToast.showSuccess(
          context,
          'تم تقفيل الوردية #$shiftId وترحيل حساب الدرج بنجاح ✅',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        AppToast.showError(context, 'خطأ أثناء إغلاق الوردية: $e');
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:stream_pay/app/theme/app_colors.dart';
import 'package:stream_pay/shared/widgets/app_modals.dart';

/// The core operational action buttons:
/// - [ 💸 صرف مصروف ]
/// - [ 📥 إيداع / سحب نقدية ]
/// - Large bottom bar: [ 🔒 تقفيل الوردية وتسليم النقدية ]
class CashQuickActions extends StatelessWidget {
  final double currentBalance;
  final VoidCallback onExpense;
  final VoidCallback onDepositWithdraw;
  final VoidCallback onCloseShift;

  const CashQuickActions({
    super.key,
    required this.currentBalance,
    required this.onExpense,
    required this.onDepositWithdraw,
    required this.onCloseShift,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Two Primary Routine Buttons
        Row(
          children: [
            // Button 1: Record Expense
            Expanded(
              child: SizedBox(
                height: 54,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  icon: const Icon(Icons.money_off_rounded, size: 20),
                  label: const Text(
                    'صرف مصروف 💸',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  onPressed: () {
                    AppHaptics.medium();
                    onExpense();
                  },
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Button 2: Deposit / Withdrawal
            Expanded(
              child: SizedBox(
                height: 54,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  icon: const Icon(Icons.payments_rounded, size: 20),
                  label: const Text(
                    'إيداع / سحب 📥',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  onPressed: () {
                    AppHaptics.medium();
                    onDepositWithdraw();
                  },
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // End of Day Big Action Banner
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: currentBalance > 0
                  ? AppColors.primary
                  : AppColors.textPrimary,
              side: BorderSide(
                color: currentBalance > 0
                    ? AppColors.primary.withValues(alpha: 0.5)
                    : AppColors.border,
                width: 1.5,
              ),
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: Icon(
              currentBalance > 0
                  ? Icons.lock_clock_rounded
                  : Icons.playlist_add_check_circle_rounded,
              size: 20,
              color: currentBalance > 0 ? AppColors.primary : AppColors.textSecondary,
            ),
            label: Text(
              currentBalance > 0
                  ? 'تقفيل الوردية وجرد النقدية وتسليم الدرج 🔒'
                  : 'جرد وتصفية الوردية / تسوية الدرج',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              AppHaptics.selection();
              onCloseShift();
            },
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_pay/app/theme/app_colors.dart';
import 'package:stream_pay/core/providers/erp_providers.dart';
import 'package:stream_pay/shared/widgets/app_modals.dart';

import '../widgets/cash_register/cash_summary_row.dart';
import '../widgets/cash_register/cash_quick_actions.dart';
import '../widgets/cash_register/cash_transactions_feed.dart';
import '../widgets/cash_register/expense_sheet.dart';
import '../widgets/cash_register/deposit_withdrawal_sheet.dart';
import '../widgets/cash_register/close_shift_sheet.dart';
import '../widgets/cash_register/shift_history_dialog.dart';

/// Redesigned, High-Protection Cash Register & Shifts Screen.
/// Built for crystal-clear clarity:
/// 1. 🟢 Total Inflow Today (sales & deposits)
/// 2. 🔴 Total Outflow Today (expenses & withdrawals)
/// 3. 💵 Net Cash in Drawer right now
/// With one-tap Expense recording, Float Deposit/Withdrawal, and Smart Shift Reconciliation.
class CashRegisterScreen extends ConsumerWidget {
  const CashRegisterScreen({super.key});

  Future<void> _refreshData(WidgetRef ref) async {
    AppHaptics.light();
    ref.invalidate(drawerBalanceProvider);
    ref.invalidate(dailyCashSummaryProvider);
    ref.invalidate(recentTransactionsProvider);
    ref.invalidate(shiftClosingsHistoryProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dailyCashSummaryProvider);
    final transactionsAsync = ref.watch(recentTransactionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'الخزينة وحساب الوردية',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
        ),
        centerTitle: true,
        actions: [
          // Previous Shift Audits Button
          IconButton(
            icon: const Icon(Icons.history_edu_rounded),
            tooltip: 'سجل إغلاق الورديات والجرد السابق',
            onPressed: () {
              AppHaptics.selection();
              ShiftHistoryDialog.show(context);
            },
          ),
          // Refresh Button
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'تحديث الحسابات',
            onPressed: () => _refreshData(ref),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          onRefresh: () => _refreshData(ref),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                children: [
                  // ─── 1. Core Cash Flow Pulse Cards (Inflow, Outflow, Drawer Net) ───
                  summaryAsync.when(
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (e, _) => Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              color: AppColors.error),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'خطأ في قراءة رصيد الخزينة: $e',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          TextButton(
                            onPressed: () => _refreshData(ref),
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    ),
                    data: (summary) => Column(
                      children: [
                        CashSummaryRow(summary: summary),
                        const SizedBox(height: 14),

                        // ─── 2. Routine Fast Actions (Expense, Deposit/Withdraw, Close Shift) ───
                        CashQuickActions(
                          currentBalance: summary.drawerBalance,
                          onExpense: () => ExpenseSheet.show(context),
                          onDepositWithdraw: () =>
                              DepositWithdrawalSheet.show(context),
                          onCloseShift: () => CloseShiftSheet.show(context),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ─── 3. Detailed Transaction Feed with Filters ───
                  transactionsAsync.when(
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (e, _) => Center(
                      child: Text('خطأ في تحميل الحركات: $e'),
                    ),
                    data: (transactions) => CashTransactionsFeed(
                      transactions: transactions,
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

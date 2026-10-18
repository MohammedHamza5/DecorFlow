import 'package:stream_pay/core/database/app_database.dart';
import 'package:drift/drift.dart';

/// Handles Cash Flow and Profitability based on CashTransactions and Expenses ledgers.
class CashFlowEngine {
  final ErpDatabase _db;

  CashFlowEngine(this._db);

  /// Records a cash movement into the central CashTransactions ledger.
  Future<void> recordTransaction({
    required double amount,
    required String type, // 'in', 'out'
    required String category, // 'customer_payment', 'supplier_payment', 'expense'
    int? referenceId,
    String paymentMethod = 'cash',
    String? notes,
  }) async {
    // Avoid recording non-positive (0 or negative) amounts
    if (amount <= 0) return;

    await _db.into(_db.cashTransactions).insert(
      CashTransactionsCompanion.insert(
        amount: amount,
        type: type,
        category: category,
        referenceId: Value(referenceId),
        paymentMethod: Value(paymentMethod),
        notes: Value(notes),
      ),
    );
  }

  /// Helper to record an expense specifically, tying it to the Expenses table and Cash flow.
  Future<void> recordExpense({
    required int categoryId,
    required double amount,
    String? notes,
  }) async {
    return _db.transaction(() async {
      // 1. Record specific expense
      final expenseId = await _db.into(_db.expenses).insert(
        ExpensesCompanion.insert(
          categoryId: categoryId,
          amount: amount,
          notes: Value(notes),
        ),
      );

      // 2. Record out flow
      await recordTransaction(
        amount: amount,
        type: 'out',
        category: 'expense',
        referenceId: expenseId,
        notes: notes,
      );
    });
  }

  /// Calculates the current exact drawer balance (Cash Flow).
  Future<double> getDrawerBalance() async {
    final transactions = await _db.select(_db.cashTransactions).get();
    
    double balance = 0.0;
    for (final t in transactions) {
      if (t.type == 'in') {
        balance += t.amount;
      } else if (t.type == 'out') {
        balance -= t.amount;
      }
    }
    
    return balance;
  }
  
  /// Calculates Real Net Profit for a given period (Cash Basis).
  Future<double> calculateNetProfit(DateTime start, DateTime end) async {
    // 1. Get Revenue (collected payments)
    final incomes = await (_db.select(_db.cashTransactions)
      ..where((t) => t.type.equals('in') & 
                     t.category.equals('customer_payment') &
                     t.createdAt.isBetweenValues(start, end)))
      .get();
      
    double totalRevenue = 0.0;
    for (final i in incomes) {
      totalRevenue += i.amount;
    }
    
    // Estimated COGS (Cost of Goods Sold) based on assumed 30% margin.
    // In a full implementation, we would trace the items sold and sum their `base_cost`.
    double cogs = totalRevenue * 0.70; 
    double grossProfit = totalRevenue - cogs;
    
    // 2. Subtract operational expenses
    final expenses = await (_db.select(_db.expenses)
      ..where((e) => e.createdAt.isBetweenValues(start, end)))
      .get();
      
    double totalExpenses = 0.0;
    for (final e in expenses) {
      totalExpenses += e.amount;
    }

    // 3. Subtract Technician Payouts (fee_earned is the cost to the shop)
    final techLedger = await (_db.select(_db.technicianLedger)
      ..where((t) => t.type.equals('fee_earned') & t.createdAt.isBetweenValues(start, end)))
      .get();
    
    double techCosts = 0.0;
    for (final t in techLedger) {
      techCosts += t.amount;
    }
    
    return grossProfit - totalExpenses - techCosts;
  }

  /// Close the shift: records the count, inserts a closing record, and resets the drawer.
  Future<int> closeShift({
    required String closedBy,
    required double actualCash,
    String? notes,
  }) async {
    return _db.transaction(() async {
      final expectedCash = await getDrawerBalance();
      final difference = actualCash - expectedCash;

      final shiftId = await _db.into(_db.shiftClosings).insert(
        ShiftClosingsCompanion.insert(
          closedBy: closedBy,
          expectedCash: expectedCash,
          actualCash: actualCash,
          difference: difference,
          notes: Value(notes),
        ),
      );

      // 1. If actual cash exists in hand, transfer it out of the drawer
      if (actualCash > 0) {
        await recordTransaction(
          type: 'out',
          amount: actualCash,
          category: 'shift_transfer',
          notes: 'تسليم عهدة الوردية $shiftId بواسطة $closedBy',
        );
      }

      // 2. Reconcile differences:
      if (expectedCash >= 0) {
        if (difference < 0) {
          // Real shortage: Expected > Actual
          await recordTransaction(
            type: 'out',
            amount: difference.abs(),
            category: 'shift_shortage',
            notes: 'عجز في الوردية $shiftId',
          );
        } else if (difference > 0) {
          // Real surplus: Actual > Expected when expected >= 0
          await recordTransaction(
            type: 'in',
            amount: difference,
            category: 'shift_surplus',
            notes: 'زيادة نقدية في الوردية $shiftId',
          );
        }
      } else {
        // Expected cash was negative (e.g. -1000 due to unbacked expenses).
        // This is an overdraft/deficit, NOT a surplus profit!
        // To reset the drawer to clean 0 for the next shift, record a settlement adjustment.
        final overdraftToClear = expectedCash.abs();
        await recordTransaction(
          type: 'in',
          amount: overdraftToClear,
          category: 'shift_settlement',
          notes: 'تسوية رصيد الدرج السالب وتصفير الوردية $shiftId',
        );
      }

      return shiftId;
    });
  }
}

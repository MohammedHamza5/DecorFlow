import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_pay/core/database/app_database.dart';
import 'package:stream_pay/engines/erp/inventory_engine.dart';
import 'package:stream_pay/engines/erp/cash_flow_engine.dart';
import 'package:stream_pay/engines/erp/technicians_engine.dart';
import 'package:drift/drift.dart';

// ─── Core ERP Engines ────────────────────────────────────────

final erpDatabaseProvider = Provider<ErpDatabase>((ref) {
  return ErpDatabase();
});

final inventoryEngineProvider = Provider<InventoryEngine>((ref) {
  final db = ref.watch(erpDatabaseProvider);
  return InventoryEngine(db);
});

final cashFlowEngineProvider = Provider<CashFlowEngine>((ref) {
  final db = ref.watch(erpDatabaseProvider);
  return CashFlowEngine(db);
});

// ─── Cash Register & Expenses ────────────────────────────────

/// Gets the real-time drawer balance
final drawerBalanceProvider = FutureProvider.autoDispose<double>((ref) async {
  final engine = ref.watch(cashFlowEngineProvider);
  return await engine.getDrawerBalance();
});

/// Gets the estimated net profit for the current month
final currentMonthNetProfitProvider = FutureProvider.autoDispose<double>((
  ref,
) async {
  final engine = ref.watch(cashFlowEngineProvider);
  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);
  return await engine.calculateNetProfit(startOfMonth, now);
});

/// Gets the recent cash transactions
final recentTransactionsProvider =
    FutureProvider.autoDispose<List<CashTransaction>>((ref) async {
      final db = ref.watch(erpDatabaseProvider);
      return await (db.select(db.cashTransactions)
            ..orderBy([
              (t) => OrderingTerm(
                expression: t.createdAt,
                mode: OrderingMode.desc,
              ),
            ])
            ..limit(50))
          .get();
    });

/// Summary of daily cash flows (Total In, Total Out, and current drawer balance)
class DailyCashSummary {
  final double totalIn;
  final double totalOut;
  final double drawerBalance;
  final double salesIn;
  final double expensesOut;
  final double depositsIn;
  final double withdrawalsOut;
  final int transactionsCount;

  const DailyCashSummary({
    required this.totalIn,
    required this.totalOut,
    required this.drawerBalance,
    required this.salesIn,
    required this.expensesOut,
    required this.depositsIn,
    required this.withdrawalsOut,
    required this.transactionsCount,
  });
}

/// Provider for today's comprehensive cash flow metrics
final dailyCashSummaryProvider =
    FutureProvider.autoDispose<DailyCashSummary>((ref) async {
  final db = ref.watch(erpDatabaseProvider);
  final engine = ref.watch(cashFlowEngineProvider);

  final now = DateTime.now();
  final startOfToday = DateTime(now.year, now.month, now.day);

  final todayTxQuery = db.select(db.cashTransactions)
    ..where((t) => t.createdAt.isBiggerOrEqualValue(startOfToday));
  final todayTransactions = await todayTxQuery.get();

  double totalIn = 0.0;
  double totalOut = 0.0;
  double salesIn = 0.0;
  double expensesOut = 0.0;
  double depositsIn = 0.0;
  double withdrawalsOut = 0.0;

  for (final t in todayTransactions) {
    if (t.type == 'in') {
      totalIn += t.amount;
      if (t.category == 'customer_payment') {
        salesIn += t.amount;
      } else if (t.category == 'drawer_deposit') {
        depositsIn += t.amount;
      }
    } else if (t.type == 'out') {
      totalOut += t.amount;
      if (t.category == 'expense') {
        expensesOut += t.amount;
      } else if (t.category == 'drawer_withdrawal') {
        withdrawalsOut += t.amount;
      }
    }
  }

  final drawerBalance = await engine.getDrawerBalance();

  return DailyCashSummary(
    totalIn: totalIn,
    totalOut: totalOut,
    drawerBalance: drawerBalance,
    salesIn: salesIn,
    expensesOut: expensesOut,
    depositsIn: depositsIn,
    withdrawalsOut: withdrawalsOut,
    transactionsCount: todayTransactions.length,
  );
});

/// Gets shift closings audit log
final shiftClosingsHistoryProvider =
    FutureProvider.autoDispose<List<ShiftClosing>>((ref) async {
  final db = ref.watch(erpDatabaseProvider);
  return await (db.select(db.shiftClosings)
        ..orderBy([
          (s) => OrderingTerm(
            expression: s.closedAt,
            mode: OrderingMode.desc,
          ),
        ])
        ..limit(30))
      .get();
});

/// Gets or creates expense categories
final expenseCategoriesProvider = FutureProvider<List<ExpenseCategory>>((
  ref,
) async {
  final db = ref.watch(erpDatabaseProvider);

  // Seed basic categories if empty
  var categories = await db.select(db.expenseCategories).get();
  if (categories.isEmpty) {
    final defaultCategories = [
      'إيجار',
      'كهرباء/مياه',
      'رواتب',
      'شحن ونقل',
      'إكراميات',
      'ضيافة',
      'أخرى',
    ];
    for (var cat in defaultCategories) {
      await db
          .into(db.expenseCategories)
          .insert(ExpenseCategoriesCompanion.insert(name: cat));
    }
    categories = await db.select(db.expenseCategories).get();
  }
  return categories;
});

// ─── Purchase Orders ─────────────────────────────────────────

/// Gets all purchase orders
final purchaseOrdersProvider = FutureProvider.autoDispose<List<PurchaseOrder>>((
  ref,
) async {
  final db = ref.watch(erpDatabaseProvider);
  return await (db.select(db.purchaseOrders)..orderBy([
        (p) => OrderingTerm(expression: p.createdAt, mode: OrderingMode.desc),
      ]))
      .get();
});

// --- Technicians & Installations -----------------------------

final techniciansEngineProvider = Provider<TechniciansEngine>((ref) {
  final db = ref.watch(erpDatabaseProvider);
  return TechniciansEngine(db);
});

/// Gets all technicians
final techniciansListProvider = FutureProvider.autoDispose<List<Technician>>((
  ref,
) async {
  final db = ref.watch(erpDatabaseProvider);
  return await (db.select(db.technicians)..orderBy([
        (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
      ]))
      .get();
});

/// Gets balance for a specific technician
final technicianBalanceProvider = FutureProvider.family
    .autoDispose<double, int>((ref, techId) async {
      final engine = ref.watch(techniciansEngineProvider);
      return await engine.getTechnicianBalance(techId);
    });

/// Gets installation jobs (pending and in progress)
final activeInstallationJobsProvider =
    FutureProvider.autoDispose<List<InstallationJob>>((ref) async {
      final db = ref.watch(erpDatabaseProvider);
      return await (db.select(db.installationJobs)
            ..where((j) => j.status.isNotIn(['completed', 'cancelled']))
            ..orderBy([
              (j) => OrderingTerm(
                expression: j.createdAt,
                mode: OrderingMode.desc,
              ),
            ]))
          .get();
    });

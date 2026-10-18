import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_pay/core/local_db/app_database.dart';
import 'package:stream_pay/core/providers/data_providers.dart';

class DashboardStats {
  final double totalSales;
  final double totalCollected;
  final double totalReceivables;
  final List<Map<String, dynamic>> recentActivity;

  DashboardStats({
    required this.totalSales,
    required this.totalCollected,
    required this.totalReceivables,
    required this.recentActivity,
  });
}

class DashboardRepository {
  final AppDatabase _db;

  DashboardRepository(this._db);

  Future<DashboardStats> getDashboardStats() async {
    // 1. Total Sales (from confirmed or paid invoices, excluding deleted ones)
    final salesQuery = _db.select(_db.localInvoices)
      ..where((tbl) => tbl.status.isNotIn(['draft']) & tbl.isDeleted.equals(false));
    final allInvoices = await salesQuery.get();
    
    double totalSales = 0.0;
    for (var inv in allInvoices) {
      totalSales += inv.totalAmount;
    }

    // 2. Total Collected (from payments, excluding deleted ones)
    final paymentsQuery = _db.select(_db.localPayments)
      ..where((tbl) => tbl.isDeleted.equals(false));
    final allPayments = await paymentsQuery.get();

    double totalCollected = 0.0;
    for (var pay in allPayments) {
      totalCollected += pay.amount;
    }

    // 3. Receivables
    final double totalReceivables = totalSales - totalCollected;

    // 4. Recent Activity (Last 5 non-draft invoices, excluding deleted ones)
    final recentInvoicesQuery = _db.select(_db.localInvoices)
      ..where((tbl) => tbl.status.isNotIn(['draft']) & tbl.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)])
      ..limit(5);
    final recentInvoices = await recentInvoicesQuery.get();

    final customers = await _db.select(_db.localCustomers).get();
    final customerMap = {for (var c in customers) c.id: c.name};

    final recentActivity = recentInvoices.map((inv) {
      return {
        'id': inv.id,
        'invoice_number': inv.invoiceNumber,
        'customer_name': customerMap[inv.customerId] ?? 'غير معروف',
        'total_amount': inv.totalAmount,
        'status': inv.status,
        'created_at': inv.createdAt.toIso8601String(),
      };
    }).toList();

    return DashboardStats(
      totalSales: totalSales,
      totalCollected: totalCollected,
      totalReceivables: totalReceivables > 0 ? totalReceivables : 0.0,
      recentActivity: recentActivity,
    );
  }
}

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return DashboardRepository(db);
});

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  // Optional: Listen to a generic "data changed" provider to refresh, 
  // but for now relying on pull-to-refresh or simple watch.
  return repo.getDashboardStats();
});

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_pay/app/theme/app_colors.dart';
import 'package:stream_pay/core/local_db/app_database.dart';
import 'package:stream_pay/core/providers/data_providers.dart';
import 'package:stream_pay/features/catalog/data/catalog_hub.dart';
import 'package:stream_pay/shared/widgets/app_modals.dart';

import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_stats_grid.dart';
import '../widgets/dashboard_quick_actions.dart';
import '../widgets/dashboard_counter_search.dart';
import '../widgets/dashboard_activity_section.dart';
import '../widgets/dashboard_shift_pulse_card.dart';
import '../widgets/dashboard_quick_tools_card.dart';
import '../widgets/dashboard_skeleton.dart';

/// Optimized Provider for dashboard operational and counter metrics.
/// Uses selective SQL indexing, limits, and aggregate count queries for maximum performance.
final geniusDashboardProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
      final appDb = ref.watch(appDatabaseProvider);
      final now = DateTime.now();
      final startOfToday = DateTime(now.year, now.month, now.day);

      // 1. Invoices today: count & total sales using indexed SQL WHERE
      final todayInvoicesQuery = appDb.select(appDb.localInvoices)
        ..where(
          (tbl) =>
              tbl.createdAt.isBiggerOrEqualValue(startOfToday) &
              tbl.status.isNotIn(['draft']) &
              tbl.isDeleted.equals(false),
        );
      final todayInvoices = await todayInvoicesQuery.get();

      int todayInvoicesCount = todayInvoices.length;
      double todaySalesTotal = 0.0;
      for (final inv in todayInvoices) {
        todaySalesTotal += inv.totalAmount;
      }

      // 2. Recent 5 invoices (newest first, not deleted)
      final recentInvoicesQuery = appDb.select(appDb.localInvoices)
        ..where((tbl) => tbl.isDeleted.equals(false))
        ..orderBy([
          (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
        ])
        ..limit(5);
      final recentInvoices = await recentInvoicesQuery.get();

      // 3. Selective customer map for recent invoices only
      final customerIds = recentInvoices
          .map((i) => i.customerId)
          .where((id) => id != null && id.isNotEmpty)
          .cast<String>()
          .toSet();
      final customerMap = <String, String>{};
      if (customerIds.isNotEmpty) {
        final custQuery = appDb.select(appDb.localCustomers)
          ..where((tbl) => tbl.id.isIn(customerIds));
        final customers = await custQuery.get();
        for (final c in customers) {
          customerMap[c.id] = c.name;
        }
      }

      // 4. Low stock items (limit 10 items)
      final inventoryQuery = appDb.select(appDb.localInventoryItems)
        ..where(
          (tbl) =>
              tbl.availableQty.isSmallerOrEqualValue(10) &
              tbl.availableQty.isBiggerOrEqualValue(0),
        )
        ..limit(10);
      final inventory = await inventoryQuery.get();

      final List<Map<String, dynamic>> lowStock = [];
      if (inventory.isNotEmpty) {
        final variantIds = inventory.map((i) => i.productVariantId).toSet();
        final variantsQuery = appDb.select(appDb.localProductVariants)
          ..where((tbl) => tbl.id.isIn(variantIds));
        final variants = await variantsQuery.get();

        final productIds = variants.map((v) => v.productId).toSet();
        final productsQuery = appDb.select(appDb.localProducts)
          ..where((tbl) => tbl.id.isIn(productIds));
        final products = await productsQuery.get();

        final pMap = {for (var p in products) p.id: p};
        final vMap = {for (var v in variants) v.id: v};

        for (final item in inventory) {
          final v = vMap[item.productVariantId];
          if (v != null) {
            final p = pMap[v.productId];
            if (p != null) {
              lowStock.add({
                'name': '${p.name} - ${v.variantName}',
                'qty': item.availableQty,
                'unit':
                    p.unitType != null && p.unitType!.isNotEmpty
                        ? p.unitType!
                        : 'لوح',
                'productId': p.id,
                'variantId': v.id,
              });
            }
          }
        }
      }

      // 5. Total active products count via SQL COUNT
      final productsCountExpr = appDb.localProducts.id.count();
      final productsCountQuery = appDb.selectOnly(appDb.localProducts)
        ..where(
          appDb.localProducts.isActive.equals(true) &
              appDb.localProducts.isDeleted.equals(false),
        )
        ..addColumns([productsCountExpr]);
      final totalProductsCount =
          await productsCountQuery
              .map((row) => row.read(productsCountExpr))
              .getSingleOrNull() ??
          0;

      // 6. Pending quotes count via SQL COUNT
      final quotesCountExpr = appDb.localQuotes.id.count();
      final quotesCountQuery = appDb.selectOnly(appDb.localQuotes)
        ..where(
          appDb.localQuotes.status.isIn(['draft', 'sent']) &
              appDb.localQuotes.isDeleted.equals(false),
        )
        ..addColumns([quotesCountExpr]);
      final pendingQuotesCount =
          await quotesCountQuery
              .map((row) => row.read(quotesCountExpr))
              .getSingleOrNull() ??
          0;

      return {
        'todayInvoicesCount': todayInvoicesCount,
        'todaySalesTotal': todaySalesTotal,
        'recentInvoices': recentInvoices,
        'customerMap': customerMap,
        'lowStock': lowStock,
        'totalProductsCount': totalProductsCount,
        'pendingQuotesCount': pendingQuotesCount,
      };
    });

/// Redesigned, High-Performance Dashboard Screen.
/// Built for maximum ease of use, speed, flexibility, and clean organization.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  Future<void> _refreshAll(WidgetRef ref) async {
    AppHaptics.light();
    ref.invalidate(geniusDashboardProvider);
    await ref.read(catalogHubProvider.notifier).load(forceRefresh: true);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(geniusDashboardProvider);
    final shopInfo = ref.watch(shopInfoProvider).value;
    final shopName = shopInfo?['name'] as String? ?? 'معرض السويدي للديكورات';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: statsAsync.when(
          loading: () => const DashboardSkeleton(),
          error:
              (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: AppColors.error,
                        size: 44,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'تعذر تحميل بيانات لوحة التحكم',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$e',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => _refreshAll(ref),
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                ),
              ),
          data:
              (stats) => RefreshIndicator(
                color: AppColors.primary,
                backgroundColor: AppColors.surface,
                onRefresh: () => _refreshAll(ref),
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  children: [
                    // 1. Full-Width Command Bar (Store Info + Privacy Eye + Drawer + Refresh)
                    DashboardHeader(
                      shopName: shopName,
                      onRefresh: () => _refreshAll(ref),
                    ),

                    const SizedBox(height: 16),

                    // 2. Full-Width Responsive KPI Stats Grid (4 expansive cards)
                    DashboardStatsGrid(stats: stats),

                    const SizedBox(height: 16),

                    // 3. Fluid Responsive Multi-Column Grid (Zero Dead Space!)
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        final recent =
                            stats['recentInvoices'] as List<LocalInvoice>? ??
                            [];
                        final customerMap =
                            stats['customerMap'] as Map<String, String>? ??
                            {};
                        final lowStock =
                            stats['lowStock'] as List<Map<String, dynamic>>? ??
                            [];

                        if (width >= 1200) {
                          // ─── 3-Column Desktop Grid (Full Canvas Utilization) ───
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Right Column (Operations & Live Invoices Stream) - 38%
                              Expanded(
                                flex: 38,
                                child: Column(
                                  children: [
                                    const DashboardQuickActions(),
                                    const SizedBox(height: 16),
                                    DashboardRecentInvoicesCard(
                                      recent: recent,
                                      customerMap: customerMap,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Center Column (Counter Price Lookup & Critical Shortages) - 34%
                              Expanded(
                                flex: 34,
                                child: Column(
                                  children: [
                                    const DashboardCounterSearch(),
                                    const SizedBox(height: 16),
                                    DashboardLowStockCard(lowStock: lowStock),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Left Column (Cashier Drawer Pulse & Showroom Tools) - 28%
                              const Expanded(
                                flex: 28,
                                child: Column(
                                  children: [
                                    DashboardShiftPulseCard(),
                                    SizedBox(height: 16),
                                    DashboardQuickToolsCard(),
                                  ],
                                ),
                              ),
                            ],
                          );
                        } else if (width >= 800) {
                          // ─── 2-Column Medium Screen Layout ───
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 6,
                                child: Column(
                                  children: [
                                    const DashboardQuickActions(),
                                    const SizedBox(height: 16),
                                    DashboardRecentInvoicesCard(
                                      recent: recent,
                                      customerMap: customerMap,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 5,
                                child: Column(
                                  children: [
                                    const DashboardShiftPulseCard(),
                                    const SizedBox(height: 16),
                                    const DashboardCounterSearch(),
                                    const SizedBox(height: 16),
                                    DashboardLowStockCard(lowStock: lowStock),
                                    const SizedBox(height: 16),
                                    const DashboardQuickToolsCard(),
                                  ],
                                ),
                              ),
                            ],
                          );
                        } else {
                          // ─── 1-Column Mobile / Narrow Screen Layout ───
                          return Column(
                            children: [
                              const DashboardQuickActions(),
                              const SizedBox(height: 14),
                              const DashboardShiftPulseCard(),
                              const SizedBox(height: 14),
                              const DashboardCounterSearch(),
                              const SizedBox(height: 14),
                              DashboardRecentInvoicesCard(
                                recent: recent,
                                customerMap: customerMap,
                              ),
                              const SizedBox(height: 14),
                              DashboardLowStockCard(lowStock: lowStock),
                              const SizedBox(height: 14),
                              const DashboardQuickToolsCard(),
                            ],
                          );
                        }
                      },
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
        ),
      ),
    );
  }
}

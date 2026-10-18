import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stream_pay/app/theme/app_colors.dart';
import 'package:stream_pay/core/providers/erp_providers.dart';
import 'package:stream_pay/core/database/app_database.dart';
import 'package:drift/drift.dart' as drift;
import 'package:stream_pay/core/responsive/constrained_body.dart';
import 'package:intl/intl.dart';

final purchasingHubProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final db = ref.watch(erpDatabaseProvider);

  // 1. Purchases This Month
  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);
  final pos = await db.select(db.purchaseOrders).get();
  double monthTotal = 0;
  for (var po in pos) {
    if (po.createdAt.isAfter(startOfMonth)) {
      monthTotal += po.totalAmount;
    }
  }

  // 2. Recent POs
  final recentPOs = await (db.select(db.purchaseOrders)
    ..orderBy([(t) => drift.OrderingTerm(expression: t.createdAt, mode: drift.OrderingMode.desc)])
    ..limit(5))
    .get();

  return {
    'monthTotal': monthTotal,
    'recentPOs': recentPOs,
  };
});

class PurchasingHubScreen extends ConsumerWidget {
  const PurchasingHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(purchasingHubProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('إدارة المشتريات والتسعير', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: false,
      ),
      body: ConstrainedBody(
        child: statsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text("خطأ: $e")),
          data: (stats) {
            final monthTotal = stats['monthTotal'] as double;
            final recentPOs = stats['recentPOs'] as List<PurchaseOrder>;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Highlight Stats
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.secondary, Color(0xFF0F766E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.inventory_2_rounded, color: Colors.white70, size: 28),
                          SizedBox(width: 8),
                          Text('مشتريات البضاعة (هذا الشهر)', style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        NumberFormat.currency(locale: 'ar_EG', symbol: 'ج.م').format(monthTotal),
                        style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  'غرفة العمليات',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                const SizedBox(height: 16),

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
                    _HubCard(
                      title: 'استلام بضاعة',
                      subtitle: 'إنشاء فاتورة مشتريات',
                      icon: Icons.add_shopping_cart_rounded,
                      color: AppColors.primary,
                      onTap: () => context.push('/purchase-orders'),
                    ),
                    _HubCard(
                      title: 'تسعير الكتالوج',
                      subtitle: 'إضافة منتجات وتعديل أسعار',
                      icon: Icons.price_change_rounded,
                      color: AppColors.success,
                      onTap: () => context.push('/product/add'),
                    ),
                    _HubCard(
                      title: 'الموردين',
                      subtitle: 'إدارة حسابات الموردين',
                      icon: Icons.storefront_rounded,
                      color: AppColors.warning,
                      onTap: () => context.push('/suppliers'),
                    ),
                    _HubCard(
                      title: 'تنبيهات النواقص',
                      subtitle: 'مراقبة المخزون',
                      icon: Icons.warning_amber_rounded,
                      color: AppColors.error,
                      onTap: () => context.push('/inventory'),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                if (recentPOs.isNotEmpty) ...[
                  const Text(
                    'أحدث فواتير المشتريات الواردة',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recentPOs.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final po = recentPOs[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.background,
                            child: const Icon(Icons.receipt_rounded, color: AppColors.primary, size: 20),
                          ),
                          title: Text('رقم الفاتورة: ${po.invoiceNumber ?? 'بدون'}', style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(DateFormat('yyyy-MM-dd').format(po.createdAt)),
                          trailing: Text(
                            NumberFormat.currency(locale: 'ar_EG', symbol: '').format(po.totalAmount),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ],
            );
          }
        ),
      ),
    );
  }
}

class _HubCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _HubCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

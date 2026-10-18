import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:stream_pay/app/theme/app_colors.dart';
import 'package:stream_pay/core/local_db/app_database.dart';
import 'package:stream_pay/shared/widgets/app_modals.dart';
import '../providers/dashboard_privacy_provider.dart';

/// Operational activity monitor: Recent Invoices & Critical Low Stock Alerts.
class DashboardActivitySection extends StatelessWidget {
  final Map<String, dynamic> stats;

  const DashboardActivitySection({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final recent = stats['recentInvoices'] as List<LocalInvoice>? ?? [];
    final customerMap = stats['customerMap'] as Map<String, String>? ?? {};
    final lowStock = stats['lowStock'] as List<Map<String, dynamic>>? ?? [];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 720;
        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: DashboardRecentInvoicesCard(
                  recent: recent,
                  customerMap: customerMap,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 4,
                child: DashboardLowStockCard(lowStock: lowStock),
              ),
            ],
          );
        } else {
          return Column(
            children: [
              DashboardRecentInvoicesCard(
                recent: recent,
                customerMap: customerMap,
              ),
              const SizedBox(height: 14),
              DashboardLowStockCard(lowStock: lowStock),
            ],
          );
        }
      },
    );
  }
}

/// Standalone card for Recent Invoices on the Dashboard.
class DashboardRecentInvoicesCard extends ConsumerWidget {
  final List<LocalInvoice> recent;
  final Map<String, String> customerMap;

  const DashboardRecentInvoicesCard({
    super.key,
    required this.recent,
    required this.customerMap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPrivacy = ref.watch(dashboardPrivacyProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.receipt_long_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'أحدث فواتير اليوم',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    AppHaptics.selection();
                    context.push('/invoices');
                  },
                  child: const Text('عرض الكل', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Invoices List or Empty
          if (recent.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_outlined,
                      size: 40,
                      color: AppColors.textTertiary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'لا توجد فواتير مسجلة اليوم حتى الآن',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ابدأ بيع جديد من زر POS أعلاه',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recent.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final inv = recent[index];
                final customerName =
                    customerMap[inv.customerId ?? ''] ?? 'عميل نقدي (كاش)';
                final isReturn = inv.invoiceType == 'return';
                final timeFmt =
                    DateFormat('hh:mm a', 'ar').format(inv.createdAt);

                final amountStr = isPrivacy
                    ? '•••••'
                    : '${NumberFormat('#,##0', 'ar').format(inv.totalAmount)} ج.م';

                return ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 3,
                  ),
                  onTap: () {
                    AppHaptics.selection();
                    context.push('/invoice/${inv.id}');
                  },
                  leading: CircleAvatar(
                    radius: 15,
                    backgroundColor: isReturn
                        ? AppColors.error.withValues(alpha: 0.12)
                        : AppColors.success.withValues(alpha: 0.12),
                    child: Icon(
                      isReturn
                          ? Icons.assignment_return_rounded
                          : Icons.receipt_long_rounded,
                      color: isReturn ? AppColors.error : AppColors.success,
                      size: 16,
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(
                        inv.invoiceNumber ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor(inv.status).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          _statusLabel(inv.status),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: _statusColor(inv.status),
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    '$customerName • $timeFmt',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        amountStr,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          color: isReturn ? AppColors.error : AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 11,
                        color: AppColors.textTertiary,
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'paid':
        return AppColors.success;
      case 'partial':
      case 'partially_paid':
        return const Color(0xFFF59E0B);
      case 'unpaid':
        return AppColors.error;
      case 'cancelled':
        return AppColors.textSecondary;
      default:
        return AppColors.primary;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return 'معتمدة';
      case 'paid':
        return 'مدفوعة';
      case 'partial':
      case 'partially_paid':
        return 'سداد جزئي';
      case 'unpaid':
        return 'آجل';
      case 'cancelled':
        return 'ملغاة';
      case 'draft':
        return 'مسودة';
      default:
        return status;
    }
  }
}

/// Standalone card for Critical Low Stock Alerts on the Dashboard.
class DashboardLowStockCard extends StatelessWidget {
  final List<Map<String, dynamic>> lowStock;

  const DashboardLowStockCard({super.key, required this.lowStock});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.error,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'نواقص المخزن (ألواح وخامات)',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    AppHaptics.selection();
                    context.push('/inventory');
                  },
                  child: const Text('المخزن', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // List or Empty
          if (lowStock.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
              child: Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 36,
                      color: AppColors.success,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'المخزون متوفر وممتاز 🟢',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'لا توجد خامات تحت حد الأمان',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: lowStock.length > 5 ? 5 : lowStock.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = lowStock[index];
                return ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 3,
                  ),
                  leading: CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.error.withValues(alpha: 0.12),
                    child: const Icon(
                      Icons.inventory_2_outlined,
                      color: AppColors.error,
                      size: 14,
                    ),
                  ),
                  title: Text(
                    item['name'] as String? ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'متبقي: ${item['qty']} ${item['unit']}',
                          style: const TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(
                          Icons.add_shopping_cart_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        tooltip: 'طلب توريد من المورد',
                        onPressed: () {
                          AppHaptics.selection();
                          context.push('/purchasing-hub');
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

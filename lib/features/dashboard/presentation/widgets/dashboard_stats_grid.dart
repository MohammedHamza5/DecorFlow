import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:stream_pay/app/theme/app_colors.dart';
import 'package:stream_pay/core/auth/providers/auth_state_provider.dart';
import 'package:stream_pay/core/auth/rbac/app_permissions.dart';
import 'package:stream_pay/shared/widgets/app_modals.dart';
import '../providers/dashboard_privacy_provider.dart';

/// Responsive KPI stats grid for the dashboard.
/// Displays today's invoices, sales total (with privacy masking), low stock count, and catalog count.
class DashboardStatsGrid extends ConsumerWidget {
  final Map<String, dynamic> stats;

  const DashboardStatsGrid({super.key, required this.stats});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPrivacy = ref.watch(dashboardPrivacyProvider);
    final userRole = ref.watch(currentUserRoleProvider);
    final canViewFinancials = userRole == AppRole.owner || userRole == AppRole.manager;

    final int todayInvoices = stats['todayInvoicesCount'] as int? ?? 0;
    final double todaySales = (stats['todaySalesTotal'] as num?)?.toDouble() ?? 0.0;
    final List<dynamic> lowStock = stats['lowStock'] as List<dynamic>? ?? [];
    final int totalProducts = stats['totalProductsCount'] as int? ?? 0;
    final int pendingQuotes = stats['pendingQuotesCount'] as int? ?? 0;

    final salesFormatted = isPrivacy
        ? '••••••'
        : '${NumberFormat('#,##0', 'ar').format(todaySales)} ج.م';

    final card1 = _StatCard(
      title: 'فواتير اليوم',
      value: '$todayInvoices فاتورة',
      subtitle: todayInvoices > 0 ? 'نشاط ممتاز اليوم' : 'لا توجد فواتير بعد',
      icon: Icons.receipt_long_rounded,
      accentColor: AppColors.success,
      onTap: () {
        AppHaptics.selection();
        context.push('/invoices');
      },
    );

    final card2 = canViewFinancials
        ? _StatCard(
            title: 'مبيعات اليوم',
            value: salesFormatted,
            subtitle: isPrivacy ? 'المبلغ مخفي للخصوصية' : 'إجمالي المبيعات المؤكدة',
            icon: Icons.monetization_on_rounded,
            accentColor: AppColors.primary,
            isPrivate: isPrivacy,
            onTap: () {
              AppHaptics.selection();
              context.push('/invoices');
            },
          )
        : _StatCard(
            title: 'عروض أسعار معلقة',
            value: '$pendingQuotes عرض',
            subtitle: 'بانتظار تأكيد العملاء',
            icon: Icons.description_rounded,
            accentColor: const Color(0xFFF59E0B),
            onTap: () {
              AppHaptics.selection();
              context.push('/quotes');
            },
          );

    final card3 = _StatCard(
      title: 'نواقص المخزن',
      value: lowStock.isNotEmpty ? '${lowStock.length} أصناف' : 'المخزون آمن',
      subtitle: lowStock.isNotEmpty ? 'أوشكت على النفاد (ألواح)' : 'لا توجد نواقص حرجة',
      icon: Icons.warning_amber_rounded,
      accentColor: lowStock.isNotEmpty ? AppColors.error : Colors.teal,
      hasAlert: lowStock.isNotEmpty,
      onTap: () {
        AppHaptics.selection();
        context.push('/inventory');
      },
    );

    final card4 = _StatCard(
      title: 'كتالوج المعرض',
      value: '$totalProducts صنف',
      subtitle: 'خامات وديكورات نشطة',
      icon: Icons.category_rounded,
      accentColor: const Color(0xFF6366F1),
      onTap: () {
        AppHaptics.selection();
        context.push('/catalog');
      },
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 760;

        if (isWide) {
          return Row(
            children: [
              Expanded(child: card1),
              const SizedBox(width: 10),
              Expanded(child: card2),
              const SizedBox(width: 10),
              Expanded(child: card3),
              const SizedBox(width: 10),
              Expanded(child: card4),
            ],
          );
        } else {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: card1),
                  const SizedBox(width: 10),
                  Expanded(child: card2),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: card3),
                  const SizedBox(width: 10),
                  Expanded(child: card4),
                ],
              ),
            ],
          );
        }
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final bool isPrivate;
  final bool hasAlert;
  final VoidCallback onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    this.isPrivate = false,
    this.hasAlert = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasAlert
                ? accentColor.withValues(alpha: 0.4)
                : AppColors.border.withValues(alpha: 0.6),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Row: Icon + Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: accentColor, size: 18),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Value
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: hasAlert ? accentColor : AppColors.textPrimary,
                letterSpacing: isPrivate ? 2 : 0,
              ),
            ),

            const SizedBox(height: 2),

            // Title & Subtitle
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

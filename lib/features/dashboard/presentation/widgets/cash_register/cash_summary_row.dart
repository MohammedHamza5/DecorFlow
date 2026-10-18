import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stream_pay/app/theme/app_colors.dart';
import 'package:stream_pay/core/providers/erp_providers.dart';

/// The 3 core cash pulse cards:
/// 1. 🟢 Total Inflow Today (مبيعات وإيداعات)
/// 2. 🔴 Total Outflow Today (مصاريف ومسحوبات)
/// 3. 💵 Net Cash In Drawer Right Now (صافي الفلوس بالدرج)
class CashSummaryRow extends StatelessWidget {
  final DailyCashSummary summary;

  const CashSummaryRow({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final currencyFmt = NumberFormat('#,##0', 'ar');

    final cardInflow = _SummaryCard(
      title: 'إجمالي الكاش الوارد اليوم',
      subtitle: '${currencyFmt.format(summary.salesIn)} ج.م مبيعات',
      value: '+${currencyFmt.format(summary.totalIn)} ج.م',
      icon: Icons.arrow_downward_rounded,
      color: AppColors.success,
      badgeText: 'وارد اليوم 🟢',
    );

    final cardOutflow = _SummaryCard(
      title: 'إجمالي المنصرف من الدرج',
      subtitle: '${currencyFmt.format(summary.expensesOut)} ج.م مصاريف',
      value: '-${currencyFmt.format(summary.totalOut)} ج.م',
      icon: Icons.arrow_upward_rounded,
      color: AppColors.error,
      badgeText: 'منصرف اليوم 🔴',
    );

    final isNegativeBalance = summary.drawerBalance < 0;
    final cardBalance = _SummaryCard(
      title: 'صافي الفلوس بالدرج الآن',
      subtitle: isNegativeBalance
          ? '⚠ رصيد سالب (مصروف بدون عهدة)'
          : 'الرصيد الدفتري الفعلي',
      value: '${currencyFmt.format(summary.drawerBalance)} ج.م',
      icon: Icons.account_balance_wallet_rounded,
      color: isNegativeBalance ? AppColors.error : AppColors.primary,
      isPrimary: true,
      badgeText: 'في الدرج الآن 💵',
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 720;
        if (isWide) {
          return Row(
            children: [
              Expanded(flex: 4, child: cardBalance),
              const SizedBox(width: 12),
              Expanded(flex: 3, child: cardInflow),
              const SizedBox(width: 12),
              Expanded(flex: 3, child: cardOutflow),
            ],
          );
        } else {
          return Column(
            children: [
              // Main Drawer Balance full width on mobile
              cardBalance,
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: cardInflow),
                  const SizedBox(width: 10),
                  Expanded(child: cardOutflow),
                ],
              ),
            ],
          );
        }
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final IconData icon;
  final Color color;
  final String badgeText;
  final bool isPrimary;

  const _SummaryCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.icon,
    required this.color,
    required this.badgeText,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPrimary
            ? color.withValues(alpha: 0.08)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isPrimary
              ? color.withValues(alpha: 0.35)
              : AppColors.border,
          width: isPrimary ? 1.5 : 1,
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badgeText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              CircleAvatar(
                radius: 14,
                backgroundColor: color.withValues(alpha: 0.12),
                child: Icon(icon, color: color, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isPrimary ? 22 : 18,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

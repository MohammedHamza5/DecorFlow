import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:stream_pay/app/theme/app_colors.dart';
import 'package:stream_pay/core/providers/erp_providers.dart';
import 'package:stream_pay/shared/widgets/app_modals.dart';
import '../providers/dashboard_privacy_provider.dart';

/// Compact Shift & Drawer status card for the dashboard side panel.
class DashboardShiftPulseCard extends ConsumerWidget {
  const DashboardShiftPulseCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPrivacy = ref.watch(dashboardPrivacyProvider);
    final summaryAsync = ref.watch(dailyCashSummaryProvider);

    final summary = summaryAsync.value;
    final drawerBal = summary?.drawerBalance ?? 0.0;
    final totalIn = summary?.totalIn ?? 0.0;
    final totalOut = summary?.totalOut ?? 0.0;

    final drawerFormatted = isPrivacy
        ? '••••••'
        : '${NumberFormat('#,##0', 'ar').format(drawerBal)} ج.م';

    return Container(
      padding: const EdgeInsets.all(14),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.point_of_sale_rounded,
                  color: AppColors.success,
                  size: 17,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'الخزينة والدرج اليوم',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              InkWell(
                onTap: () {
                  AppHaptics.selection();
                  context.push('/cash-register');
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'فتح الخزينة',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.primaryLight,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 11, color: AppColors.primaryLight),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border, width: 1.2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'النقدية بالدرج 💵',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        drawerFormatted,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: drawerBal >= 0 ? AppColors.successLight : AppColors.errorLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border, width: 1.2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'حركة اليوم (داخل / خارج)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            isPrivacy ? '•••' : '+${NumberFormat.compact(locale: 'ar').format(totalIn)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: AppColors.successLight,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isPrivacy ? '•••' : '-${NumberFormat.compact(locale: 'ar').format(totalOut)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: AppColors.errorLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

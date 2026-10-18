import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stream_pay/app/theme/app_colors.dart';
import 'package:stream_pay/app/theme/theme_provider.dart';
import 'package:stream_pay/shared/widgets/app_modals.dart';
import '../providers/dashboard_privacy_provider.dart';

/// Top header bar of the dashboard.
/// Displays shop branding, live counter status, and quick counter tools
/// (Privacy eye toggle, protected drawer shortcut, and refresh).
class DashboardHeader extends ConsumerWidget {
  final String shopName;
  final VoidCallback onRefresh;

  const DashboardHeader({
    super.key,
    required this.shopName,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPrivacyMode = ref.watch(dashboardPrivacyProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Store Branding Icon
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.storefront_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),

          // Store Name & Live Counter Status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  shopName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'كاونتر المبيعات نشط',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Action 1: Privacy Mode Toggle
          Tooltip(
            message: isPrivacyMode
                ? 'إلغاء وضع الخصوصية (إظهار المبالغ)'
                : 'تفعيل وضع الخصوصية (إخفاء المبالغ أمام الزبائن)',
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                AppHaptics.light();
                ref.read(dashboardPrivacyProvider.notifier).toggle();
                AppToast.showInfo(
                  context,
                  isPrivacyMode
                      ? 'تم إظهار المبالغ المالية'
                      : 'تم تفعيل وضع الخصوصية (إخفاء المبالغ)',
                );
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isPrivacyMode
                      ? AppColors.gold.withValues(alpha: 0.15)
                      : AppColors.surfaceVariant.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isPrivacyMode
                        ? AppColors.gold.withValues(alpha: 0.4)
                        : AppColors.border,
                  ),
                ),
                child: Icon(
                  isPrivacyMode
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  size: 18,
                  color: isPrivacyMode
                      ? AppColors.gold
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ),

          const SizedBox(width: 6),

          // Action 2: Protected Cash Register Drawer
          Tooltip(
            message: 'الخزينة والوردية (محمية)',
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                AppHaptics.selection();
                context.push('/cash-register');
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.teal.withValues(alpha: 0.3),
                  ),
                ),
                child: const Icon(
                  Icons.point_of_sale_rounded,
                  size: 18,
                  color: Colors.teal,
                ),
              ),
            ),
          ),

          const SizedBox(width: 6),

          // Action 3: Refresh Button
          Tooltip(
            message: 'تحديث البيانات الفوري',
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                AppHaptics.light();
                onRefresh();
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Icon(
                  Icons.refresh_rounded,
                  size: 18,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),

          const SizedBox(width: 6),

          // Action 4: Quick Theme Mode Switcher (☀️ / 🌙)
          Builder(
            builder: (context) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              return Tooltip(
                message: isDark
                    ? 'التحويل إلى الوضع الفاتح (النهاري) ☀️'
                    : 'التحويل إلى الوضع الداكن (الليلي) 🌙',
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    AppHaptics.medium();
                    ref.read(themeModeProvider.notifier).toggle();
                    AppToast.showSuccess(
                      context,
                      isDark
                          ? 'تم تفعيل الوضع الفاتح (النهاري) ☀️'
                          : 'تم تفعيل الوضع الداكن (الليلي) 🌙',
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF38BDF8).withValues(alpha: 0.15)
                          : const Color(0xFFF59E0B).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF38BDF8).withValues(alpha: 0.4)
                            : const Color(0xFFF59E0B).withValues(alpha: 0.4),
                      ),
                    ),
                    child: Icon(
                      isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                      size: 18,
                      color: isDark ? const Color(0xFF38BDF8) : const Color(0xFFD97706),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

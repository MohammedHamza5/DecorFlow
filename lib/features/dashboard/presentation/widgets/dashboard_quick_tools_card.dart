import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stream_pay/app/theme/app_colors.dart';
import 'package:stream_pay/shared/widgets/app_modals.dart';

/// Ergonomic Quick Tools & Direct Navigation Card for the Dashboard.
/// Provides direct 1-tap access to vital showroom utilities.
class DashboardQuickToolsCard extends StatelessWidget {
  const DashboardQuickToolsCard({super.key});

  @override
  Widget build(BuildContext context) {
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
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.grid_view_rounded,
                  color: Color(0xFF6366F1),
                  size: 17,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'أدوات الكاونتر والإدارة',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                'وصول مباشر',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Tools List
          _ToolTile(
            title: 'كشف الأسعار الفوري',
            subtitle: 'استعلام سريع عن تسعير الألواح والخامات للزبائن',
            icon: Icons.price_change_outlined,
            color: const Color(0xFF0284C7),
            onTap: () {
              AppHaptics.selection();
              context.push('/quick-price-board');
            },
          ),
          const SizedBox(height: 8),

          _ToolTile(
            title: 'توريد فاتورة مشتريات',
            subtitle: 'إدخال بضاعة من الموردين وتحديث رصيد المخزن',
            icon: Icons.add_business_outlined,
            color: const Color(0xFF10B981),
            onTap: () {
              AppHaptics.selection();
              context.push('/inventory/purchase-orders/new');
            },
          ),
          const SizedBox(height: 8),

          _ToolTile(
            title: 'كتالوج المعرض الشامل',
            subtitle: 'معاينة 172 صنف وتفاصيل المقاسات والألوان',
            icon: Icons.inventory_2_outlined,
            color: const Color(0xFF8B5CF6),
            onTap: () {
              AppHaptics.selection();
              context.push('/catalog');
            },
          ),
          const SizedBox(height: 8),

          _ToolTile(
            title: 'جرد ومطابقة المخزون',
            subtitle: 'متابعة حركات الوارد والمنصرف والتحويلات',
            icon: Icons.warehouse_outlined,
            color: const Color(0xFFF59E0B),
            onTap: () {
              AppHaptics.selection();
              context.push('/inventory');
            },
          ),
        ],
      ),
    );
  }
}

class _ToolTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ToolTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
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
      ),
    );
  }
}

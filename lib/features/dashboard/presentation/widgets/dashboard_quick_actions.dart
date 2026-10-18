import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stream_pay/app/theme/app_colors.dart';
import 'package:stream_pay/shared/widgets/app_modals.dart';

/// Clean, high-speed operations hub for the counter.
class DashboardQuickActions extends StatelessWidget {
  const DashboardQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'العمليات السريعة والبيع',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Text(
                'كاشير الكاونتر الفوري',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Primary Big Action Buttons (POS + Calculator)
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 460;
              final posButton = SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  icon: const Icon(Icons.flash_on_rounded, size: 20),
                  label: const Text(
                    'فاتورة بيع سريعة (POS) ⚡',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  onPressed: () {
                    AppHaptics.medium();
                    context.push('/smart-invoice');
                  },
                ),
              );

              final calcButton = SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                  icon: const Icon(Icons.calculate_rounded, size: 19),
                  label: const Text(
                    'حاسبة المقاسات والخامات 📐',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    AppHaptics.selection();
                    context.push('/calculator');
                  },
                ),
              );

              if (isWide) {
                return Row(
                  children: [
                    Expanded(flex: 6, child: posButton),
                    const SizedBox(width: 10),
                    Expanded(flex: 4, child: calcButton),
                  ],
                );
              } else {
                return Column(
                  children: [
                    SizedBox(width: double.infinity, child: posButton),
                    const SizedBox(height: 8),
                    SizedBox(width: double.infinity, child: calcButton),
                  ],
                );
              }
            },
          ),

          const SizedBox(height: 12),
          Divider(height: 1, color: AppColors.border.withValues(alpha: 0.5)),
          const SizedBox(height: 10),

          // Secondary Quick Operations (Compact, clean row of 4 shortcuts)
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 540;
              final items = [
                _QuickActionChip(
                  icon: Icons.description_outlined,
                  label: 'عرض أسعار جديد',
                  color: const Color(0xFF0284C7),
                  onTap: () {
                    AppHaptics.selection();
                    context.push('/quote-builder');
                  },
                ),
                _QuickActionChip(
                  icon: Icons.request_quote_outlined,
                  label: 'كشف الأسعار',
                  color: const Color(0xFFF59E0B),
                  onTap: () {
                    AppHaptics.selection();
                    context.push('/quick-price-board');
                  },
                ),
                _QuickActionChip(
                  icon: Icons.person_add_outlined,
                  label: 'إضافة عميل',
                  color: const Color(0xFF8B5CF6),
                  onTap: () => _showQuickAddCustomer(context),
                ),
                _QuickActionChip(
                  icon: Icons.warehouse_outlined,
                  label: 'جرد ونواقص',
                  color: const Color(0xFF10B981),
                  onTap: () {
                    AppHaptics.selection();
                    context.push('/inventory');
                  },
                ),
              ];

              if (isWide) {
                return Row(
                  children: items
                      .map((item) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: item,
                            ),
                          ))
                      .toList(),
                );
              } else {
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: items
                      .map((item) => SizedBox(
                            width: (constraints.maxWidth - 8) / 2,
                            child: item,
                          ))
                      .toList(),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _showQuickAddCustomer(BuildContext context) {
    AppHaptics.selection();
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.person_add_rounded, color: AppColors.primary, size: 22),
            SizedBox(width: 8),
            Text('إضافة عميل جديد سريع', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'اسم العميل / المهندس',
                hintText: 'مثال: م. أحمد السعيد',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'رقم الهاتف',
                hintText: '01xxxxxxxxx',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty) {
                AppToast.showError(context, 'يرجى إدخال اسم العميل');
                return;
              }
              Navigator.pop(ctx);
              AppToast.showSuccess(context, 'تمت إضافة العميل: ${nameCtrl.text.trim()}');
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.22)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

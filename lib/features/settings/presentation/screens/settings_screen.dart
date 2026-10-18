import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_pay/app/theme/app_colors.dart';
import 'package:stream_pay/app/theme/theme_provider.dart';

import 'package:stream_pay/features/auth/presentation/providers/auth_provider.dart';
import 'package:stream_pay/features/settings/presentation/screens/profile_screen.dart';
import 'package:stream_pay/core/auth/rbac/app_permissions.dart';
import 'package:stream_pay/core/auth/providers/auth_state_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream_pay/core/providers/supabase_providers.dart';
import 'package:stream_pay/core/providers/data_providers.dart';
import 'package:stream_pay/features/catalog/data/catalog_hub.dart';
import 'package:stream_pay/features/dashboard/data/dashboard_repository.dart';
import 'package:stream_pay/core/monitoring/action_tracker.dart';
import 'package:stream_pay/core/responsive/constrained_body.dart';
import 'package:stream_pay/core/constants/app_constants.dart';
import 'package:stream_pay/features/update/providers/update_providers.dart';
import 'package:stream_pay/features/update/providers/update_state.dart';

/// Settings screen — app configuration and management.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final fullName = user?.userMetadata?['full_name'] ?? 'مستخدم';
    final email = user?.email ?? '';
    final roleEnum = ref.watch(currentUserRoleProvider);
    final themeMode = ref.watch(currentThemeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
        actions: [
          _ThemeToggleButton(isDark: isDark),
          const SizedBox(width: 8),
        ],
      ),
      body: ConstrainedBody(
        child: ListView(
        children: [
          // Profile header
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.12),
                  AppColors.accent.withValues(alpha: 0.06),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  child: Text(
                    fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        email,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _roleLabel(roleEnum.name),
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: AppColors.primary,
                  ),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  ),
                ),
              ],
            ),
          ),
          _buildSection(context, 'الحساب', [
            _SettingItem(
              icon: Icons.person_outlined,
              title: 'الملف الشخصي',
              subtitle: 'الاسم والدور والصلاحيات',
              onTap: () => context.push('/profile'),
            ),
            if (RolePermissions.hasPermission(roleEnum, AppPermission.manageTeam))
              _SettingItem(
                icon: Icons.group_outlined,
                title: 'إدارة الفريق',
                subtitle: 'إدارة الموظفين والصلاحيات',
                onTap: () => context.push('/team-management'),
              ),
          ]),
          _buildSection(context, 'البيانات والمبيعات', [
            _SettingItem(
              icon: Icons.folder_outlined,
              title: 'المشاريع والتسعير',
              subtitle: 'إدارة طلبات وعروض أسعار العملاء',
              onTap: () => context.push('/projects'),
            ),
            if (RolePermissions.hasPermission(roleEnum, AppPermission.manageSuppliers))
              _SettingItem(
                icon: Icons.local_shipping_outlined,
                title: 'الموردون',
                subtitle: 'إدارة الموردين والأسعار',
                onTap: () => context.push('/suppliers'),
              ),
            if (RolePermissions.hasPermission(roleEnum, AppPermission.viewInvoices))
              _SettingItem(
                icon: Icons.receipt_long_outlined,
                title: 'الفواتير والتحصيلات',
                subtitle: 'سندات القبض ومتابعة الدفعات',
                onTap: () => context.push('/invoices'),
              ),
          ]),
          _buildSection(context, 'الميزات العبقرية (Premium)', [
            _SettingItem(
              icon: Icons.account_balance_wallet_outlined,
              title: 'محفظة الفنيين',
              subtitle: 'إدارة العمولات وحسابات المهندسين',
              onTap: () => context.push('/premium/wallet'),
            ),
            _SettingItem(
              icon: Icons.design_services_outlined,
              title: 'مستشار التصميم',
              subtitle: 'معرض التصاميم وحاسبة الخامات',
              onTap: () => context.push('/premium/design-advisor'),
            ),
            _SettingItem(
              icon: Icons.content_cut_outlined,
              title: 'مخطط التقطيع',
              subtitle: 'تخطيط تفادي الهدر في الألواح',
              onTap: () => context.push('/premium/cutting-optimizer'),
            ),
            _SettingItem(
              icon: Icons.radar_outlined,
              title: 'رادار النواقص',
              subtitle: 'تتبع المخزون وطلبات الشراء للموردين',
              onTap: () => context.push('/premium/restock-radar'),
            ),
          ]),
          _buildSection(context, 'التطبيق', [
            _SettingItem(
              icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              title: 'المظهر',
              subtitle: isDark ? 'الوضع الليلي مفعّل' : 'الوضع النهاري مفعّل',
              trailing: _ThemeToggleButton(isDark: isDark),
              onTap: () => ref.read(themeModeProvider.notifier).toggle(),
            ),
            _SettingItem(
              icon: Icons.system_update_alt_rounded,
              title: 'التحقق من وجود تحديثات',
              subtitle: 'فحص التحديثات الهوائية للبرنامج',
              onTap: () async {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('جاري البحث عن تحديثات...'),
                    duration: Duration(milliseconds: 1200),
                  ),
                );
                await ref.read(updateNotifierProvider.notifier).checkForUpdates();
                if (!context.mounted) return;
                final state = ref.read(updateNotifierProvider);
                if (state.status == UpdateStatus.noUpdate) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('أنت تستخدم أحدث إصدار بالفعل.'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
            ),
            _SettingItem(
              icon: Icons.info_outlined,
              title: 'عن التطبيق',
              subtitle: 'السويدي للديكور — الإصدار ${AppConstants.appVersion}',
              onTap: () => showAboutDialog(
                context: context,
                applicationName: 'السويدي للديكور',
                applicationVersion: AppConstants.appVersion,
                applicationLegalese: '© 2026 ElSweedy for Decoration',
              ),
            ),
            _SettingItem(
              icon: Icons.logout_outlined,
              title: 'تسجيل الخروج',
              subtitle: email,
              isDestructive: true,
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('تسجيل الخروج'),
                    content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('إلغاء'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.error,
                        ),
                        child: const Text('خروج'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  ref.read(authNotifierProvider.notifier).signOut();
                }
              },
            ),
          ]),
          if (roleEnum == AppRole.owner)
            _buildSection(context, 'منطقة الخطر', [
              _SettingItem(
                icon: Icons.delete_forever_outlined,
                title: 'تفريغ بيانات المحل',
                subtitle: 'حذف جميع بيانات المحل (المنتجات، الفواتير، التحصيلات، العملاء) سحابياً ومحلياً',
                isDestructive: true,
                onTap: () => _showResetDataDialog(context, ref),
              ),
            ]),
        ],
        ),
      ),
    );
  }

  void _showResetDataDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 28),
            SizedBox(width: 8),
            Text(
              'إعادة تعيين البيانات',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          'تحذير صارم: سيؤدي هذا الإجراء إلى مسح كافة المنتجات، الفواتير، المقبوضات، العملاء، والمخزون الخاص بمتجرك نهائياً من هذا الجهاز ومن السحابة.\n\nلا يمكن التراجع عن هذا الإجراء بعد تنفيذه. هل أنت متأكد من رغبتك في حذف كل هذه البيانات؟',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              // Delay execution of _performResetData to avoid frame/navigator collision
              Future.delayed(Duration.zero, () {
                if (context.mounted) {
                  _performResetData(context, ref);
                }
              });
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('نعم، احذف كل شيء', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _performResetData(BuildContext context, WidgetRef ref) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context, rootNavigator: true);

    // Show loading overlay using root navigator
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (ctx) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final supabase = ref.read(supabaseProvider);
      final shopId = ref.read(currentShopIdProvider);
      if (shopId == null) throw 'معرف المحل غير موجود';

      await ActionTracker.track(
        operationName: '[System] Reset All Shop Data',
        localAction: () async {
          // 1. Clear local Drift DB
          final db = ref.read(appDatabaseProvider);
          await db.clearAllData();

          // 2. Clear onboarding dismiss flag and last sync time
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('onboarding_dismissed_$shopId');
          await prefs.remove('last_sync_time');

          // 3. Clear repository memory caches so UI doesn't show old data
          ref.read(productRepositoryProvider).invalidateCache();
          ref.read(inventoryRepositoryProvider).invalidateCache();
        },
        cloudAction: () async {
          // 3. Clear all shop tables on Supabase
          await supabase.from('payments').delete().eq('shop_id', shopId);
          await supabase.from('invoices').delete().eq('shop_id', shopId);
          await supabase.from('quotes').delete().eq('shop_id', shopId);
          await supabase.from('inventory_items').delete().eq('shop_id', shopId);
          await supabase.from('customers').delete().eq('shop_id', shopId);
          await supabase.from('products').delete().eq('shop_id', shopId);
          await supabase.from('projects').delete().eq('shop_id', shopId);
        },
      );

      // Dismiss loading overlay FIRST to avoid locking the navigator during provider rebuilds
      if (navigator.mounted) {
        navigator.pop();
      }
      
      // Wait for the dialog pop animation to completely finish (typically ~300ms).
      // This prevents the '!_debugLocked' Navigator assertion error caused by
      // massive widget tree rebuilds occurring while a route is still animating.
      await Future.delayed(const Duration(milliseconds: 400));

      // 4. Invalidate Riverpod providers to refresh UI state safely
      ref.invalidate(isCatalogEmptyProvider);
      ref.invalidate(catalogHubProvider);
      ref.invalidate(categoriesProvider);
      ref.invalidate(dashboardStatsProvider);

      if (context.mounted) {
        context.go('/dashboard');
      }

      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('تم تفريغ كافة بيانات المحل بنجاح محلياً وسحابياً.'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      // Dismiss loading overlay if it's still open
      try {
        if (navigator.mounted) {
          navigator.pop();
        }
      } catch (_) {}

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء تفريغ البيانات: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  String _roleLabel(String role) {
    const map = {
      'admin': 'صاحب المحل / المدير',
      'owner': 'صاحب المحل',
      'seller': 'بائع',
      'technician': 'فني',
      'manager': 'مدير',
    };
    return map[role] ?? role;
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<_SettingItem> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(color: AppColors.primary),
          ),
        ),
        ...items.map(
          (item) => ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: item.isDestructive
                    ? AppColors.error.withValues(alpha: 0.12)
                    : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                item.icon,
                color: item.isDestructive ? AppColors.error : AppColors.primary,
                size: 20,
              ),
            ),
            title: Text(
              item.title,
              style: item.isDestructive
                  ? TextStyle(color: AppColors.error)
                  : null,
            ),
            subtitle: Text(
              item.subtitle,
              style: const TextStyle(fontSize: 12),
            ),
            trailing: item.trailing ?? const Icon(Icons.chevron_left, size: 20),
            onTap: item.onTap,
          ),
        ),
      ],
    );
  }
}

class _SettingItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;
  final Widget? trailing;

  const _SettingItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
    this.trailing,
  });
}

/// Animated moon/sun toggle button for theme switching.
class _ThemeToggleButton extends ConsumerWidget {
  final bool isDark;

  const _ThemeToggleButton({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, anim) => RotationTransition(
        turns: anim,
        child: FadeTransition(opacity: anim, child: child),
      ),
      child: IconButton(
        key: ValueKey(isDark),
        onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
        icon: Icon(
          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          color: isDark ? AppColors.primary : AppColors.textSecondary,
        ),
        tooltip: isDark ? 'تفعيل الوضع النهاري' : 'تفعيل الوضع الليلي',
      ),
    );
  }
}

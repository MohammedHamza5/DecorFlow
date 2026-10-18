import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_pay/app/theme/app_colors.dart';
import 'package:stream_pay/app/theme/theme_provider.dart';
import 'package:stream_pay/core/auth/providers/auth_state_provider.dart';
import 'package:stream_pay/core/auth/rbac/app_permissions.dart';
import 'package:stream_pay/core/responsive/app_responsive.dart';
import 'package:stream_pay/shared/widgets/app_modals.dart';

/// Main app shell with adaptive, high-UX desktop sidebar and mobile navigation.
///
/// - Mobile: Premium Bottom NavigationBar
/// - Tablet/Desktop: Modern, Collapsible, Multi-Section Navigation Sidebar with Quick POS Hub.
class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  List<_NavItem> _getNavItems(AppRole role) {
    final isSeller = role == AppRole.seller;
    return [
      // ─── قسم كاونتر المبيعات والعمليات ───
      const _NavItem(
        icon: Icons.dashboard_outlined,
        activeIcon: Icons.dashboard_rounded,
        label: 'الرئيسية والعمليات',
        path: '/dashboard',
        section: 'كاونتر المبيعات والعمليات',
        sectionColor: Color(0xFF10B981), // Emerald
      ),
      const _NavItem(
        icon: Icons.receipt_long_outlined,
        activeIcon: Icons.receipt_long_rounded,
        label: 'الفواتير والمبيعات',
        path: '/invoices',
        section: 'كاونتر المبيعات والعمليات',
        sectionColor: Color(0xFF10B981),
      ),
      const _NavItem(
        icon: Icons.description_outlined,
        activeIcon: Icons.description_rounded,
        label: 'عروض الأسعار',
        path: '/quotes',
        section: 'كاونتر المبيعات والعمليات',
        sectionColor: Color(0xFF10B981),
      ),
      const _NavItem(
        icon: Icons.calculate_outlined,
        activeIcon: Icons.calculate_rounded,
        label: 'حاسبة المقاسات والخامات',
        path: '/calculator',
        section: 'كاونتر المبيعات والعمليات',
        sectionColor: Color(0xFF10B981),
      ),

      // ─── قسم المعرض والمخزون والخزينة ───
      const _NavItem(
        icon: Icons.category_outlined,
        activeIcon: Icons.category_rounded,
        label: 'كتالوج وخامات المعرض',
        path: '/catalog',
        section: 'المعرض والمخزون والخزينة',
        sectionColor: Color(0xFFF59E0B), // Warm Amber
      ),
      if (!isSeller)
        const _NavItem(
          icon: Icons.warehouse_outlined,
          activeIcon: Icons.warehouse_rounded,
          label: 'المخزون والمشتريات',
          path: '/inventory',
          section: 'المعرض والمخزون والخزينة',
          sectionColor: Color(0xFFF59E0B),
        ),
      const _NavItem(
        icon: Icons.point_of_sale_outlined,
        activeIcon: Icons.point_of_sale_rounded,
        label: 'الخزينة وحركة الدرج',
        path: '/cash-register',
        section: 'المعرض والمخزون والخزينة',
        sectionColor: Color(0xFFF59E0B),
      ),

      // ─── قسم العملاء والمشاريع ───
      const _NavItem(
        icon: Icons.people_outline_rounded,
        activeIcon: Icons.people_rounded,
        label: 'العملاء والمهندسين',
        path: '/customers',
        section: 'العملاء والمشاريع',
        sectionColor: Color(0xFF6366F1), // Indigo
      ),
      const _NavItem(
        icon: Icons.architecture_rounded,
        activeIcon: Icons.architecture_rounded,
        label: 'المشاريع والمقايسات',
        path: '/projects',
        section: 'العملاء والمشاريع',
        sectionColor: Color(0xFF6366F1),
      ),

      // ─── قسم النظام والإعدادات ───
      const _NavItem(
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings_rounded,
        label: 'إعدادات النظام',
        path: '/settings',
        section: 'النظام والإعدادات',
        sectionColor: Color(0xFF8B5CF6), // Purple
      ),
    ];
  }

  int _currentIndex(BuildContext context, List<_NavItem> items) {
    final location = GoRouterState.of(context).uri.path;
    for (int i = 0; i < items.length; i++) {
      if (location == items[i].path) return i;
    }

    // Smart route mapping for sub-screens:
    if (location.startsWith('/smart-invoice') || location.startsWith('/invoice')) {
      final idx = items.indexWhere((it) => it.path == '/invoices');
      if (idx != -1) return idx;
    }
    if (location.startsWith('/quote')) {
      final idx = items.indexWhere((it) => it.path == '/quotes');
      if (idx != -1) return idx;
    }
    if (location.startsWith('/product') ||
        location.startsWith('/category') ||
        location.startsWith('/price-list') ||
        location.startsWith('/quick-price-board')) {
      final idx = items.indexWhere((it) => it.path == '/catalog');
      if (idx != -1) return idx;
    }
    if (location.startsWith('/purchase') ||
        location.startsWith('/purchasing') ||
        location.startsWith('/stock-adjustment') ||
        location.startsWith('/inventory')) {
      final idx = items.indexWhere((it) => it.path == '/inventory');
      if (idx != -1) return idx;
    }
    if (location.startsWith('/customer')) {
      final idx = items.indexWhere((it) => it.path == '/customers');
      if (idx != -1) return idx;
    }
    if (location.startsWith('/project') || location.startsWith('/measurement')) {
      final idx = items.indexWhere((it) => it.path == '/projects');
      if (idx != -1) return idx;
    }
    if (location.startsWith('/team') ||
        location.startsWith('/suppliers') ||
        location.startsWith('/profile') ||
        location.startsWith('/technicians') ||
        location.startsWith('/settings')) {
      final idx = items.indexWhere((it) => it.path == '/settings');
      if (idx != -1) return idx;
    }
    if (location.startsWith('/cash-register')) {
      final idx = items.indexWhere((it) => it.path == '/cash-register');
      if (idx != -1) return idx;
    }

    for (int i = 0; i < items.length; i++) {
      if (location.startsWith(items[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    if (profileAsync.isLoading && !profileAsync.hasValue) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final role = ref.watch(currentUserRoleProvider);
    final navItems = _getNavItems(role);
    final currentIndex = _currentIndex(context, navItems);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: isDark
            ? AppColors.darkNavBar
            : AppColors.surface,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      ),
    );

    return ResponsiveBuilder(
      builder: (context, info) {
        if (info.isDesktop) {
          return _DesktopShell(
            navItems: navItems,
            currentIndex: currentIndex,
            isDark: isDark,
            onDestinationSelected: (index) {
              if (index != currentIndex) {
                AppHaptics.selection();
                context.go(navItems[index].path);
              }
            },
            child: child,
          );
        }

        // Mobile / Tablet: bottom nav with core items
        final mobileItems = navItems.where((i) {
          return i.path == '/dashboard' ||
              i.path == '/invoices' ||
              i.path == '/calculator' ||
              i.path == '/catalog' ||
              i.path == '/settings';
        }).toList();

        final mobileCurrentIndex = _currentIndex(context, mobileItems);
        final location = GoRouterState.of(context).uri.path;
        final isRootMobile = mobileItems.any((i) => i.path == location);

        return Scaffold(
          body: child,
          bottomNavigationBar: isRootMobile
              ? _PremiumNavBar(
                  navItems: mobileItems,
                  currentIndex: mobileCurrentIndex,
                  isDark: isDark,
                  onDestinationSelected: (index) {
                    if (index != mobileCurrentIndex) {
                      AppHaptics.selection();
                      context.go(mobileItems[index].path);
                    }
                  },
                )
              : null,
        );
      },
    );
  }
}

/// Advanced, Collapsible Desktop Sidebar with high-performance UX ergonomics.
class _DesktopShell extends ConsumerStatefulWidget {
  final List<_NavItem> navItems;
  final int currentIndex;
  final bool isDark;
  final Widget child;
  final ValueChanged<int> onDestinationSelected;

  const _DesktopShell({
    required this.navItems,
    required this.currentIndex,
    required this.isDark,
    required this.child,
    required this.onDestinationSelected,
  });

  @override
  ConsumerState<_DesktopShell> createState() => _DesktopShellState();
}

class _DesktopShellState extends ConsumerState<_DesktopShell> {
  bool _isExtended = true;

  @override
  Widget build(BuildContext context) {
    final railBg = widget.isDark ? AppColors.darkNavBar : AppColors.surface;
    final borderColor = widget.isDark
        ? AppColors.darkBorder
        : AppColors.border.withValues(alpha: 0.4);

    final profile = ref.watch(userProfileProvider).value;
    final fullName = profile?['full_name'] as String? ?? 'كاشير المعرض';
    final role = ref.watch(currentUserRoleProvider);
    final roleLabel = role == AppRole.owner
        ? 'المالك'
        : (role == AppRole.manager ? 'مدير المعرض' : 'كاشير');

    final double sidebarWidth = _isExtended ? 270 : 76;

    return Scaffold(
      body: Row(
        children: [
          // ─── Custom Responsive Sidebar ───
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOutCubic,
            width: sidebarWidth,
            decoration: BoxDecoration(
              color: railBg,
              border: Border(left: BorderSide(color: borderColor, width: 1)),
              boxShadow: widget.isDark
                  ? []
                  : [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.03),
                        blurRadius: 16,
                        offset: const Offset(-4, 0),
                      ),
                    ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Sidebar Header (Brand + Collapse/Expand Toggle)
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: _isExtended ? 14 : 10,
                  ),
                  child: Row(
                    mainAxisAlignment: _isExtended
                        ? MainAxisAlignment.spaceBetween
                        : MainAxisAlignment.center,
                    children: [
                      // Brand Avatar + Title
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.primaryDark,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.35,
                                  ),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.storefront_rounded,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                          if (_isExtended) ...[
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'معرض السويدي',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  'للديكورات والتشطيبات',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),

                      // Collapse Toggle Button
                      if (_isExtended)
                        IconButton(
                          icon: const Icon(Icons.menu_open_rounded, size: 20),
                          color: AppColors.textSecondary,
                          tooltip: 'تصغير الشريط الجانبي',
                          onPressed: () {
                            AppHaptics.light();
                            setState(() => _isExtended = false);
                          },
                        ),
                    ],
                  ),
                ),

                // Expand button when collapsed
                if (!_isExtended)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Center(
                      child: IconButton(
                        icon: const Icon(Icons.menu_rounded, size: 20),
                        color: AppColors.textSecondary,
                        tooltip: 'توسيع القائمة الجانبية',
                        onPressed: () {
                          AppHaptics.light();
                          setState(() => _isExtended = true);
                        },
                      ),
                    ),
                  ),

                // 2. Direct Hero Action: Quick POS Sale Button
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: _isExtended ? 14 : 10,
                    vertical: 6,
                  ),
                  child: _isExtended
                      ? Container(
                          height: 46,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF059669),
                                Color(0xFF10B981),
                              ],
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                            ),
                            borderRadius: BorderRadius.circular(13),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF059669).withValues(alpha: 0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(13),
                              onTap: () {
                                AppHaptics.medium();
                                context.push('/smart-invoice');
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 14),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.flash_on_rounded, size: 20, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text(
                                      'فاتورة بيع سريعة (POS)',
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      : Tooltip(
                          message: 'فاتورة بيع سريعة (POS) ⚡',
                          waitDuration: const Duration(milliseconds: 150),
                          child: InkWell(
                            onTap: () {
                              AppHaptics.medium();
                              context.push('/smart-invoice');
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              height: 44,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF059669),
                                    Color(0xFF10B981),
                                  ],
                                  begin: Alignment.topRight,
                                  end: Alignment.bottomLeft,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF059669).withValues(alpha: 0.35),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.flash_on_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                ),

                const SizedBox(height: 10),
                Divider(height: 1, color: borderColor.withValues(alpha: 0.5)),
                const SizedBox(height: 6),

                // 3. Navigation Items List (Categorized with Section Titles)
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: _isExtended ? 12 : 8,
                      vertical: 6,
                    ),
                    itemCount: widget.navItems.length,
                    itemBuilder: (context, index) {
                      final item = widget.navItems[index];
                      final isSelected = widget.currentIndex == index;

                      // Check if we should render a section header
                      final showSectionHeader =
                          _isExtended &&
                          (index == 0 ||
                              item.section !=
                                  widget.navItems[index - 1].section);

                      // Divider for collapsed mode
                      final showCollapsedDivider =
                          !_isExtended &&
                          index > 0 &&
                          item.section != widget.navItems[index - 1].section;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showSectionHeader && item.section != null) ...[
                            Padding(
                              padding: EdgeInsets.only(
                                right: 10,
                                left: 10,
                                top: index == 0 ? 10 : 22,
                                bottom: 10,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      color: item.sectionColor ?? AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    item.section!,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w900,
                                      color: widget.isDark
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFF64748B),
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Divider(
                                      height: 1,
                                      thickness: 0.8,
                                      color: borderColor.withValues(alpha: 0.35),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          if (showCollapsedDivider)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 10,
                              ),
                              child: Divider(
                                height: 1,
                                color: borderColor.withValues(alpha: 0.5),
                              ),
                            ),
                          _SidebarItem(
                            item: item,
                            isSelected: isSelected,
                            isExtended: _isExtended,
                            isDark: widget.isDark,
                            onTap: () => widget.onDestinationSelected(index),
                          ),
                          const SizedBox(height: 7),
                        ],
                      );
                    },
                  ),
                ),

                // Theme Mode Switcher
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: _isExtended ? 12 : 8,
                    vertical: 4,
                  ),
                  child: _isExtended
                      ? InkWell(
                          onTap: () {
                            AppHaptics.medium();
                            ref.read(themeModeProvider.notifier).toggle();
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                            decoration: BoxDecoration(
                              color: widget.isDark
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: widget.isDark
                                    ? AppColors.darkBorderMid
                                    : AppColors.border,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      widget.isDark
                                          ? Icons.dark_mode_rounded
                                          : Icons.light_mode_rounded,
                                      size: 16,
                                      color: widget.isDark
                                          ? const Color(0xFF38BDF8)
                                          : const Color(0xFFF59E0B),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      widget.isDark ? 'الوضع الداكن' : 'الوضع الفاتح',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: widget.isDark
                                            ? Colors.white
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: widget.isDark
                                        ? const Color(0xFF38BDF8).withValues(alpha: 0.15)
                                        : const Color(0xFFF59E0B).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    widget.isDark ? 'تبديل للنهاري ☀️' : 'تبديل لليلي 🌙',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: widget.isDark
                                          ? const Color(0xFF38BDF8)
                                          : const Color(0xFFD97706),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Tooltip(
                          message: widget.isDark
                              ? 'التحويل للوضع الفاتح ☀️'
                              : 'التحويل للوضع الداكن 🌙',
                          child: Center(
                            child: IconButton(
                              icon: Icon(
                                widget.isDark
                                    ? Icons.light_mode_rounded
                                    : Icons.dark_mode_rounded,
                                size: 18,
                                color: widget.isDark
                                    ? const Color(0xFFF59E0B)
                                    : const Color(0xFF38BDF8),
                              ),
                              onPressed: () {
                                AppHaptics.medium();
                                ref.read(themeModeProvider.notifier).toggle();
                              },
                            ),
                          ),
                        ),
                ),

                // 4. Sidebar Footer (Cashier Status & Profile)
                Divider(height: 1, color: borderColor.withValues(alpha: 0.5)),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: _isExtended ? 14 : 10,
                    vertical: 12,
                  ),
                  child: _isExtended
                      ? Row(
                          children: [
                            CircleAvatar(
                              radius: 17,
                              backgroundColor: AppColors.primary.withValues(
                                alpha: 0.15,
                              ),
                              child: Text(
                                fullName.isNotEmpty ? fullName[0] : 'ك',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    fullName,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: AppColors.success,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        roleLabel,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Tooltip(
                              message: 'الإعدادات',
                              child: IconButton(
                                icon: const Icon(Icons.tune_rounded, size: 17),
                                color: AppColors.textTertiary,
                                onPressed: () {
                                  AppHaptics.selection();
                                  context.push('/settings');
                                },
                              ),
                            ),
                          ],
                        )
                      : Tooltip(
                          message: '$fullName • $roleLabel (متصل 🟢)',
                          waitDuration: const Duration(milliseconds: 150),
                          child: Center(
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: AppColors.primary.withValues(
                                alpha: 0.15,
                              ),
                              child: Text(
                                fullName.isNotEmpty ? fullName[0] : 'ك',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),

          // ─── Main Screen Content ───
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatefulWidget {
  final _NavItem item;
  final bool isSelected;
  final bool isExtended;
  final bool isDark;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.item,
    required this.isSelected,
    required this.isExtended,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary;
    final textSelected = primary;
    final textUnselected = widget.isDark
        ? const Color(0xFFF1F5F9) // Clear, high-contrast, bold Slate 100
        : const Color(0xFF1E293B); // Bold Slate 800

    final bgSelected = primary.withValues(alpha: widget.isDark ? 0.16 : 0.10);
    final bgHover = primary.withValues(alpha: widget.isDark ? 0.08 : 0.05);

    final content = MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            vertical: 12,
            horizontal: widget.isExtended ? 14 : 0,
          ),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? bgSelected
                : (_isHovering ? bgHover : Colors.transparent),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: widget.isSelected
                  ? primary.withValues(alpha: widget.isDark ? 0.4 : 0.25)
                  : (_isHovering
                      ? primary.withValues(alpha: 0.15)
                      : Colors.transparent),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisAlignment: widget.isExtended
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              // Active Pill Indicator on Right edge in RTL
              if (widget.isSelected && widget.isExtended)
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withValues(alpha: 0.5),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              if (widget.isSelected && widget.isExtended)
                const SizedBox(width: 8),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: Icon(
                  widget.isSelected ? widget.item.activeIcon : widget.item.icon,
                  key: ValueKey(widget.isSelected),
                  color: widget.isSelected ? textSelected : textUnselected,
                  size: 22,
                ),
              ),

              if (widget.isExtended) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.item.label,
                    style: TextStyle(
                      color: widget.isSelected ? textSelected : textUnselected,
                      fontWeight: widget.isSelected
                          ? FontWeight.w900
                          : FontWeight.w800, // Extra bold font
                      fontSize: 14,
                      letterSpacing: 0.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    if (!widget.isExtended) {
      return Tooltip(
        message: widget.item.label,
        waitDuration: const Duration(milliseconds: 150),
        preferBelow: false,
        child: content,
      );
    }

    return content;
  }
}

/// Bottom navigation bar for mobile.
class _PremiumNavBar extends StatelessWidget {
  final List<_NavItem> navItems;
  final int currentIndex;
  final bool isDark;
  final ValueChanged<int> onDestinationSelected;

  const _PremiumNavBar({
    required this.navItems,
    required this.currentIndex,
    required this.isDark,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkNavBar : AppColors.surface,
        border: Border(
          top: BorderSide(
            color: isDark
                ? AppColors.darkBorder
                : AppColors.border.withValues(alpha: 0.6),
            width: 1,
          ),
        ),
      ),
      child: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: navItems
            .map(
              (item) => NavigationDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.activeIcon),
                label: item.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String path;
  final String? section;
  final Color? sectionColor;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.path,
    this.section,
    this.sectionColor,
  });
}

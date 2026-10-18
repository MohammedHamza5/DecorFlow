import 'package:flutter/material.dart';

/// Breakpoint constants for the app's responsive system.
class AppBreakpoints {
  AppBreakpoints._();

  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;

  /// Max content width for centered content on large screens.
  static const double maxContentWidth = 720;

  /// Max content width for forms and narrow content.
  static const double maxFormWidth = 560;
}

/// Responsive information about the current screen size.
class ResponsiveInfo {
  final double width;
  final double height;

  const ResponsiveInfo({required this.width, required this.height});

  bool get isMobile => width < AppBreakpoints.mobile;
  bool get isTablet => width >= AppBreakpoints.mobile && width < AppBreakpoints.tablet;
  bool get isDesktop => width >= AppBreakpoints.tablet;
  bool get isLargeDesktop => width >= AppBreakpoints.desktop;

  /// Number of columns for grid layouts.
  int get gridColumns {
    if (isLargeDesktop) return 4;
    if (isDesktop) return 3;
    if (isTablet) return 2;
    return 2; // mobile: 2 cols for product grids
  }

  /// Number of columns for list-style cards.
  int get cardColumns {
    if (isDesktop) return 2;
    return 1;
  }

  /// Horizontal padding for screen content.
  double get horizontalPadding {
    if (isDesktop) return 24;
    if (isTablet) return 20;
    return 16;
  }
}

/// A widget that builds its child based on the current screen size.
/// 
/// Usage:
/// ```dart
/// ResponsiveBuilder(
///   builder: (context, info) {
///     if (info.isDesktop) return DesktopLayout();
///     return MobileLayout();
///   },
/// )
/// ```
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ResponsiveInfo info) builder;

  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final info = ResponsiveInfo(
          width: constraints.maxWidth,
          height: MediaQuery.sizeOf(context).height,
        );
        return builder(context, info);
      },
    );
  }
}

/// Extension on BuildContext for quick responsive checks.
extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  bool get isMobile => screenWidth < AppBreakpoints.mobile;
  bool get isTablet => screenWidth >= AppBreakpoints.mobile && screenWidth < AppBreakpoints.tablet;
  bool get isDesktop => screenWidth >= AppBreakpoints.tablet;

  double get horizontalPadding {
    if (isDesktop) return 24;
    if (isTablet) return 20;
    return 16;
  }
}

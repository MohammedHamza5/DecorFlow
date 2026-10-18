import 'package:flutter/material.dart';
import 'app_responsive.dart';

/// A widget that constrains and centers its child content on large screens.
///
/// On mobile: renders the child as-is with standard padding.
/// On tablet/desktop: wraps child in a centered container with max width.
///
/// Usage:
/// ```dart
/// Scaffold(
///   body: ConstrainedBody(
///     child: ListView(...),
///   ),
/// )
/// ```
class ConstrainedBody extends StatelessWidget {
  final Widget child;

  /// Max width for the content. Defaults to [AppBreakpoints.maxContentWidth].
  final double? maxWidth;

  /// Extra padding to apply around the content on all screen sizes.
  final EdgeInsetsGeometry? padding;

  const ConstrainedBody({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, info) {
        if (info.isMobile) {
          // On mobile, just add standard horizontal padding if needed
          if (padding != null) {
            return Padding(padding: padding!, child: child);
          }
          return child;
        }

        // On tablet/desktop, constrain only if it's explicitly a form or smaller width
        if (maxWidth != null && maxWidth != AppBreakpoints.maxContentWidth) {
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth!),
              child: padding != null
                  ? Padding(padding: padding!, child: child)
                  : child,
            ),
          );
        }

        // Otherwise, allow full width native desktop layout
        if (padding != null) {
          return Padding(padding: padding!, child: child);
        }
        return child;
      },
    );
  }
}

/// A constrained body specifically for forms.
/// Uses a narrower max width (maxFormWidth) for better readability.
class ConstrainedForm extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const ConstrainedForm({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBody(
      maxWidth: AppBreakpoints.maxFormWidth,
      padding: padding,
      child: child,
    );
  }
}

/// A responsive padding widget that adjusts horizontal padding based on screen size.
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final double? vertical;

  const ResponsivePadding({super.key, required this.child, this.vertical});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.horizontalPadding,
        vertical: vertical ?? 0,
      ),
      child: child,
    );
  }
}

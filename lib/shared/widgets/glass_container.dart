import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:stream_pay/app/theme/app_colors.dart';

/// A sleek glassmorphism container for modern, premium UI elements.
///
/// Automatically adapts between light and dark modes.
/// Dark: warm amber-tinted glass on deep charcoal
/// Light: white-tinted glass with soft shadow
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final Color? color;
  final BorderRadius? borderRadius;
  final Border? border;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool useTheme;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 12.0,
    this.color,
    this.borderRadius,
    this.border,
    this.padding,
    this.margin,
    this.useTheme = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final effectiveColor = color ??
        (isDark
            ? AppColors.darkSurface.withValues(alpha: 0.7)
            : Colors.white.withValues(alpha: 0.75));

    final effectiveBorder = border ??
        Border.all(
          color: isDark
              ? AppColors.darkBorderMid.withValues(alpha: 0.6)
              : Colors.white.withValues(alpha: 0.4),
          width: 1,
        );

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: effectiveColor,
              borderRadius: borderRadius,
              border: effectiveBorder,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// An amber-tinted glass surface — used for highlighted/featured cards in dark mode.
class AmberGlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final double blur;

  const AmberGlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.blur = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassContainer(
      blur: blur,
      padding: padding,
      margin: margin,
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      color: isDark
          ? AppColors.primarySurfaceDark.withValues(alpha: 0.5)
          : AppColors.primarySurface.withValues(alpha: 0.8),
      border: Border.all(
        color: isDark
            ? AppColors.primary.withValues(alpha: 0.2)
            : AppColors.primary.withValues(alpha: 0.15),
        width: 1,
      ),
      child: child,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:stream_pay/app/theme/app_colors.dart';

/// Centralized Haptic Feedback Manager
class AppHaptics {
  AppHaptics._();

  static void selection() {
    HapticFeedback.selectionClick();
  }

  static void light() {
    HapticFeedback.lightImpact();
  }

  static void medium() {
    HapticFeedback.mediumImpact();
  }

  static void success() {
    HapticFeedback.mediumImpact();
  }

  static void error() {
    HapticFeedback.heavyImpact();
  }
}

/// Floating modern toast alerts with haptic feedback
class AppToast {
  AppToast._();

  static void showSuccess(BuildContext context, String message) {
    AppHaptics.success();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Cairo', fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static void showError(BuildContext context, String message) {
    AppHaptics.error();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Cairo', fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showInfo(BuildContext context, String message) {
    AppHaptics.light();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Cairo', fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/// Direct Contact Launchers (WhatsApp, Phone call, Copy)
class AppContactActions {
  AppContactActions._();

  static String cleanPhoneNumber(String phone) {
    var p = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (p.startsWith('01') && p.length == 11) {
      p = '+2$p';
    } else if (p.startsWith('1') && p.length == 10) {
      p = '+20$p';
    }
    return p;
  }

  static Future<bool> launchWhatsApp({
    required BuildContext context,
    required String phone,
    String text = '',
  }) async {
    AppHaptics.light();
    final clean = cleanPhoneNumber(phone).replaceAll('+', '');
    final uri = Uri.parse('https://wa.me/$clean?text=${Uri.encodeComponent(text)}');
    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
    if (context.mounted) {
      Clipboard.setData(ClipboardData(text: text.isNotEmpty ? text : phone));
      AppToast.showInfo(context, 'تم نسخ النص إلى الحافظة لعدم توفر واتساب مباشرة');
    }
    return false;
  }

  static Future<bool> callPhone({
    required BuildContext context,
    required String phone,
  }) async {
    AppHaptics.light();
    final clean = cleanPhoneNumber(phone);
    final uri = Uri.parse('tel:$clean');
    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri);
      }
    } catch (_) {}
    if (context.mounted) {
      Clipboard.setData(ClipboardData(text: phone));
      AppToast.showInfo(context, 'تم نسخ رقم الهاتف: $phone');
    }
    return false;
  }
}

/// Ergonomic Bottom Sheet and Dialog system
class AppBottomSheet {
  AppBottomSheet._();

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    Widget? subtitle,
    required Widget Function(BuildContext context) builder,
    Widget? stickyAction,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    AppHaptics.selection();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurface,
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, width: 1.2),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * 0.9,
                maxWidth: 600,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkBorderMid : Colors.black12,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),

                  // Header with Title & Close
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                              if (subtitle != null) ...[
                                const SizedBox(height: 2),
                                subtitle,
                              ],
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 20),
                          onPressed: () => Navigator.of(ctx).pop(),
                          style: IconButton.styleFrom(
                            backgroundColor: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05),
                            padding: const EdgeInsets.all(6),
                            minimumSize: const Size(32, 32),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, thickness: 1),

                  // Content Body
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      child: builder(ctx),
                    ),
                  ),

                  // Optional Sticky Action Button
                  if (stickyAction != null) ...[
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurface,
                        border: Border(
                          top: BorderSide(
                            color: isDark ? AppColors.darkBorder : AppColors.border,
                            width: 1,
                          ),
                        ),
                      ),
                      child: stickyAction,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Modern Fast Confirmation Dialog
class AppConfirmDialog {
  AppConfirmDialog._();

  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'تأكيد',
    String cancelLabel = 'إلغاء',
    bool isDanger = false,
    IconData? icon,
  }) async {
    AppHaptics.light();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurfaceTop : AppColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: isDark ? AppColors.darkBorderMid : AppColors.lightBorder, width: 1.2),
        ),
        title: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: isDanger ? AppColors.error : AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w500,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              cancelLabel,
              style: TextStyle(
                color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
                fontWeight: FontWeight.w700,
                fontFamily: 'Cairo',
              ),
            ),
          ),
          FilledButton(
            onPressed: () {
              AppHaptics.medium();
              Navigator.pop(ctx, true);
            },
            style: FilledButton.styleFrom(
              backgroundColor: isDanger ? AppColors.error : AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            ),
            child: Text(
              confirmLabel,
              style: const TextStyle(fontWeight: FontWeight.w800, fontFamily: 'Cairo'),
            ),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}

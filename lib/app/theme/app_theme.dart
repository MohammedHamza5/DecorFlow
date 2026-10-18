import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// App theme configuration — Material 3 with premium high-contrast theme.
class AppTheme {
  AppTheme._();

  // ─── Light Theme ────────────────────────────────────────────
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        textTheme: AppTypography.textTheme,

        colorScheme: ColorScheme.light(
          primary: AppColors.primary,
          onPrimary: AppColors.textOnPrimary,
          primaryContainer: AppColors.primarySurface,
          onPrimaryContainer: AppColors.primaryDark,
          secondary: AppColors.secondaryDark,
          onSecondary: Colors.white,
          tertiary: AppColors.calcResult,
          surface: AppColors.lightSurface,
          onSurface: AppColors.lightTextPrimary,
          surfaceContainerHighest: AppColors.lightSurfaceVariant,
          error: AppColors.error,
          onError: Colors.white,
          outline: AppColors.lightBorder,
          outlineVariant: AppColors.lightDivider,
          shadow: Colors.black.withValues(alpha: 0.06),
          scrim: Colors.black.withValues(alpha: 0.3),
        ),

        scaffoldBackgroundColor: AppColors.lightBackground,

        // AppBar
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.lightSurface,
          foregroundColor: AppColors.lightTextPrimary,
          elevation: 0,
          scrolledUnderElevation: 1,
          shadowColor: Colors.black.withValues(alpha: 0.05),
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          titleTextStyle: AppTypography.textTheme.titleLarge?.copyWith(
            color: AppColors.lightTextPrimary,
            fontWeight: FontWeight.w800,
          ),
          iconTheme: const IconThemeData(color: AppColors.lightTextPrimary),
        ),

        // Cards
        cardTheme: CardThemeData(
          color: AppColors.lightSurface,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: AppColors.lightBorder, width: 1.2),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          shadowColor: Colors.black.withValues(alpha: 0.04),
          clipBehavior: Clip.antiAlias,
        ),

        // Elevated Buttons
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            elevation: 2,
            shadowColor: AppColors.primary.withValues(alpha: 0.3),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: AppTypography.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),

        // Filled Buttons
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: AppTypography.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),

        // Outlined Buttons
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            side: const BorderSide(color: AppColors.primary, width: 1.5),
            textStyle: AppTypography.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),

        // Text Buttons
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: AppTypography.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),

        // Input Decoration
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.lightSurface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.lightBorder, width: 1.2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: AppColors.lightBorder,
              width: 1.2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.error, width: 1.2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.error, width: 2),
          ),
          labelStyle: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.lightTextSecondary,
            fontWeight: FontWeight.w600,
          ),
          hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.lightTextTertiary,
          ),
          prefixIconColor: AppColors.lightTextSecondary,
          suffixIconColor: AppColors.lightTextSecondary,
        ),

        // Navigation Bar
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.lightSurface,
          indicatorColor: AppColors.primarySurface,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.black.withValues(alpha: 0.08),
          elevation: 2,
          height: 72,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: AppColors.primary, size: 24);
            }
            return const IconThemeData(color: AppColors.lightTextTertiary, size: 22);
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppTypography.textTheme.labelSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              );
            }
            return AppTypography.textTheme.labelSmall?.copyWith(
              color: AppColors.lightTextTertiary,
              fontWeight: FontWeight.w600,
            );
          }),
        ),

        // Floating Action Button
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 4,
          highlightElevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),

        // Chips
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.lightSurfaceVariant,
          selectedColor: AppColors.primarySurface,
          labelStyle: AppTypography.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        ),

        // Divider
        dividerTheme: const DividerThemeData(
          color: AppColors.lightBorder,
          space: 1,
          thickness: 1,
        ),

        // Bottom Sheet
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.lightSurface,
          surfaceTintColor: Colors.transparent,
          modalElevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          showDragHandle: true,
          dragHandleColor: AppColors.lightBorder,
        ),

        // Snackbar
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.lightTextPrimary,
          contentTextStyle: AppTypography.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 6,
        ),

        // Dialog
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.lightSurface,
          surfaceTintColor: Colors.transparent,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: AppColors.lightBorder, width: 1.2),
          ),
          titleTextStyle: AppTypography.textTheme.headlineSmall?.copyWith(
            color: AppColors.lightTextPrimary,
            fontWeight: FontWeight.w800,
          ),
          contentTextStyle: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.lightTextSecondary,
          ),
        ),

        // List Tile
        listTileTheme: ListTileThemeData(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          titleTextStyle: AppTypography.textTheme.bodyLarge?.copyWith(
            color: AppColors.lightTextPrimary,
            fontWeight: FontWeight.w700,
          ),
          subtitleTextStyle: AppTypography.textTheme.bodySmall?.copyWith(
            color: AppColors.lightTextSecondary,
          ),
        ),

        // Progress Indicator
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.primary,
        ),
      );

  // ─── Dark Theme ─────────────────────────────────────────────
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        textTheme: AppTypography.textTheme.apply(
          bodyColor: AppColors.darkTextPrimary,
          displayColor: AppColors.darkTextPrimary,
          decorationColor: AppColors.darkTextPrimary,
        ),

        colorScheme: ColorScheme.dark(
          // Primary — Radiant Azure Light in Dark Mode (High-Luminance)
          primary: AppColors.primaryLight,
          onPrimary: Colors.white,
          primaryContainer: AppColors.primarySurfaceDark,
          onPrimaryContainer: Colors.white,

          // Secondary — Crisp Slate
          secondary: AppColors.secondaryLight,
          onSecondary: AppColors.darkBg,
          secondaryContainer: AppColors.darkSurfaceElevated,
          onSecondaryContainer: AppColors.darkTextPrimary,

          // Tertiary — Emerald green
          tertiary: AppColors.calcResult,
          onTertiary: Colors.white,
          tertiaryContainer: AppColors.calcResultBg,
          onTertiaryContainer: AppColors.calcResult,

          // Surfaces — High Contrast Midnight Slate
          surface: AppColors.darkSurface,
          onSurface: AppColors.darkTextPrimary,
          surfaceContainerLowest: AppColors.darkBg,
          surfaceContainerLow: AppColors.darkBackground,
          surfaceContainer: AppColors.darkSurface,
          surfaceContainerHigh: AppColors.darkSurfaceElevated,
          surfaceContainerHighest: AppColors.darkSurfaceTop,

          // Inverse
          inverseSurface: AppColors.darkTextPrimary,
          onInverseSurface: AppColors.darkBg,
          inversePrimary: AppColors.primaryDark,

          // Error
          error: AppColors.error,
          onError: Colors.white,
          errorContainer: AppColors.errorSurface,
          onErrorContainer: AppColors.error,

          // Outlines
          outline: AppColors.darkBorder,
          outlineVariant: AppColors.darkBorderMid,

          // Shadows
          shadow: Colors.black.withValues(alpha: 0.5),
          scrim: Colors.black.withValues(alpha: 0.7),
        ),

        scaffoldBackgroundColor: AppColors.darkBackground,

        // AppBar
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.darkBackground,
          foregroundColor: AppColors.darkTextPrimary,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          centerTitle: true,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
            systemNavigationBarColor: AppColors.darkBackground,
            systemNavigationBarIconBrightness: Brightness.light,
          ),
          titleTextStyle: AppTypography.textTheme.titleLarge?.copyWith(
            color: AppColors.darkTextPrimary,
            fontWeight: FontWeight.w800,
          ),
          iconTheme: const IconThemeData(
            color: AppColors.darkTextPrimary,
            size: 22,
          ),
          actionsIconTheme: const IconThemeData(
            color: AppColors.darkTextSecondary,
            size: 22,
          ),
        ),

        // Cards — Visible borders with crisp depth
        cardTheme: CardThemeData(
          color: AppColors.darkSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(
              color: AppColors.darkBorder,
              width: 1.2,
            ),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          clipBehavior: Clip.antiAlias,
          shadowColor: Colors.transparent,
        ),

        // Elevated Buttons
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            disabledBackgroundColor: AppColors.darkSurfaceElevated,
            disabledForegroundColor: AppColors.darkTextTertiary,
            elevation: 2,
            shadowColor: AppColors.primary.withValues(alpha: 0.4),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: AppTypography.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),

        // Filled Buttons
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            disabledBackgroundColor: AppColors.darkSurfaceElevated,
            disabledForegroundColor: AppColors.darkTextTertiary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: AppTypography.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),

        // Outlined Buttons
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryLight,
            disabledForegroundColor: AppColors.darkTextTertiary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            side: const BorderSide(color: AppColors.primaryLight, width: 1.5),
            textStyle: AppTypography.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),

        // Text Buttons
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primaryLight,
            disabledForegroundColor: AppColors.darkTextTertiary,
            textStyle: AppTypography.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),

        // Input — crisp borders, clear labels
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.darkSurface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.darkBorder, width: 1.2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: AppColors.darkBorder,
              width: 1.2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: AppColors.primaryLight,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.error, width: 1.2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.error, width: 2),
          ),
          labelStyle: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.darkTextSecondary,
            fontWeight: FontWeight.w600,
          ),
          hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.darkTextTertiary,
          ),
          prefixIconColor: AppColors.darkTextSecondary,
          suffixIconColor: AppColors.darkTextSecondary,
        ),

        // Navigation Bar
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.darkNavBar,
          indicatorColor: AppColors.primarySurfaceDark,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          height: 72,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: AppColors.primaryLight, size: 24);
            }
            return const IconThemeData(
                color: AppColors.darkTextTertiary, size: 22);
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppTypography.textTheme.labelSmall?.copyWith(
                color: AppColors.primaryLight,
                fontWeight: FontWeight.w800,
              );
            }
            return AppTypography.textTheme.labelSmall?.copyWith(
              color: AppColors.darkTextTertiary,
              fontWeight: FontWeight.w600,
            );
          }),
        ),

        // Floating Action Button
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 4,
          highlightElevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(18)),
          ),
        ),

        // Chips
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.darkSurfaceElevated,
          selectedColor: AppColors.primarySurfaceDark,
          disabledColor: AppColors.darkSurface,
          labelStyle: AppTypography.textTheme.labelMedium?.copyWith(
            color: AppColors.darkTextSecondary,
            fontWeight: FontWeight.w600,
          ),
          secondaryLabelStyle: AppTypography.textTheme.labelMedium?.copyWith(
            color: AppColors.primaryLight,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          side: const BorderSide(color: AppColors.darkBorder, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          checkmarkColor: AppColors.primaryLight,
        ),

        // Divider
        dividerTheme: const DividerThemeData(
          color: AppColors.darkBorder,
          space: 1,
          thickness: 1,
        ),

        // Bottom Sheet
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.darkSurfaceElevated,
          surfaceTintColor: Colors.transparent,
          modalBackgroundColor: AppColors.darkSurfaceElevated,
          modalElevation: 0,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          showDragHandle: true,
          dragHandleColor: AppColors.darkBorderMid,
          dragHandleSize: Size(48, 5),
          clipBehavior: Clip.antiAlias,
        ),

        // Snackbar
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.darkSurfaceTop,
          contentTextStyle: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.darkTextPrimary,
            fontWeight: FontWeight.w600,
          ),
          actionTextColor: AppColors.primaryLight,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppColors.darkBorderMid, width: 1.2),
          ),
          elevation: 6,
        ),

        // Dialog
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.darkSurfaceTop,
          surfaceTintColor: Colors.transparent,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: AppColors.darkBorderMid, width: 1.2),
          ),
          titleTextStyle: AppTypography.textTheme.headlineSmall?.copyWith(
            color: AppColors.darkTextPrimary,
            fontWeight: FontWeight.w800,
          ),
          contentTextStyle: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.darkTextSecondary,
          ),
        ),

        // List Tile
        listTileTheme: ListTileThemeData(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          tileColor: Colors.transparent,
          selectedTileColor: AppColors.primarySurfaceDark,
          selectedColor: AppColors.primaryLight,
          iconColor: AppColors.darkTextSecondary,
          textColor: AppColors.darkTextPrimary,
          titleTextStyle: AppTypography.textTheme.bodyLarge?.copyWith(
            color: AppColors.darkTextPrimary,
            fontWeight: FontWeight.w700,
          ),
          subtitleTextStyle: AppTypography.textTheme.bodySmall?.copyWith(
            color: AppColors.darkTextSecondary,
          ),
        ),

        // Switch
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.textOnPrimary;
            }
            return AppColors.darkTextTertiary;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primary;
            }
            return AppColors.darkSurfaceTop;
          }),
          trackOutlineColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.transparent;
            }
            return AppColors.darkBorderMid;
          }),
        ),

        // Popup Menu
        popupMenuTheme: PopupMenuThemeData(
          color: AppColors.darkSurfaceTop,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.darkBorderMid, width: 1.2),
          ),
          surfaceTintColor: Colors.transparent,
          textStyle: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.darkTextPrimary,
            fontWeight: FontWeight.w600,
          ),
          labelTextStyle: WidgetStateProperty.all(
            AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.darkTextPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Progress Indicator
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.primaryLight,
          linearTrackColor: AppColors.darkSurfaceElevated,
        ),

        // Tooltip
        tooltipTheme: TooltipThemeData(
          decoration: BoxDecoration(
            color: AppColors.darkSurfaceTop,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.darkBorderMid),
          ),
          textStyle: AppTypography.textTheme.labelSmall?.copyWith(
            color: AppColors.darkTextPrimary,
          ),
        ),

        // Icon
        iconTheme: const IconThemeData(
          color: AppColors.darkTextSecondary,
          size: 22,
        ),

        // Primary Icon
        primaryIconTheme: const IconThemeData(
          color: AppColors.primaryLight,
          size: 22,
        ),
      );
}

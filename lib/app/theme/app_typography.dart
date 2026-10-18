import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Arabic-first typography using Cairo font.
///
/// Cairo is a clean, modern Arabic font that works excellently
/// for both body text and numbers.
class AppTypography {
  AppTypography._();

  static TextTheme get textTheme => TextTheme(
        displayLarge: GoogleFonts.cairo(
          fontSize: 32,
          fontWeight: FontWeight.w900,
          height: 1.4,
        ),
        displayMedium: GoogleFonts.cairo(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          height: 1.4,
        ),
        displaySmall: GoogleFonts.cairo(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          height: 1.4,
        ),
        headlineLarge: GoogleFonts.cairo(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          height: 1.4,
        ),
        headlineMedium: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          height: 1.4,
        ),
        headlineSmall: GoogleFonts.cairo(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          height: 1.4,
        ),
        titleLarge: GoogleFonts.cairo(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          height: 1.4,
        ),
        titleMedium: GoogleFonts.cairo(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          height: 1.4,
        ),
        titleSmall: GoogleFonts.cairo(
          fontSize: 14.5,
          fontWeight: FontWeight.w700,
          height: 1.4,
        ),
        bodyLarge: GoogleFonts.cairo(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.cairo(
          fontSize: 14.5,
          fontWeight: FontWeight.w600,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.cairo(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          height: 1.5,
        ),
        labelLarge: GoogleFonts.cairo(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          height: 1.4,
        ),
        labelMedium: GoogleFonts.cairo(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          height: 1.4,
        ),
        labelSmall: GoogleFonts.cairo(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          height: 1.4,
        ),
      );

  /// Large result number style for the calculator.
  static TextStyle get calcResultLarge => GoogleFonts.cairo(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        height: 1.2,
      );

  /// Medium result style for secondary values.
  static TextStyle get calcResultMedium => GoogleFonts.cairo(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.3,
      );

  /// Price display style.
  static TextStyle get priceStyle => GoogleFonts.cairo(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.3,
      );

  /// Strikethrough price (before discount).
  static TextStyle get priceBefore => GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        decoration: TextDecoration.lineThrough,
        height: 1.3,
      );
}

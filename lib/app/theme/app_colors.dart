import 'package:flutter/material.dart';

/// App color palette — Modern, High-Contrast Luxury Design System.
///
/// Design Philosophy:
/// - True optical depth: Deep Obsidian Slate canvas (#0B0F19) with distinct slate card surfaces (#1E293B).
/// - Ultra-crisp typography (WCAG AAA compliant): Pure bright white headings (#FFFFFF) and crystal-clear silver body (#CBD5E1).
/// - Vibrant Electric Royal Blue brand primary (#2563EB) paired with Luminous Gold (#F59E0B) accents.
/// - Unambiguous status indicators with vivid emerald green, ruby crimson, amber orange, and celestial cyan.
class AppColors {
  AppColors._();

  // ─── Primary Accent — Electric Royal Sapphire ────────────────
  /// Main brand accent — energetic, modern, crisp
  static const Color primary = Color(0xFF2563EB);        // Vibrant Royal Blue
  /// Brighter variant for highlights, hovers, active states, and dark mode
  static const Color primaryLight = Color(0xFF38BDF8);   // Electric Azure Sky (High-Luminance)
  /// Deeper variant for pressed/selected states
  static const Color primaryDark = Color(0xFF1D4ED8);    // Deep Royal Navy
  /// Subtle luminous tint for light surfaces
  static const Color primarySurface = Color(0xFFEFF6FF); // Soft Ice Blue
  /// Deep luminous tint for dark surfaces
  static const Color primarySurfaceDark = Color(0xFF132347); // Deep Navy Glow

  // ─── Luxury Gold / Warm Amber Accent ─────────────────────────
  /// Radiant gold for financial summaries, VIP badges, and highlights
  static const Color gold = Color(0xFFF59E0B);           // Vivid Amber Gold
  static const Color goldLight = Color(0xFFFBBF24);      // Radiant Gold
  static const Color goldDark = Color(0xFFD97706);       // Deep Amber
  static const Color goldSurfaceDark = Color(0xFF361E04); // Rich Amber Glow

  // ─── Background Layers — Deep Obsidian & Crisp Midnight Slate ──
  /// Canvas — deepest obsidian layer for desktop/outer canvas
  static const Color darkBg = Color(0xFF070B12);         // Pure Sleek Obsidian
  /// Base scaffold background for all mobile & desktop screens
  static const Color darkBackground = Color(0xFF0B101B); // Clean Midnight Canvas (No murky haze)
  /// Cards, list items, and standard surfaces (Clearly elevated from background)
  static const Color darkSurface = Color(0xFF141C2E);    // High-Contrast Slate Surface
  /// Elevated cards, search bars, inputs, popups, bottom sheets
  static const Color darkSurfaceElevated = Color(0xFF1E293F); // Elevated High-Contrast Surface
  /// Highest elevation — modal dialogs, top overlays
  static const Color darkSurfaceTop = Color(0xFF283654); // Top Elevated Layer

  // ─── Constant Light Theme Colors ─────────────────────────────
  static const Color lightBackground = Color(0xFFF8FAFC);    // Crisp Cool White
  static const Color lightSurface = Color(0xFFFFFFFF);       // Pure White Card
  static const Color lightSurfaceVariant = Color(0xFFF1F5F9);// Soft Slate Tint
  static const Color lightTextPrimary = Color(0xFF0F172A);   // Deep Navy Slate
  static const Color lightTextSecondary = Color(0xFF334155); // Slate Gray
  static const Color lightTextTertiary = Color(0xFF64748B);  // Muted Slate
  static const Color lightBorder = Color(0xFFE2E8F0);        // Crisp Divider
  static const Color lightDivider = Color(0xFFF1F5F9);       // Subtle Line

  // ─── Secondary — Cool Neutral Slate ───────────────────────────
  static const Color secondary = Color(0xFF94A3B8);     // Cool Slate
  static const Color secondaryLight = Color(0xFFCBD5E1); // Bright Slate
  static const Color secondaryDark = Color(0xFF475569);  // Deep Slate

  // ─── Accent — kept for legacy compatibility ───────────────────
  static const Color accent = primary;
  static const Color accentLight = primaryLight;

  // ─── Brand Glow Tint ──────────────────────────────────────────
  static Color get accentGlow => primary.withValues(alpha: 0.18);

  // ─── Typography — Dark Mode (Ultra High Contrast WCAG AAA) ───
  /// Pure 100% brilliant white for headings, titles, and critical numbers
  static const Color darkTextPrimary = Color(0xFFFFFFFF);   // Pure 100% Brilliant White
  /// Crisp luminous platinum for body, subtitles, and labels (Crystal clear reading)
  static const Color darkTextSecondary = Color(0xFFF1F5F9); // Crisp Luminous Platinum
  /// Clear silver for captions, metadata, and timestamps (Never dim or hazy)
  static const Color darkTextTertiary = Color(0xFFCBD5E1);  // High-Contrast Clear Silver
  /// Clearly legible muted slate for disabled elements
  static const Color darkTextDisabled = Color(0xFF94A3B8);  // Legible Slate

  // ─── Typography — Light Mode ─────────────────────────────────
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnPrimaryDark = Color(0xFF0F172A);

  // ─── Borders & Dividers — Dark Mode (Razor-Sharp Visibility) ─
  /// Standard card & component border (Sharp, clearly visible 1.2px outline)
  static const Color darkBorder = Color(0xFF334668);        // Crisp High-Visibility Border
  /// Slightly stronger border for focused or interactive elements
  static const Color darkBorderMid = Color(0xFF4B638F);     // Enhanced Focused Border
  /// Active / focused accent border
  static const Color darkBorderAccent = Color(0xFF38BDF8);  // Electric Azure Outline

  // ─── Borders & Dividers — Light Mode ─────────────────────────
  static const Color borderDark = Color(0xFFCBD5E1);

  // ─── Dynamic Theme Colors (adapt based on isDark) ────────────
  static bool isDark = true; // Global state updated on theme change
  
  static Color get background => isDark ? darkBackground : lightBackground;
  static Color get surface => isDark ? darkSurface : lightSurface;
  static Color get surfaceVariant => isDark ? darkSurfaceElevated : lightSurfaceVariant;
  static Color get textPrimary => isDark ? darkTextPrimary : lightTextPrimary;
  static Color get textSecondary => isDark ? darkTextSecondary : lightTextSecondary;
  static Color get textTertiary => isDark ? darkTextTertiary : lightTextTertiary;
  static Color get border => isDark ? darkBorder : lightBorder;
  static Color get divider => isDark ? darkBorderMid : lightDivider;

  // ─── Status Colors — Vivid, High-Contrast Indicators ──────────
  /// Success — Vibrant Emerald Mint
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);      // Luminous Mint for dark text/badges
  static const Color successDark = Color(0xFF059669);
  static const Color successSurface = Color(0xFF064E3B);    // Emerald glow bg

  /// Warning — Vivid Tangerine Amber
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);      // Luminous Amber Gold
  static const Color warningSurface = Color(0xFF451A03);

  /// Error — Crimson Coral
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);        // Luminous Coral for dark text/badges
  static const Color errorDark = Color(0xFFDC2626);
  static const Color errorSurface = Color(0xFF450A0A);      // Dark red glow bg

  /// Info — Cyan Sky
  static const Color info = Color(0xFF06B6D4);
  static const Color infoLight = Color(0xFF38BDF8);
  static const Color infoSurface = Color(0xFF083344);       // Cyan glow bg

  // ─── Calculator Specific ──────────────────────────────────────
  static const Color calcResult = Color(0xFF10B981);        // Mint Green
  static const Color calcResultBg = Color(0xFF064E3B);
  static const Color calcWaste = Color(0xFFF59E0B);         // Amber Gold
  static const Color calcWasteBg = Color(0xFF451A03);
  static const Color calcAccessory = Color(0xFF818CF8);     // Electric Indigo
  static const Color calcAccessoryBg = Color(0xFF1E1B4B);

  // ─── Quote & Invoice Status Colors ───────────────────────────
  static const Color quoteDraft = Color(0xFF94A3B8);        // Slate
  static const Color quoteSent = Color(0xFF38BDF8);         // Sky Blue
  static const Color quoteApproved = Color(0xFF10B981);     // Emerald Green
  static const Color quoteRejected = Color(0xFFEF4444);     // Crimson
  static const Color quoteExpired = Color(0xFF94A3B8);      // Legible Slate
  static const Color quoteRevised = Color(0xFFF59E0B);      // Amber

  // ─── Dark Mode Navigation Bar ────────────────────────────────
  static const Color darkNavBar = Color(0xFF070B12);
  static const Color darkNavIndicator = Color(0xFF141C2E);

  // ─── Shimmer / Skeleton ──────────────────────────────────────
  static const Color shimmerBase = Color(0xFF141C2E);
  static const Color shimmerHighlight = Color(0xFF283654);
}

import 'package:flutter/material.dart';

/// Shared inventory helper utilities.
class InventoryHelpers {
  InventoryHelpers._();

  /// Convert unit_type string to Arabic label.
  static String unitLabel(String unitType) {
    switch (unitType) {
      case 'rod': return 'عود';
      case 'panel': return 'لوح';
      case 'piece': return 'قطعة';
      case 'box': return 'علبة';
      case 'tube': return 'أنبوب';
      case 'roll': return 'رول';
      case 'square_meter': return 'م²';
      case 'linear_meter': return 'م.ط';
      default: return 'وحدة';
    }
  }

  /// Format quantity with smart decimal handling.
  static String formatQty(double qty) {
    if (qty == qty.roundToDouble()) {
      return qty.toStringAsFixed(0);
    }
    return qty.toStringAsFixed(1);
  }

  /// Get color for stock status.
  static Color stockStatusColor(double qty, double reorderPoint, ColorScheme colorScheme) {
    if (qty <= 0) return colorScheme.error;
    if (reorderPoint > 0 && qty <= reorderPoint) return Colors.orange;
    return Colors.green;
  }

  /// Get Arabic text for stock status.
  static String stockStatusText(double qty, double reorderPoint) {
    if (qty <= 0) return 'نفد';
    if (reorderPoint > 0 && qty <= reorderPoint) return 'منخفض';
    return 'متوفر';
  }

  /// Get icon for stock status.
  static IconData stockStatusIcon(double qty, double reorderPoint) {
    if (qty <= 0) return Icons.error_outline_rounded;
    if (reorderPoint > 0 && qty <= reorderPoint) return Icons.warning_amber_rounded;
    return Icons.check_circle_outline_rounded;
  }

  /// Get icon for movement type.
  static IconData movementIcon(String type) {
    switch (type) {
      case 'in': return Icons.arrow_downward_rounded;
      case 'out': return Icons.arrow_upward_rounded;
      case 'adjustment': return Icons.tune_rounded;
      case 'return': return Icons.undo_rounded;
      case 'initial': return Icons.flag_rounded;
      case 'damaged': return Icons.broken_image_rounded;
      default: return Icons.swap_horiz_rounded;
    }
  }

  /// Get color for movement type.
  static Color movementColor(String type) {
    switch (type) {
      case 'in': return Colors.green;
      case 'out': return Colors.red;
      case 'adjustment': return Colors.blue;
      case 'return': return Colors.orange;
      case 'initial': return Colors.purple;
      case 'damaged': return Colors.red.shade700;
      default: return Colors.grey;
    }
  }

  /// Get Arabic label for movement type.
  static String movementLabel(String type) {
    switch (type) {
      case 'in': return 'وارد';
      case 'out': return 'صادر';
      case 'adjustment': return 'تعديل';
      case 'return': return 'مرتجع';
      case 'initial': return 'جرد أولي';
      case 'damaged': return 'تالف';
      default: return type;
    }
  }

  /// Get sign prefix for movement type.
  static String movementSign(String type) {
    switch (type) {
      case 'in': case 'initial': case 'return': return '+';
      case 'out': case 'damaged': return '-';
      case 'adjustment': return '=';
      default: return '';
    }
  }

  /// Format currency in Egyptian pounds.
  static String formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)} مليون ج.م';
    }
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)} ألف ج.م';
    }
    return '${amount.toStringAsFixed(0)} ج.م';
  }
}

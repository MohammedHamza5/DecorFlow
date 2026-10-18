import 'package:intl/intl.dart';

extension NumberFormatting on num {
  /// Format as Arabic-style currency (e.g., "2,750.00 ج.م")
  String toCurrency({String symbol = 'ج.م'}) {
    final formatter = NumberFormat('#,##0.00', 'ar_EG');
    return '${formatter.format(this)} $symbol';
  }

  /// Format as a compact number for display (e.g., "2,750")
  String toCompact() {
    final formatter = NumberFormat('#,##0.##', 'ar_EG');
    return formatter.format(this);
  }

  /// Format as percentage (e.g., "10%")
  String toPercent() {
    return '${(this * 100).toStringAsFixed(0)}%';
  }

  /// Format as dimension in meters (e.g., "4.00 م")
  String toMeters() {
    return '${toStringAsFixed(2)} م';
  }

  /// Format as area in square meters (e.g., "24.00 م²")
  String toSquareMeters() {
    return '${toStringAsFixed(2)} م²';
  }
}

extension DoubleRounding on double {
  /// Round up to the nearest integer (ceiling).
  int ceilToInt() => ceil();

  /// Round to N decimal places.
  double roundTo(int places) {
    var m = 1.0;
    for (var i = 0; i < places; i++) {
      m *= 10;
    }
    return (this * m).round() / m;
  }
}

import 'dart:math';
import 'models/calc_output.dart';

/// Engine that automatically calculates required accessories for a product.
///
/// Uses `product_assemblies` data from Supabase to determine what accessories
/// are needed and in what quantities, based on the primary material calculation.
///
/// Supports all `quantity_rule_type` values:
/// - per_unit, per_meter, per_ml, per_square_meter, per_wall,
///   per_corner, per_joint, per_edge, per_roll, fixed
class AccessoriesEngine {
  /// Calculate accessories based on assembly rules and primary calculation.
  List<AccessoryCalcResult> calculate({
    required List<Map<String, dynamic>> assemblies,
    required double primaryQty,
    required double netArea,
    required double totalLength,
    required int wallCount,
    required int cornerCount,
  }) {
    final results = <AccessoryCalcResult>[];

    for (final assembly in assemblies) {
      final ruleType = assembly['quantity_rule_type'] as String? ?? 'per_unit';
      final ruleValue = _toDouble(assembly['quantity_rule_value']) ?? 1.0;
      final isOptional = assembly['is_optional'] as bool? ?? false;

      // Get accessory product info
      final accessoryProduct = assembly['accessory_product'] as Map<String, dynamic>?
          ?? assembly['accessory'] as Map<String, dynamic>?
          ?? {};
      final accName = accessoryProduct['name'] as String? ?? 'إكسسوار';
      final accId = accessoryProduct['id'] as String?;
      final accCategory = accessoryProduct['category'] as String? ?? '';

      // Calculate quantity based on rule type
      double qty = 0;
      String explanation = '';

      switch (ruleType) {
        case 'per_unit':
          qty = primaryQty * ruleValue;
          explanation = '$primaryQty وحدة × $ruleValue = ${qty.toStringAsFixed(1)}';
          break;

        case 'per_meter':
        case 'per_ml':
          qty = totalLength * ruleValue;
          explanation = '${totalLength.toStringAsFixed(1)} م × $ruleValue = ${qty.toStringAsFixed(2)}';
          break;

        case 'per_square_meter':
          qty = netArea * ruleValue;
          explanation = '${netArea.toStringAsFixed(1)} م² × $ruleValue = ${qty.toStringAsFixed(2)}';
          break;

        case 'per_wall':
          qty = wallCount * ruleValue;
          explanation = '$wallCount حائط × $ruleValue = ${qty.toStringAsFixed(1)}';
          break;

        case 'per_corner':
          qty = cornerCount * ruleValue;
          explanation = '$cornerCount زاوية × $ruleValue = ${qty.toStringAsFixed(1)}';
          break;

        case 'per_joint':
          // Joints = number of pieces that meet side-by-side minus walls
          // (each wall starts fresh, so joints = primaryQty - wallCount)
          final joints = max(0, primaryQty - wallCount).toInt();
          qty = joints * ruleValue;
          explanation = '$joints فاصل × $ruleValue = ${qty.toStringAsFixed(1)}';
          break;

        case 'per_edge':
          // Edges = start/end of each wall = wallCount × 2
          qty = wallCount * 2 * ruleValue;
          explanation = '$wallCount × 2 طرف × $ruleValue = ${qty.toStringAsFixed(1)}';
          break;

        case 'per_roll':
          qty = (primaryQty).ceil() * ruleValue;
          explanation = '${primaryQty.ceil()} رول × $ruleValue = ${qty.toStringAsFixed(1)}';
          break;

        case 'fixed':
          qty = ruleValue;
          explanation = 'كمية ثابتة = ${qty.toStringAsFixed(1)}';
          break;

        default:
          qty = primaryQty * ruleValue;
          explanation = 'افتراضي: $primaryQty × $ruleValue = ${qty.toStringAsFixed(1)}';
      }

      // Round up to whole units
      qty = qty.ceilToDouble();
      if (qty <= 0) continue;

      // Get unit price from pricing (if available)
      double unitPrice = 0;
      // Try to extract price from nested pricing data
      final accPricings = accessoryProduct['supplier_product_pricings'] as List?;
      if (accPricings != null && accPricings.isNotEmpty) {
        final preferred = accPricings.where((p) => (p as Map)['is_preferred'] == true);
        final pref = preferred.isNotEmpty ? preferred.first : accPricings.first;
        unitPrice = _toDouble(pref['net_price']) ?? _toDouble(pref['list_price']) ?? 0;
      }

      // Determine unit label from accessory's unit_type
      final accUnitType = accessoryProduct['unit_type'] as String? ?? '';
      String unitLabel;
      switch (accUnitType) {
        case 'linear_meter':
          unitLabel = 'م.ط';
          break;
        case 'square_meter':
          unitLabel = 'م²';
          break;
        case 'tube':
          unitLabel = 'أنبوبة';
          break;
        case 'container':
          unitLabel = 'عبوة';
          break;
        case 'box':
          unitLabel = 'كرتونة';
          break;
        case 'piece':
          unitLabel = 'قطعة';
          break;
        default:
          unitLabel = 'قطعة';
      }

      results.add(AccessoryCalcResult(
        name: accName,
        productId: accId,
        category: accCategory,
        quantity: qty,
        unitPrice: unitPrice,
        lineTotal: qty * unitPrice,
        unitLabel: unitLabel,
        ruleType: ruleType,
        isOptional: isOptional,
        isEnabled: true,
        explanation: explanation,
      ));
    }

    return results;
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

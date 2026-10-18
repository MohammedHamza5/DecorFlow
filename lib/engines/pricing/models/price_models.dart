/// Represents a single discount in a discount chain.
class Discount {
  final String name;
  final double value; // 0.0 to 1.0 for percentage, absolute for fixed
  final bool isPercentage;
  final String? reason;
  final DateTime? validUntil;

  const Discount({
    required this.name,
    required this.value,
    this.isPercentage = true,
    this.reason,
    this.validUntil,
  });

  /// Whether this discount is still valid.
  bool get isValid =>
      validUntil == null || validUntil!.isAfter(DateTime.now());
}

/// Accessory price information.
class AccessoryPrice {
  final String name;
  final double quantity;
  final double unitPrice;
  final String unit;

  const AccessoryPrice({
    required this.name,
    required this.quantity,
    required this.unitPrice,
    this.unit = 'قطعة',
  });

  double get total => quantity * unitPrice;
}

/// Input for the pricing engine.
class PriceInput {
  final double quantity;
  final String unitLabel;
  final double listPrice;
  final List<Discount> discounts;
  final double? installationRate; // per unit
  final List<AccessoryPrice> accessories;
  final double? profitMargin; // optional percentage

  const PriceInput({
    required this.quantity,
    required this.unitLabel,
    required this.listPrice,
    this.discounts = const [],
    this.installationRate,
    this.accessories = const [],
    this.profitMargin,
  });
}

/// Output from the pricing engine.
class PriceOutput {
  /// Original list price per unit.
  final double listPrice;

  /// Price per unit after discounts.
  final double netUnitPrice;

  /// Total before anything (quantity × listPrice).
  final double totalBeforeDiscount;

  /// Total discount amount.
  final double totalDiscount;

  /// Subtotal after discounts.
  final double subtotalAfterDiscount;

  /// Total installation cost.
  final double installationCost;

  /// Total accessories cost.
  final double accessoriesCost;

  /// Profit margin amount (if applicable).
  final double profitAmount;

  /// Grand total.
  final double finalTotal;

  /// Breakdown of discounts applied.
  final List<DiscountStep> discountBreakdown;

  /// Breakdown of accessories.
  final List<AccessoryPrice> accessoryBreakdown;

  const PriceOutput({
    this.listPrice = 0,
    this.netUnitPrice = 0,
    this.totalBeforeDiscount = 0,
    this.totalDiscount = 0,
    this.subtotalAfterDiscount = 0,
    this.installationCost = 0,
    this.accessoriesCost = 0,
    this.profitAmount = 0,
    this.finalTotal = 0,
    this.discountBreakdown = const [],
    this.accessoryBreakdown = const [],
  });

  static const empty = PriceOutput();
}

/// A step in the discount chain for transparency.
class DiscountStep {
  final String name;
  final double beforePrice;
  final double discountAmount;
  final double afterPrice;

  const DiscountStep({
    required this.name,
    required this.beforePrice,
    required this.discountAmount,
    required this.afterPrice,
  });
}

/// A rule that modifies a base price.
class PricingRuleModel {
  final String conditionAttribute; // e.g. 'material'
  final String conditionValue;     // e.g. 'ريزين'
  final double modifierAmount;     // e.g. 100
  final String modifierType;       // e.g. 'fixed_addition'
  
  const PricingRuleModel({
    required this.conditionAttribute,
    required this.conditionValue,
    required this.modifierAmount,
    this.modifierType = 'fixed_addition',
  });
}

/// Result of resolving a hierarchical price for a product.
class ResolvedPrice {
  final double cost;
  final double price;
  final bool isCostOverridden;
  final bool isPriceOverridden;
  final List<String> appliedRules;
  
  /// Net profit per unit
  double get profit => price - cost;
  
  /// Profit margin percentage (0.0 to 1.0)
  double get marginPercent => price > 0 ? (profit / price) : 0;
  
  const ResolvedPrice({
    required this.cost,
    required this.price,
    this.isCostOverridden = false,
    this.isPriceOverridden = false,
    this.appliedRules = const [],
  });
}

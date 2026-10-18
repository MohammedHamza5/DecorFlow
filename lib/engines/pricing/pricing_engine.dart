import 'models/price_models.dart';

/// The pricing engine — handles discounts, accessories, installation, and margins.
///
/// Implements sequential discount chain as per PRD section 12.2:
/// finalPrice = listPrice × (1-d1) × (1-d2) × ...
///
/// Pure Dart, no Flutter dependencies.
class PricingEngine {
  /// Calculate the full price breakdown.
  PriceOutput calculatePrice(PriceInput input) {
    // Step 1: Apply sequential discounts to unit price
    double currentPrice = input.listPrice;
    final discountSteps = <DiscountStep>[];

    for (final discount in input.discounts) {
      if (!discount.isValid) continue;

      final beforePrice = currentPrice;
      double discountAmount;

      if (discount.isPercentage) {
        discountAmount = currentPrice * discount.value;
      } else {
        discountAmount = discount.value;
      }

      currentPrice -= discountAmount;

      discountSteps.add(DiscountStep(
        name: discount.name,
        beforePrice: beforePrice,
        discountAmount: discountAmount,
        afterPrice: currentPrice,
      ));
    }

    final netUnitPrice = currentPrice;
    final totalBeforeDiscount = input.quantity * input.listPrice;
    final subtotalAfterDiscount = input.quantity * netUnitPrice;
    final totalDiscount = totalBeforeDiscount - subtotalAfterDiscount;

    // Step 2: Installation cost
    final installationCost = input.installationRate != null
        ? input.quantity * input.installationRate!
        : 0.0;

    // Step 3: Accessories cost
    double accessoriesCost = 0;
    for (final accessory in input.accessories) {
      accessoriesCost += accessory.total;
    }

    // Step 4: Profit margin
    final subtotal = subtotalAfterDiscount + installationCost + accessoriesCost;
    final profitAmount = input.profitMargin != null
        ? subtotal * input.profitMargin!
        : 0.0;

    // Step 5: Final total
    final finalTotal = subtotal + profitAmount;

    return PriceOutput(
      listPrice: input.listPrice,
      netUnitPrice: netUnitPrice,
      totalBeforeDiscount: totalBeforeDiscount,
      totalDiscount: totalDiscount,
      subtotalAfterDiscount: subtotalAfterDiscount,
      installationCost: installationCost,
      accessoriesCost: accessoriesCost,
      profitAmount: profitAmount,
      finalTotal: finalTotal,
      discountBreakdown: discountSteps,
      accessoryBreakdown: input.accessories,
    );
  }

  /// Quick calculation — just quantity × price with discounts.
  double quickPrice({
    required double quantity,
    required double listPrice,
    List<Discount> discounts = const [],
  }) {
    double price = listPrice;
    for (final d in discounts) {
      if (!d.isValid) continue;
      if (d.isPercentage) {
        price *= (1 - d.value);
      } else {
        price -= d.value;
      }
    }
    return quantity * price;
  }

  /// Resolves the base cost and price for a product based on the Smart Tiered Pricing Matrix.
  ResolvedPrice resolveBasePrice({
    required double? costOverride,
    required double? priceOverride,
    required double categoryBaseCost,
    required double categoryBasePrice,
    required List<PricingRuleModel> rules,
    required Map<String, String?> productAttributes,
  }) {
    double finalCost = costOverride ?? categoryBaseCost;
    double finalPrice = priceOverride ?? categoryBasePrice;
    
    final appliedRules = <String>[];

    // Only apply rules if price/cost are NOT overridden
    // Or if we want rules to always apply? Usually overrides skip rules.
    if (priceOverride == null || costOverride == null) {
      for (final rule in rules) {
        final attrValue = productAttributes[rule.conditionAttribute];
        if (attrValue != null && attrValue.toLowerCase() == rule.conditionValue.toLowerCase()) {
          // Rule matches!
          if (rule.modifierType == 'fixed_addition') {
            if (priceOverride == null) finalPrice += rule.modifierAmount;
            if (costOverride == null) finalCost += rule.modifierAmount; // Assume rule affects both cost & price identically for now, or just price?
            // "هل هذه الزيادة تطبق على سعر الشراء وسعر البيع معاً؟" -> Since user didn't specify, we'll apply to both to preserve margin, or we can just apply to price.
            // Actually, usually material upgrades cost more. Let's apply to both.
          } else if (rule.modifierType == 'percentage') {
            if (priceOverride == null) finalPrice += (finalPrice * (rule.modifierAmount / 100));
            if (costOverride == null) finalCost += (finalCost * (rule.modifierAmount / 100));
          }
          
          appliedRules.add('${rule.conditionAttribute}=${rule.conditionValue} (+${rule.modifierAmount})');
        }
      }
    }

    return ResolvedPrice(
      cost: finalCost,
      price: finalPrice,
      isCostOverridden: costOverride != null,
      isPriceOverridden: priceOverride != null,
      appliedRules: appliedRules,
    );
  }
}

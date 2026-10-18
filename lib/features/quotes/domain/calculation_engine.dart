class CalculationResult {
  final double primaryQty;
  final double primaryUnitPrice;
  final double primaryLineTotal;
  final List<AccessoryResult> accessories;

  CalculationResult({
    required this.primaryQty,
    required this.primaryUnitPrice,
    required this.primaryLineTotal,
    required this.accessories,
  });

  double get grandTotal =>
      primaryLineTotal +
      accessories.fold(0.0, (sum, acc) => sum + acc.lineTotal);
}

class AccessoryResult {
  final Map<String, dynamic> accessoryProduct;
  final double qty;
  final double unitPrice;
  final double lineTotal;

  AccessoryResult({
    required this.accessoryProduct,
    required this.qty,
    required this.unitPrice,
    required this.lineTotal,
  });
}

class CalculationEngine {
  /// Calculate required materials and accessories for a given wall and product variant.
  static CalculationResult calculateMaterialRequirements({
    required double wallLength,
    required double wallHeight,
    required double netArea,
    required Map<String, dynamic> variant,
    required String calcMode,
    required double wastePercent,
  }) {
    // Determine unit price for primary item
    double unitPrice = 0.0;
    final pricings = variant['supplier_product_pricings'] as List? ?? [];
    if (pricings.isNotEmpty) {
      // Pick preferred or first
      final preferred = pricings.where((p) => (p as Map)['is_preferred'] == true);
      final pref = preferred.isNotEmpty ? preferred.first : pricings.first;
      unitPrice = (pref['price'] as num?)?.toDouble() ?? 0.0;
    }

    final dimsRaw = variant['dimensions'];
    final Map<String, dynamic> variantDimensions = (dimsRaw is Map) 
        ? Map<String, dynamic>.from(dimsRaw) 
        : {};
    final vWidth = (variantDimensions['width'] as num?)?.toDouble() ?? 1.0;
    final vLength = (variantDimensions['length'] as num?)?.toDouble() ?? 1.0;

    double primaryQty = 0.0;

    switch (calcMode) {
      case 'vertical':
        // Panels installed vertically
        // Requires panel height (vLength) to be >= wallHeight.
        // We calculate how many panels needed to cover wallLength.
        // Example: Wall 3m, Panel width 0.15m. Need 3 / 0.15 = 20 panels.
        final requiredWidth = wallLength * (1 + (wastePercent / 100));
        primaryQty = (requiredWidth / vWidth).ceilToDouble();
        break;

      case 'horizontal':
        // Panels installed horizontally
        // Requires panel length (vLength) to be >= wallLength.
        // We calculate how many panels needed to cover wallHeight.
        final requiredHeight = wallHeight * (1 + (wastePercent / 100));
        primaryQty = (requiredHeight / vWidth).ceilToDouble();
        break;

      case 'linear':
        // Cornice, Skirting
        // Measured by total length.
        final requiredLength = wallLength * (1 + (wastePercent / 100));
        primaryQty = requiredLength.ceilToDouble();
        break;

      case 'standard':
      default:
        // Area-based calculation
        // Example: Wallpaper, marble sheets.
        final requiredArea = netArea * (1 + (wastePercent / 100));
        final variantArea = vWidth * vLength;
        if (variantArea > 0) {
          primaryQty = (requiredArea / variantArea).ceilToDouble();
        } else {
          primaryQty = requiredArea.ceilToDouble();
        }
        break;
    }

    // Ensure we don't return infinity or NaN
    if (primaryQty.isNaN || primaryQty.isInfinite) primaryQty = 0;

    final primaryLineTotal = primaryQty * unitPrice;

    // Calculate Accessories
    final accessories = <AccessoryResult>[];
    final assemblies = variant['product_assemblies'] as List? ?? [];

    for (final assembly in assemblies) {
      final accProduct = assembly['accessory'] as Map<String, dynamic>?;
      if (accProduct == null) continue;

      final ratioPrimary = (assembly['quantity_primary'] as num?)?.toDouble() ?? 1.0;
      final ratioAccessory = (assembly['quantity_accessory'] as num?)?.toDouble() ?? 1.0;

      // Rule: For every [ratioPrimary] of primary item, we need [ratioAccessory] of accessory.
      // Example: 1 tube of silicone (ratioAccessory = 1) for every 3 panels (ratioPrimary = 3).
      double accQty = 0.0;
      if (ratioPrimary > 0) {
        // Ceiling division to ensure we have enough accessories.
        accQty = (primaryQty / ratioPrimary).ceil() * ratioAccessory;
      }

      // Default accessory price is 0 unless we fetch it (in a real app we'd join accessory pricing too).
      // For MVP, we assume accessory pricing might not be joined deeply, or we can use a dummy 0.0
      double accUnitPrice = 0.0; // We'd need to fetch pricing for accessories.
      
      accessories.add(
        AccessoryResult(
          accessoryProduct: accProduct,
          qty: accQty,
          unitPrice: accUnitPrice,
          lineTotal: accQty * accUnitPrice,
        ),
      );
    }

    return CalculationResult(
      primaryQty: primaryQty,
      primaryUnitPrice: unitPrice,
      primaryLineTotal: primaryLineTotal,
      accessories: accessories,
    );
  }
}

/// Output model from the calculation engine.
///
/// Contains all computed values that the UI and quote builder need.
class CalcOutput {
  /// The gross area or length before deductions.
  final double grossArea;

  /// Total area of deducted openings.
  final double openingsArea;

  /// Net area/length after deductions.
  final double netArea;

  /// Base quantity needed (before waste).
  final double baseQuantity;

  /// Quantity after applying waste percentage.
  final double quantityWithWaste;

  /// Number of discrete units needed (rods, panels, boxes) — always rounded up.
  final int unitsNeeded;

  /// Unit label for display (e.g., "عود", "لوح", "م²").
  final String unitLabel;

  /// The waste percentage that was applied.
  final double wastePercent;

  /// Waste quantity (quantityWithWaste - baseQuantity).
  final double wasteQuantity;

  /// Total covered area/length by the calculated units.
  final double totalCoverage;

  /// List of warnings or suitability alerts.
  final List<String> warnings;

  /// Detailed calculation steps for transparency.
  final List<String> calculationSteps;

  /// Calculated accessories (populated by AccessoriesEngine).
  final List<AccessoryCalcResult> accessories;

  /// Detailed cutting instructions for each optimized rod.
  final List<String> cuttingInstructions;

  /// Detailed cuts per rod (list of cut lengths for each rod).
  final List<List<double>> rodCuts;

  /// Efficiency percentage of material usage (e.g. 0.85 for 85%).
  final double? optimizationEfficiency;

  const CalcOutput({
    this.grossArea = 0,
    this.openingsArea = 0,
    this.netArea = 0,
    this.baseQuantity = 0,
    this.quantityWithWaste = 0,
    this.unitsNeeded = 0,
    this.unitLabel = '',
    this.wastePercent = 0,
    this.wasteQuantity = 0,
    this.totalCoverage = 0,
    this.warnings = const [],
    this.calculationSteps = const [],
    this.accessories = const [],
    this.cuttingInstructions = const [],
    this.rodCuts = const [],
    this.optimizationEfficiency,
  });

  /// Empty output (initial state).
  static const empty = CalcOutput();

  /// Whether this output has valid results.
  bool get hasResults => unitsNeeded > 0 || quantityWithWaste > 0;

  /// Total accessories cost.
  double get totalAccessoriesCost =>
      accessories.fold(0.0, (sum, a) => sum + a.lineTotal);

  /// Create a copy with accessories populated.
  CalcOutput withAccessories(List<AccessoryCalcResult> accessories) {
    return CalcOutput(
      grossArea: grossArea,
      openingsArea: openingsArea,
      netArea: netArea,
      baseQuantity: baseQuantity,
      quantityWithWaste: quantityWithWaste,
      unitsNeeded: unitsNeeded,
      unitLabel: unitLabel,
      wastePercent: wastePercent,
      wasteQuantity: wasteQuantity,
      totalCoverage: totalCoverage,
      warnings: warnings,
      calculationSteps: calculationSteps,
      accessories: accessories,
      cuttingInstructions: cuttingInstructions,
      rodCuts: rodCuts,
      optimizationEfficiency: optimizationEfficiency,
    );
  }

  /// Convert to JSON for saving calculation records.
  Map<String, dynamic> toJson() => {
        'grossArea': grossArea,
        'openingsArea': openingsArea,
        'netArea': netArea,
        'baseQuantity': baseQuantity,
        'quantityWithWaste': quantityWithWaste,
        'unitsNeeded': unitsNeeded,
        'unitLabel': unitLabel,
        'wastePercent': wastePercent,
        'wasteQuantity': wasteQuantity,
        'totalCoverage': totalCoverage,
        'warnings': warnings,
        'calculationSteps': calculationSteps,
        'accessories': accessories.map((a) => a.toJson()).toList(),
        'cuttingInstructions': cuttingInstructions,
        'rodCuts': rodCuts,
        'optimizationEfficiency': optimizationEfficiency,
      };
}

/// Result of an accessory calculation.
class AccessoryCalcResult {
  /// Accessory product name.
  final String name;

  /// Accessory product ID (from products table).
  final String? productId;

  /// Category of the accessory.
  final String category;

  /// Calculated quantity.
  final double quantity;

  /// Unit price of the accessory.
  final double unitPrice;

  /// Line total (quantity × unitPrice).
  final double lineTotal;

  /// Unit label for display.
  final String unitLabel;

  /// The rule that was used to calculate.
  final String ruleType;

  /// Whether this accessory is optional.
  final bool isOptional;

  /// Whether the user has toggled this accessory on.
  final bool isEnabled;

  /// Calculation explanation.
  final String explanation;

  const AccessoryCalcResult({
    required this.name,
    this.productId,
    this.category = '',
    required this.quantity,
    this.unitPrice = 0,
    this.lineTotal = 0,
    this.unitLabel = 'قطعة',
    this.ruleType = '',
    this.isOptional = false,
    this.isEnabled = true,
    this.explanation = '',
  });

  AccessoryCalcResult copyWith({bool? isEnabled}) {
    return AccessoryCalcResult(
      name: name,
      productId: productId,
      category: category,
      quantity: quantity,
      unitPrice: unitPrice,
      lineTotal: isEnabled == false ? 0 : lineTotal,
      unitLabel: unitLabel,
      ruleType: ruleType,
      isOptional: isOptional,
      isEnabled: isEnabled ?? this.isEnabled,
      explanation: explanation,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'productId': productId,
    'category': category,
    'quantity': quantity,
    'unitPrice': unitPrice,
    'lineTotal': lineTotal,
    'unitLabel': unitLabel,
    'ruleType': ruleType,
    'isOptional': isOptional,
    'isEnabled': isEnabled,
  };
}

// Models for the Smart Mix Advisor.

/// A proposal for mixing materials to reduce cost.
class MixProposal {
  /// Proposal title (e.g., "رخام + خشب").
  final String title;

  /// Human-readable description.
  final String description;

  /// Design note explaining the visual benefit.
  final String designNote;

  /// The items in this mix.
  final List<MixItem> items;

  /// Total cost of this mix.
  final double totalCost;

  /// Original cost (single material).
  final double originalCost;

  /// Savings amount.
  double get savings => originalCost - totalCost;

  /// Savings percentage.
  double get savingsPercent =>
      originalCost > 0 ? (savings / originalCost) * 100 : 0;

  const MixProposal({
    required this.title,
    required this.description,
    required this.designNote,
    required this.items,
    required this.totalCost,
    required this.originalCost,
  });
}

/// A single item in a mix proposal.
class MixItem {
  /// Product name.
  final String productName;

  /// Product category.
  final String category;

  /// Placement description (e.g., "وسط الحائط").
  final String placement;

  /// Coverage area ratio (0.0 to 1.0).
  final double coverageRatio;

  /// Actual coverage area in m².
  final double coverageArea;

  /// Calculated quantity.
  final double quantity;

  /// Unit label.
  final String unitLabel;

  /// Unit price.
  final double unitPrice;

  /// Line total.
  final double lineTotal;

  /// Suggested product variant ID (if linked to catalog).
  final String? variantId;

  const MixItem({
    required this.productName,
    required this.category,
    required this.placement,
    required this.coverageRatio,
    required this.coverageArea,
    required this.quantity,
    required this.unitLabel,
    required this.unitPrice,
    required this.lineTotal,
    this.variantId,
  });
}

/// A mix rule defines how two categories can be combined.
class MixRule {
  /// Source category (the expensive one).
  final String sourceCategory;

  /// The secondary category to mix with.
  final String mixCategory;

  /// Ratio of secondary material (e.g., 0.4 = 40%).
  final double secondaryRatio;

  /// Placement of the secondary material.
  final String secondaryPlacement;

  /// Placement of the remaining primary material.
  final String primaryPlacement;

  /// Expected savings percentage.
  final double expectedSavings;

  /// Design description.
  final String designNote;

  /// Title template.
  final String title;

  const MixRule({
    required this.sourceCategory,
    required this.mixCategory,
    required this.secondaryRatio,
    required this.secondaryPlacement,
    required this.primaryPlacement,
    required this.expectedSavings,
    required this.designNote,
    required this.title,
  });
}

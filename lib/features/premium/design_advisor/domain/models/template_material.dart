class TemplateMaterial {
  final String id;
  final String templateId;
  final String productCategory; // Category like 'بديل خشب', 'بديل رخام', etc.
  final String calculationRule; // 'panel_center_one_third', 'louver_edges_two_thirds', 'fixed_count', etc.
  final double unitMultiplier;
  final bool isOptional;

  TemplateMaterial({
    required this.id,
    required this.templateId,
    required this.productCategory,
    required this.calculationRule,
    this.unitMultiplier = 1.0,
    this.isOptional = false,
  });

  factory TemplateMaterial.fromJson(Map<String, dynamic> json) {
    return TemplateMaterial(
      id: json['id'] as String,
      templateId: json['template_id'] as String,
      productCategory: json['product_category'] as String,
      calculationRule: json['calculation_rule'] as String,
      unitMultiplier: (json['unit_multiplier'] as num?)?.toDouble() ?? 1.0,
      isOptional: json['is_optional'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'template_id': templateId,
      'product_category': productCategory,
      'calculation_rule': calculationRule,
      'unit_multiplier': unitMultiplier,
      'is_optional': isOptional,
    };
  }
}

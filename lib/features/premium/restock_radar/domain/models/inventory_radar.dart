class InventoryRadar {
  final String productVariantId;
  final String? supplierId;
  final double? safetyStockOverride;
  final double restockOrderQuantity;
  final DateTime createdAt;
  final DateTime updatedAt;

  InventoryRadar({
    required this.productVariantId,
    this.supplierId,
    this.safetyStockOverride,
    this.restockOrderQuantity = 50.0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InventoryRadar.fromJson(Map<String, dynamic> json) {
    return InventoryRadar(
      productVariantId: json['product_variant_id'] as String,
      supplierId: json['supplier_id'] as String?,
      safetyStockOverride: (json['safety_stock_override'] as num?)?.toDouble(),
      restockOrderQuantity: (json['restock_order_quantity'] as num?)?.toDouble() ?? 50.0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_variant_id': productVariantId,
      'supplier_id': supplierId,
      'safety_stock_override': safetyStockOverride,
      'restock_order_quantity': restockOrderQuantity,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

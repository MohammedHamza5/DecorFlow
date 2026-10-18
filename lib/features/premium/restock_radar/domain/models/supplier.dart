class Supplier {
  final String id;
  final String shopId;
  final String name;
  final String? contactPerson;
  final String phone;
  final String? email;
  final String? categorySupplied;
  final bool isActive;
  final DateTime createdAt;

  Supplier({
    required this.id,
    required this.shopId,
    required this.name,
    this.contactPerson,
    required this.phone,
    this.email,
    this.categorySupplied,
    this.isActive = true,
    required this.createdAt,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'] as String,
      shopId: json['shop_id'] as String,
      name: json['name'] as String,
      contactPerson: json['contact_person'] as String?,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      categorySupplied: json['category_supplied'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop_id': shopId,
      'name': name,
      'contact_person': contactPerson,
      'phone': phone,
      'email': email,
      'category_supplied': categorySupplied,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

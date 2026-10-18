class Technician {
  final String id;
  final String shopId;
  final String name;
  final String phone;
  final String title; // e.g. 'designer', 'electrician', etc.
  final double commissionRate;
  final String? notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Technician({
    required this.id,
    required this.shopId,
    required this.name,
    required this.phone,
    required this.title,
    required this.commissionRate,
    this.notes,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Technician.fromJson(Map<String, dynamic> json) {
    return Technician(
      id: json['id'] as String,
      shopId: json['shop_id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      title: json['title'] as String,
      commissionRate: (json['commission_rate'] as num?)?.toDouble() ?? 5.0,
      notes: json['notes'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop_id': shopId,
      'name': name,
      'phone': phone,
      'title': title,
      'commission_rate': commissionRate,
      'notes': notes,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Technician copyWith({
    String? name,
    String? phone,
    String? title,
    double? commissionRate,
    String? notes,
    bool? isActive,
  }) {
    return Technician(
      id: id,
      shopId: shopId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      title: title ?? this.title,
      commissionRate: commissionRate ?? this.commissionRate,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

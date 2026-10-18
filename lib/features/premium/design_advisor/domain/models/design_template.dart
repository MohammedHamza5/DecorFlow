class DesignTemplate {
  final String id;
  final String? shopId;
  final String titleAr;
  final String? titleEn;
  final String? descriptionAr;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;

  DesignTemplate({
    required this.id,
    this.shopId,
    required this.titleAr,
    this.titleEn,
    this.descriptionAr,
    this.imageUrl,
    this.isActive = true,
    required this.createdAt,
  });

  factory DesignTemplate.fromJson(Map<String, dynamic> json) {
    return DesignTemplate(
      id: json['id'] as String,
      shopId: json['shop_id'] as String?,
      titleAr: json['title_ar'] as String,
      titleEn: json['title_en'] as String?,
      descriptionAr: json['description_ar'] as String?,
      imageUrl: json['image_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop_id': shopId,
      'title_ar': titleAr,
      'title_en': titleEn,
      'description_ar': descriptionAr,
      'image_url': imageUrl,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class WebQuote {
  final String id;
  final String quoteId;
  final String shareToken;
  final bool allowCustomization;
  final bool showAlternatives;
  final String? customerNotes;
  final DateTime? confirmedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  WebQuote({
    required this.id,
    required this.quoteId,
    required this.shareToken,
    this.allowCustomization = true,
    this.showAlternatives = true,
    this.customerNotes,
    this.confirmedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WebQuote.fromJson(Map<String, dynamic> json) {
    return WebQuote(
      id: json['id'] as String,
      quoteId: json['quote_id'] as String,
      shareToken: json['share_token'] as String,
      allowCustomization: json['allow_customization'] as bool? ?? true,
      showAlternatives: json['show_alternatives'] as bool? ?? true,
      customerNotes: json['customer_notes'] as String?,
      confirmedAt: json['confirmed_at'] != null
          ? DateTime.parse(json['confirmed_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quote_id': quoteId,
      'share_token': shareToken,
      'allow_customization': allowCustomization,
      'show_alternatives': showAlternatives,
      'customer_notes': customerNotes,
      'confirmed_at': confirmedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class TechnicianTransaction {
  final String id;
  final String shopId;
  final String technicianId;
  final String? invoiceId;
  final double amount;
  final String transactionType; // 'commission' (credit), 'withdrawal' (debit)
  final String status; // 'pending', 'completed', 'cancelled'
  final String? notes;
  final DateTime createdAt;

  TechnicianTransaction({
    required this.id,
    required this.shopId,
    required this.technicianId,
    this.invoiceId,
    required this.amount,
    required this.transactionType,
    required this.status,
    this.notes,
    required this.createdAt,
  });

  factory TechnicianTransaction.fromJson(Map<String, dynamic> json) {
    return TechnicianTransaction(
      id: json['id'] as String,
      shopId: json['shop_id'] as String,
      technicianId: json['technician_id'] as String,
      invoiceId: json['invoice_id'] as String?,
      amount: (json['amount'] as num).toDouble(),
      transactionType: json['transaction_type'] as String,
      status: json['status'] as String? ?? 'completed',
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop_id': shopId,
      'technician_id': technicianId,
      'invoice_id': invoiceId,
      'amount': amount,
      'transaction_type': transactionType,
      'status': status,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class PendingRecurringTransaction {
  final String id;
  final String categoryId;
  final String categoryName;
  final String type; 
  final double amount;
  final String? note;
  final DateTime transactionDate;
  final String? recurringId;
  final String status; 

  PendingRecurringTransaction({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.type,
    required this.amount,
    required this.transactionDate,
    required this.status,
    this.note,
    this.recurringId,
  });

  factory PendingRecurringTransaction.fromJson(Map<String, dynamic> json) {
    final category = json['category'] as Map<String, dynamic>?;
    return PendingRecurringTransaction(
      id: json['id'].toString(),
      categoryId: (json['category_id'] ?? category?['id'] ?? '').toString(),
      categoryName: (category?['name'] ?? 'Unknown').toString(),
      type: (json['type'] ?? 'expense').toString().toLowerCase(),
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      note: json['note'] == null ? null : json['note'].toString(),
      transactionDate:
          DateTime.tryParse(json['transaction_date'].toString()) ?? DateTime.now(),
      recurringId: json['recurring_id'] == null ? null : json['recurring_id'].toString(),
      status: (json['status'] ?? 'pending').toString().toLowerCase(),
    );
  }
}
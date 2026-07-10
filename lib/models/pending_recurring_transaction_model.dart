/// Represents one *occurrence* generated from a recurring transaction rule
/// that is waiting for the user to Accept or Reject it.
///
/// This is different from `RecurringTransactionItem` (the recurring *rule*
/// itself, managed on the Recurring Transactions screen). This model
/// mirrors the shape returned by `GET /transactions-recurring`:
///
/// {
///   "id": "01kx0dkezp8yq183jaqfx5vb8j",
///   "category_id": "01kwkafgtdns58dhwb47bczc34",
///   "type": "expense",
///   "amount": 9000,
///   "note": null,
///   "transaction_date": "2026-07-08",
///   "recurring_id": "01kx0djvht5nhsfmk94yw8g9p0",
///   "status": "pending",
///   "category": { "id": "01kwkafgtdns58dhwb47bczc34", "name": "cloth" }
/// }
class PendingRecurringTransaction {
  final String id;
  final String categoryId;
  final String categoryName;
  final String type; // 'expense' or 'income'
  final double amount;
  final String? note;
  final DateTime transactionDate;
  final String? recurringId;
  final String status; // 'pending' | 'accepted' | 'rejected'

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
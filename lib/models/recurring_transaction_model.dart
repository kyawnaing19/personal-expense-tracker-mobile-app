/// Model for a single Recurring Transaction record.
/// Mirrors the JSON shape returned by the backend for
/// GET/POST/PUT `/recurring-transactions`.
class RecurringTransactionItem {
  final String id;
  final String categoryId;
  final String type; // 'expense' or 'income'
  final double amount;
  final String note;
  final DateTime startDate;
  final DateTime? endDate;
  final String frequency; // 'daily' | 'weekly' | 'monthly'
  final DateTime? nextRunDate;
  final bool isActive;

  RecurringTransactionItem({
    required this.id,
    required this.categoryId,
    required this.type,
    required this.amount,
    required this.note,
    required this.startDate,
    required this.frequency,
    this.endDate,
    this.nextRunDate,
    this.isActive = true,
  });

  factory RecurringTransactionItem.fromJson(Map<String, dynamic> json) {
    return RecurringTransactionItem(
      id: json['id'].toString(),
      categoryId: json['category_id'].toString(),
      type: (json['type'] ?? 'expense').toString().toLowerCase(),
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      note: (json['note'] ?? '').toString(),
      startDate: DateTime.tryParse(json['start_date'].toString()) ?? DateTime.now(),
      endDate: json['end_date'] != null ? DateTime.tryParse(json['end_date'].toString()) : null,
      frequency: (json['frequency'] ?? 'monthly').toString().toLowerCase(),
      nextRunDate: json['next_run_date'] != null ? DateTime.tryParse(json['next_run_date'].toString()) : null,
      isActive: json['is_active'] == 1 || json['is_active'] == true,
    );
  }

  /// Human readable label for the frequency, matching the design
  /// ("Every Month" / "Every Weekly" / "Every Daily").
  String get frequencyLabel {
    switch (frequency) {
      case 'daily':
        return 'Every Daily';
      case 'weekly':
        return 'Every Weekly';
      case 'monthly':
      default:
        return 'Every Month';
    }
  }
}

abstract class RecurringTransactionEvent {}

// 1. List အားလုံး / Filter ဖြင့်ဆွဲမည့် Event
class LoadRecurringTransactions extends RecurringTransactionEvent {
  final String? type; // 'expense' | 'income' | null (All)
  final String? categoryId;

  LoadRecurringTransactions({this.type, this.categoryId});
}

// 2. အသစ်ဖန်တီးမည့် Event
class AddRecurringTransactionRequested extends RecurringTransactionEvent {
  final String categoryId;
  final double amount;
  final String frequency;
  final DateTime startDate;
  final String? note;

  AddRecurringTransactionRequested({
    required this.categoryId,
    required this.amount,
    required this.frequency,
    required this.startDate,
    this.note,
  });
}

// 3. ID ဖြင့်ပြန်ပြင်မည့် Event
class UpdateRecurringTransactionRequested extends RecurringTransactionEvent {
  final String id;
  final String categoryId;
  final double amount;
  final String frequency;
  final DateTime startDate;
  final String? note;

  UpdateRecurringTransactionRequested({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.frequency,
    required this.startDate,
    this.note,
  });
}

// 4. ID ဖြင့်ဖျက်မည့် Event
class DeleteRecurringTransactionRequested extends RecurringTransactionEvent {
  final String id;
  DeleteRecurringTransactionRequested(this.id);
}

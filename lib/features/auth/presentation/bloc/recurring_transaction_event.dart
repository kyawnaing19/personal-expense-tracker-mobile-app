abstract class RecurringTransactionEvent {}

class LoadRecurringTransactions extends RecurringTransactionEvent {
  final String? type; 
  final String? categoryId;

  LoadRecurringTransactions({this.type, this.categoryId});
}

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

class DeleteRecurringTransactionRequested extends RecurringTransactionEvent {
  final String id;
  DeleteRecurringTransactionRequested(this.id);
}

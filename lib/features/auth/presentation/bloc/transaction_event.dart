abstract class TransactionEvent {}

class LoadTransactions extends TransactionEvent {
  final Map<String, dynamic>? queryParams;
  LoadTransactions({this.queryParams});
}

class AddTransactionRequested extends TransactionEvent {
  final String categoryId;
  final double amount;
  final String note;

  AddTransactionRequested({
    required this.categoryId,
    required this.amount,
    required this.note,
  });
}
class UpdateTransactionRequested extends TransactionEvent {
  final String id;
  final double amount;
  final String note;

  UpdateTransactionRequested({
    required this.id,
    required this.amount,
    required this.note,
  });
}

class DeleteTransactionRequested extends TransactionEvent {
  final String id;

  DeleteTransactionRequested(this.id);
}
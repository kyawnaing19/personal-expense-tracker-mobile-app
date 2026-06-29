abstract class TransactionEvent {}

class LoadTransactions extends TransactionEvent {}

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
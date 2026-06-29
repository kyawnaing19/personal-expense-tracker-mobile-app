import 'package:expense_tracker/models/transaction_model.dart';

abstract class TransactionStateBase {}

class TransactionInitial extends TransactionStateBase {}
class TransactionLoading extends TransactionStateBase {}
class TransactionActionSuccess extends TransactionStateBase {} // Submit အောင်မြင်မှုပြရန်

class TransactionLoaded extends TransactionStateBase {
  final List<TransactionItem> transactions;
  TransactionLoaded(this.transactions);
}

class TransactionError extends TransactionStateBase {
  final String message;
  TransactionError(this.message);
}
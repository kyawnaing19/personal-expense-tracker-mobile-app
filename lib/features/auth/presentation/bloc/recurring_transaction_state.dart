import '../../../../models/recurring_transaction_model.dart';

abstract class RecurringTransactionStateBase {}

class RecurringTransactionInitial extends RecurringTransactionStateBase {}

class RecurringTransactionLoading extends RecurringTransactionStateBase {}

class RecurringTransactionActionSuccess extends RecurringTransactionStateBase {}

class RecurringTransactionLoaded extends RecurringTransactionStateBase {
  final List<RecurringTransactionItem> transactions;
  RecurringTransactionLoaded(this.transactions);
}

class RecurringTransactionError extends RecurringTransactionStateBase {
  final String message;
  RecurringTransactionError(this.message);
}

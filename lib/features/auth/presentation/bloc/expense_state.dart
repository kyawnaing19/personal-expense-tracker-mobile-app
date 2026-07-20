import '../../../../models/expense_model.dart';

abstract class ExpenseStateBase {}

class ExpenseInitial extends ExpenseStateBase {}

class ExpenseListLoading extends ExpenseStateBase {}

class ExpenseListLoaded extends ExpenseStateBase {
  final String groupId;
  final List<ExpenseModel> expenses;
  ExpenseListLoaded({required this.groupId, required this.expenses});
}

class ExpenseCreating extends ExpenseStateBase {}


class ExpenseCreateSuccess extends ExpenseStateBase {
  final ExpenseModel expense;
  ExpenseCreateSuccess(this.expense);
}

class ExpenseError extends ExpenseStateBase {
  final String message;
  ExpenseError(this.message);
}

class ExpenseDetailLoading extends ExpenseStateBase {}

class ExpenseDetailLoaded extends ExpenseStateBase {
  final ExpenseModel expense;
  ExpenseDetailLoaded(this.expense);
}

class ExpenseUpdating extends ExpenseStateBase {}

class ExpenseUpdateSuccess extends ExpenseStateBase {
  final ExpenseModel expense;
  ExpenseUpdateSuccess(this.expense);
}

class ExpenseDeleting extends ExpenseStateBase {}

class ExpenseDeleteSuccess extends ExpenseStateBase {
  final String expenseId;
  ExpenseDeleteSuccess(this.expenseId);
}
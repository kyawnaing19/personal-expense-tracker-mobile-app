import '../../data/expense_repository.dart';

abstract class ExpenseEvent {}

class LoadGroupExpenses extends ExpenseEvent {
  final String groupId;
  LoadGroupExpenses({required this.groupId});
}

class CreateExpenseRequested extends ExpenseEvent {
  final String groupId;
  final int amount;
  final String? description;
  final DateTime expenseDate;
  final String splitType; 
  final bool? includePayer; 
  final List<ExpenseSplitInput>? splits; 

  CreateExpenseRequested({
    required this.groupId,
    required this.amount,
    this.description,
    required this.expenseDate,
    required this.splitType,
    this.includePayer,
    this.splits,
  });
}

class LoadExpenseDetail extends ExpenseEvent {
  final String expenseId;
  LoadExpenseDetail({required this.expenseId});
}


class UpdateExpenseRequested extends ExpenseEvent {
  final String expenseId;
  final String groupId;
  final int amount;
  final String? description;
  final DateTime expenseDate;
  final String splitType; 
  final bool? includePayer;
  final List<ExpenseSplitInput>? splits;

  UpdateExpenseRequested({
    required this.expenseId,
    required this.groupId,
    required this.amount,
    this.description,
    required this.expenseDate,
    required this.splitType,
    this.includePayer,
    this.splits,
  });
}
class DeleteExpenseRequested extends ExpenseEvent {
  final String expenseId;
  final String groupId;
  DeleteExpenseRequested({required this.expenseId, required this.groupId});
}
abstract class BudgetEvent {}

class LoadBudgets extends BudgetEvent {
  final int month;
  final int year;
  LoadBudgets({required this.month, required this.year});
}

class CreateBudgetRequested extends BudgetEvent {
  final String categoryId;
  final double amount;
  final int alertPercentage;
  final int month;
  final int year;

  CreateBudgetRequested({
    required this.categoryId,
    required this.amount,
    required this.alertPercentage,
    required this.month,
    required this.year,
  });
}

class UpdateBudgetRequested extends BudgetEvent {
  final String id;
  final String categoryId;
  final double amount;
  final int alertPercentage;
  final int month; // kept only so the bloc can reload the correct month afterwards
  final int year;

  UpdateBudgetRequested({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.alertPercentage,
    required this.month,
    required this.year,
  });
}

class DeleteBudgetRequested extends BudgetEvent {
  final String id;
  final int month;
  final int year;

  DeleteBudgetRequested({required this.id, required this.month, required this.year});
}
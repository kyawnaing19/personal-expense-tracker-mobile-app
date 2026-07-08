import '../../../../models/budget_model.dart';

abstract class BudgetStateBase {}

class BudgetInitial extends BudgetStateBase {}

class BudgetLoading extends BudgetStateBase {}

class BudgetLoaded extends BudgetStateBase {
  final List<BudgetItem> budgets;
  final int month;
  final int year;
  BudgetLoaded(this.budgets, {required this.month, required this.year});
}

// Emitted right after a successful create/update/delete, before the list reloads
class BudgetActionSuccess extends BudgetStateBase {}

class BudgetError extends BudgetStateBase {
  final String message;
  BudgetError(this.message);
}
import '../../../../models/expense_model.dart';

abstract class ExpenseStateBase {}

class ExpenseInitial extends ExpenseStateBase {}

class ExpenseListLoading extends ExpenseStateBase {}

class ExpenseListLoaded extends ExpenseStateBase {
  final String groupId;
  final List<ExpenseModel> expenses;
  ExpenseListLoaded({required this.groupId, required this.expenses});
}

// Create Expense form ကနေ Done နှိပ်ပြီး submit ဖြစ်နေတုန်း (button loading spinner)
class ExpenseCreating extends ExpenseStateBase {}

// Create အောင်မြင်ပြီးတာနဲ့ (form ကို pop ဖို့ listener က သုံးမယ်)
class ExpenseCreateSuccess extends ExpenseStateBase {
  final ExpenseModel expense;
  ExpenseCreateSuccess(this.expense);
}

class ExpenseError extends ExpenseStateBase {
  final String message;
  ExpenseError(this.message);
}

// Expense Details page ကို ဝင်တာနဲ့ GET /group-expenses/{id} loading
class ExpenseDetailLoading extends ExpenseStateBase {}

class ExpenseDetailLoaded extends ExpenseStateBase {
  final ExpenseModel expense;
  ExpenseDetailLoaded(this.expense);
}

// Edit form ရဲ့ Save ခလုတ် submit ဖြစ်နေတုန်း (button loading spinner)
class ExpenseUpdating extends ExpenseStateBase {}

// Update အောင်မြင်ပြီးတာနဲ့ (Edit form ကို pop ဖို့ listener က သုံးမယ်)
class ExpenseUpdateSuccess extends ExpenseStateBase {
  final ExpenseModel expense;
  ExpenseUpdateSuccess(this.expense);
}

// Delete ခလုတ် submit ဖြစ်နေတုန်း (button loading spinner)
class ExpenseDeleting extends ExpenseStateBase {}

// Delete အောင်မြင်ပြီးတာနဲ့ (Details page ကို pop ဖို့ listener က သုံးမယ်)
class ExpenseDeleteSuccess extends ExpenseStateBase {
  final String expenseId;
  ExpenseDeleteSuccess(this.expenseId);
}
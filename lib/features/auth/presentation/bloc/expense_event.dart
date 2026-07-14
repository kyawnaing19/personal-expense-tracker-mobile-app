import '../../data/expense_repository.dart';

abstract class ExpenseEvent {}

// Group Detail screen ဝင်တာနဲ့ / refresh လုပ်တာနဲ့ expense list ကို ခေါ်ဖို့
class LoadGroupExpenses extends ExpenseEvent {
  final String groupId;
  LoadGroupExpenses({required this.groupId});
}

// Create Expense form ရဲ့ Done ခလုတ်ကနေ ပို့မယ့် event
class CreateExpenseRequested extends ExpenseEvent {
  final String groupId;
  final int amount;
  final String? description;
  final DateTime expenseDate;
  final String splitType; // 'equally' | 'custom'
  final bool? includePayer; // 'equally' အတွက်သာ - Include Me / Exclude Me
  final List<ExpenseSplitInput>? splits; // 'custom' အတွက်သာ

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

// Expense Card ကို နှိပ်ပြီး Expense Details page ကိုသွားတဲ့အခါ ခေါ်မယ့် event
class LoadExpenseDetail extends ExpenseEvent {
  final String expenseId;
  LoadExpenseDetail({required this.expenseId});
}

// Expense Details page ရဲ့ Edit form ကနေ Save ခလုတ်ကနေ ပို့မယ့် event -
// update ပြီးနောက် GroupDetailScreen ရဲ့ list ကိုပါ refresh ဖို့ groupId
// ပါလိုက်ပို့ရမယ်
class UpdateExpenseRequested extends ExpenseEvent {
  final String expenseId;
  final String groupId;
  final int amount;
  final String? description;
  final DateTime expenseDate;
  final String splitType; // 'equally' | 'custom'
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

// Expense Details page ရဲ့ Delete ခလုတ်ကနေ ပို့မယ့် event - delete ပြီးနောက်
// GroupDetailScreen ရဲ့ list ကိုပါ refresh ဖို့ groupId ပါလိုက်ပို့ရမယ်
class DeleteExpenseRequested extends ExpenseEvent {
  final String expenseId;
  final String groupId;
  DeleteExpenseRequested({required this.expenseId, required this.groupId});
}
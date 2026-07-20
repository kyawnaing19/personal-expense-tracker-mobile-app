import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/expense_repository.dart';
import 'expense_event.dart';
import 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseStateBase> {
  final ExpenseRepository _repository;

  ExpenseBloc(this._repository) : super(ExpenseInitial()) {
    on<LoadGroupExpenses>(_onLoadGroupExpenses);
    on<CreateExpenseRequested>(_onCreateExpense);
    on<LoadExpenseDetail>(_onLoadExpenseDetail);
    on<UpdateExpenseRequested>(_onUpdateExpense);
    on<DeleteExpenseRequested>(_onDeleteExpense);
  }

  Future<void> _onLoadGroupExpenses(
      LoadGroupExpenses event, Emitter<ExpenseStateBase> emit) async {
    emit(ExpenseListLoading());
    try {
      final expenses = await _repository.getGroupExpenses(event.groupId);
      emit(ExpenseListLoaded(groupId: event.groupId, expenses: expenses));
    } catch (e) {
      emit(ExpenseError(e.toString().replaceAll("Exception: ", "")));
    }
  }

  Future<void> _onCreateExpense(
      CreateExpenseRequested event, Emitter<ExpenseStateBase> emit) async {
    emit(ExpenseCreating());
    try {
      final expense = await _repository.createExpense(
        groupId: event.groupId,
        amount: event.amount,
        description: event.description,
        expenseDate: event.expenseDate,
        splitType: event.splitType,
        includePayer: event.includePayer,
        splits: event.splits,
      );
      emit(ExpenseCreateSuccess(expense));
      final expenses = await _repository.getGroupExpenses(event.groupId);
      emit(ExpenseListLoaded(groupId: event.groupId, expenses: expenses));
    } catch (e) {
      emit(ExpenseError(e.toString().replaceAll("Exception: ", "")));
    }
  }

  Future<void> _onLoadExpenseDetail(
      LoadExpenseDetail event, Emitter<ExpenseStateBase> emit) async {
    emit(ExpenseDetailLoading());
    try {
      final expense = await _repository.getExpenseDetail(event.expenseId);
      emit(ExpenseDetailLoaded(expense));
    } catch (e) {
      emit(ExpenseError(e.toString().replaceAll("Exception: ", "")));
    }
  }

  Future<void> _onUpdateExpense(
      UpdateExpenseRequested event, Emitter<ExpenseStateBase> emit) async {
    emit(ExpenseUpdating());
    try {
      final expense = await _repository.updateExpense(
        expenseId: event.expenseId,
        amount: event.amount,
        description: event.description,
        expenseDate: event.expenseDate,
        splitType: event.splitType,
        includePayer: event.includePayer,
        splits: event.splits,
      );
      emit(ExpenseUpdateSuccess(expense));
      final freshExpense =
          await _repository.getExpenseDetail(event.expenseId);
      emit(ExpenseDetailLoaded(freshExpense));
      final expenses = await _repository.getGroupExpenses(event.groupId);
      emit(ExpenseListLoaded(groupId: event.groupId, expenses: expenses));
    } catch (e) {
      emit(ExpenseError(e.toString().replaceAll("Exception: ", "")));
    }
  }

  Future<void> _onDeleteExpense(
      DeleteExpenseRequested event, Emitter<ExpenseStateBase> emit) async {
    emit(ExpenseDeleting());
    try {
      await _repository.deleteExpense(event.expenseId);
      emit(ExpenseDeleteSuccess(event.expenseId));
      final expenses = await _repository.getGroupExpenses(event.groupId);
      emit(ExpenseListLoaded(groupId: event.groupId, expenses: expenses));
    } catch (e) {
      emit(ExpenseError(e.toString().replaceAll("Exception: ", "")));
    }
  }
}
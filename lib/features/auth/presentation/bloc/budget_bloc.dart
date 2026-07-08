import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/budget_repository.dart';
import 'budget_event.dart';
import 'budget_state.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetStateBase> {
  final BudgetRepository _repository;

  BudgetBloc(this._repository) : super(BudgetInitial()) {
    on<LoadBudgets>(_onLoadBudgets);
    on<CreateBudgetRequested>(_onCreateBudget);
    on<UpdateBudgetRequested>(_onUpdateBudget);
    on<DeleteBudgetRequested>(_onDeleteBudget);
  }

  Future<void> _onLoadBudgets(LoadBudgets event, Emitter<BudgetStateBase> emit) async {
    emit(BudgetLoading());
    try {
      final budgets = await _repository.getBudgets(month: event.month, year: event.year);
      emit(BudgetLoaded(budgets, month: event.month, year: event.year));
    } catch (e) {
      emit(BudgetError(e.toString().replaceAll("Exception: ", "")));
    }
  }

  Future<void> _onCreateBudget(CreateBudgetRequested event, Emitter<BudgetStateBase> emit) async {
    emit(BudgetLoading());
    try {
      await _repository.createBudget(
        categoryId: event.categoryId,
        amount: event.amount,
        alertPercentage: event.alertPercentage,
        month: event.month,
        year: event.year,
      );
      emit(BudgetActionSuccess());
      final budgets = await _repository.getBudgets(month: event.month, year: event.year);
      emit(BudgetLoaded(budgets, month: event.month, year: event.year));
    } catch (e) {
      emit(BudgetError(e.toString().replaceAll("Exception: ", "")));
    }
  }

  Future<void> _onUpdateBudget(UpdateBudgetRequested event, Emitter<BudgetStateBase> emit) async {
    emit(BudgetLoading());
    try {
      await _repository.updateBudget(
        id: event.id,
        categoryId: event.categoryId,
        amount: event.amount,
        alertPercentage: event.alertPercentage,
      );
      emit(BudgetActionSuccess());
      final budgets = await _repository.getBudgets(month: event.month, year: event.year);
      emit(BudgetLoaded(budgets, month: event.month, year: event.year));
    } catch (e) {
      emit(BudgetError(e.toString().replaceAll("Exception: ", "")));
    }
  }

  Future<void> _onDeleteBudget(DeleteBudgetRequested event, Emitter<BudgetStateBase> emit) async {
    emit(BudgetLoading());
    try {
      await _repository.deleteBudget(event.id);
      emit(BudgetActionSuccess());
      final budgets = await _repository.getBudgets(month: event.month, year: event.year);
      emit(BudgetLoaded(budgets, month: event.month, year: event.year));
    } catch (e) {
      emit(BudgetError(e.toString().replaceAll("Exception: ", "")));
      final budgets = await _repository.getBudgets(month: event.month, year: event.year);
      emit(BudgetLoaded(budgets, month: event.month, year: event.year));
    }
  }
}
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/recurring_transaction_repository.dart';
import 'recurring_transaction_event.dart';
import 'recurring_transaction_state.dart';

class RecurringTransactionBloc extends Bloc<RecurringTransactionEvent, RecurringTransactionStateBase> {
  final RecurringTransactionRepository _repository;

  RecurringTransactionBloc(this._repository) : super(RecurringTransactionInitial()) {
    on<LoadRecurringTransactions>(_onLoad);
    on<AddRecurringTransactionRequested>(_onAdd);
    on<UpdateRecurringTransactionRequested>(_onUpdate);
    on<DeleteRecurringTransactionRequested>(_onDelete);
  }

  Future<void> _onLoad(LoadRecurringTransactions event, Emitter<RecurringTransactionStateBase> emit) async {
    emit(RecurringTransactionLoading());
    try {
      final list = await _repository.getRecurringTransactions(type: event.type, categoryId: event.categoryId);
      emit(RecurringTransactionLoaded(list));
    } catch (e) {
      emit(RecurringTransactionError(e.toString()));
    }
  }

  Future<void> _onAdd(AddRecurringTransactionRequested event, Emitter<RecurringTransactionStateBase> emit) async {
    emit(RecurringTransactionLoading());
    try {
      await _repository.createRecurringTransaction(
        categoryId: event.categoryId,
        amount: event.amount,
        frequency: event.frequency,
        startDate: event.startDate,
        note: event.note,
      );
      emit(RecurringTransactionActionSuccess());
    } catch (e) {
      emit(RecurringTransactionError(e.toString()));
    }
  }

  Future<void> _onUpdate(UpdateRecurringTransactionRequested event, Emitter<RecurringTransactionStateBase> emit) async {
    emit(RecurringTransactionLoading());
    try {
      await _repository.updateRecurringTransaction(
        id: event.id,
        categoryId: event.categoryId,
        amount: event.amount,
        frequency: event.frequency,
        startDate: event.startDate,
        note: event.note,
      );
      emit(RecurringTransactionActionSuccess());
    } catch (e) {
      emit(RecurringTransactionError(e.toString()));
    }
  }

  Future<void> _onDelete(DeleteRecurringTransactionRequested event, Emitter<RecurringTransactionStateBase> emit) async {
    emit(RecurringTransactionLoading());
    try {
      await _repository.deleteRecurringTransaction(event.id);
      emit(RecurringTransactionActionSuccess());
    } catch (e) {
      emit(RecurringTransactionError(e.toString()));
    }
  }
}

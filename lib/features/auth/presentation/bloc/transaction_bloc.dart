import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/transaction_repository.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionStateBase> {
  final TransactionRepository _repository;

  TransactionBloc(this._repository) : super(TransactionInitial()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<AddTransactionRequested>(_onAddTransaction);
  }

  Future<void> _onLoadTransactions(LoadTransactions event, Emitter<TransactionStateBase> emit) async {
    emit(TransactionLoading());
    try {
      final transactions = await _repository.getTransactions();
      emit(TransactionLoaded(transactions));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onAddTransaction(AddTransactionRequested event, Emitter<TransactionStateBase> emit) async {
    emit(TransactionLoading());
    try {
      await _repository.createTransaction(
        categoryId: event.categoryId,
        amount: event.amount,
        note: event.note,
      );
      emit(TransactionActionSuccess());
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }
}
// import 'package:expense_tracker/features/auth/data/transaction_repository.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'transaction_event.dart';
// import 'transaction_state.dart';

// class TransactionBloc extends Bloc<TransactionEvent, TransactionStateBase> {
//   final TransactionRepository _repository;

//   TransactionBloc(this._repository) : super(TransactionInitial()) {
//     on<LoadTransactions>(_onLoadTransactions);
//     on<AddTransactionRequested>(_onAddTransaction);
//     on<UpdateTransactionRequested>(_onUpdateTransaction);
//     on<DeleteTransactionRequested>(_onDeleteTransaction);
//   }

//   Future<void> _onLoadTransactions(LoadTransactions event, Emitter<TransactionStateBase> emit) async {
//     emit(TransactionLoading());
//     try {
//       // 🎯 Event က ပါလာတဲ့ queryParams ကို Repository ဆီ ထည့်ပေးလိုက်ပါတယ်
//       final transactions = await _repository.getTransactions(queryParams: event.queryParams);
//       emit(TransactionLoaded(transactions));
//     } catch (e) {
//       emit(TransactionError(e.toString()));
//     }
//   }

//   Future<void> _onAddTransaction(AddTransactionRequested event, Emitter<TransactionStateBase> emit) async {
//     emit(TransactionLoading());
//     try {
//       await _repository.createTransaction(categoryId: event.categoryId, amount: event.amount, note: event.note);
//       emit(TransactionActionSuccess());
//     } catch (e) { emit(TransactionError(e.toString())); }
//   }

//   Future<void> _onUpdateTransaction(UpdateTransactionRequested event, Emitter<TransactionStateBase> emit) async {
//     emit(TransactionLoading());
//     try {
//       await _repository.updateTransaction(id: event.id, amount: event.amount, note: event.note);
//       emit(TransactionActionSuccess());
//     } catch (e) { emit(TransactionError(e.toString())); }
//   }

//   Future<void> _onDeleteTransaction(DeleteTransactionRequested event, Emitter<TransactionStateBase> emit) async {
//     emit(TransactionLoading());
//     try {
//       await _repository.deleteTransaction(event.id);
//       emit(TransactionActionSuccess());
//     } catch (e) { emit(TransactionError(e.toString())); }
//   }
// }

import 'package:expense_tracker/features/auth/data/transaction_repository.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/analytics_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionStateBase> {
  final TransactionRepository _repository;

  TransactionBloc(this._repository) : super(TransactionInitial()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<AddTransactionRequested>(_onAddTransaction);
    on<UpdateTransactionRequested>(_onUpdateTransaction);
    on<DeleteTransactionRequested>(_onDeleteTransaction);
  }

  Future<void> _onLoadTransactions(LoadTransactions event, Emitter<TransactionStateBase> emit) async {
    emit(TransactionLoading());
    try {
      // 🎯 Event က ပါလာတဲ့ queryParams ကို Repository ဆီ ထည့်ပေးလိုက်ပါတယ်
      final transactions = await _repository.getTransactions(queryParams: event.queryParams);
      emit(TransactionLoaded(transactions));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onAddTransaction(AddTransactionRequested event, Emitter<TransactionStateBase> emit) async {
    emit(TransactionLoading());
    try {
      await _repository.createTransaction(categoryId: event.categoryId, amount: event.amount, note: event.note);
      AnalyticsBloc.markDirty(); // 🆕 transaction အသစ်ထည့်လိုက်တာကြောင့် analytics ကို stale သတ်မှတ်
      emit(TransactionActionSuccess());
    } catch (e) { emit(TransactionError(e.toString())); }
  }

  Future<void> _onUpdateTransaction(UpdateTransactionRequested event, Emitter<TransactionStateBase> emit) async {
    emit(TransactionLoading());
    try {
      await _repository.updateTransaction(id: event.id, amount: event.amount, note: event.note);
      AnalyticsBloc.markDirty(); // 🆕 transaction ပြင်လိုက်တာကြောင့် analytics ကို stale သတ်မှတ်
      emit(TransactionActionSuccess());
    } catch (e) { emit(TransactionError(e.toString())); }
  }

  Future<void> _onDeleteTransaction(DeleteTransactionRequested event, Emitter<TransactionStateBase> emit) async {
    emit(TransactionLoading());
    try {
      await _repository.deleteTransaction(event.id);
      AnalyticsBloc.markDirty(); // 🆕 transaction ဖျက်လိုက်တာကြောင့် analytics ကို stale သတ်မှတ်
      emit(TransactionActionSuccess());
    } catch (e) { emit(TransactionError(e.toString())); }
  }
}
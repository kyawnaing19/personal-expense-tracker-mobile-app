import 'package:expense_tracker/features/auth/data/balance_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'balance_event.dart';
import 'balance_state.dart';

class BalanceBloc extends Bloc<BalanceEvent, BalanceStateBase> {
  final BalanceRepository _repository;

  BalanceBloc(this._repository) : super(BalanceInitial()) {
    on<LoadGroupBalance>(_onLoadGroupBalance);
    on<LoadMemberBalanceDetail>(_onLoadMemberBalanceDetail);
    on<LoadSettlementHistory>(_onLoadSettlementHistory);
  }

  Future<void> _onLoadGroupBalance(
      LoadGroupBalance event, Emitter<BalanceStateBase> emit) async {
    emit(BalanceListLoading());
    try {
      final members = await _repository.getGroupBalance(event.groupId);
      emit(BalanceListLoaded(groupId: event.groupId, members: members));
    } catch (e) {
      emit(BalanceError(e.toString().replaceAll("Exception: ", "")));
    }
  }

  Future<void> _onLoadMemberBalanceDetail(
      LoadMemberBalanceDetail event, Emitter<BalanceStateBase> emit) async {
    emit(BalanceDetailLoading());
    try {
      final detail = await _repository.getMemberBalanceDetails(
        groupId: event.groupId,
        userId: event.userId,
      );
      emit(BalanceDetailLoaded(userId: event.userId, detail: detail));
    } catch (e) {
      emit(BalanceError(e.toString().replaceAll("Exception: ", "")));
    }
  }

  Future<void> _onLoadSettlementHistory(
    LoadSettlementHistory event, Emitter<BalanceStateBase> emit) async {
  emit(SettlementHistoryLoading());
  try {
    final history = await _repository.getSettlementHistory(
      groupId: event.groupId,
      userId: event.userId,
    );
    emit(SettlementHistoryLoaded(userId: event.userId, history: history));
  } catch (e) {
    emit(BalanceError(e.toString().replaceAll("Exception: ", "")));
  }
}
}
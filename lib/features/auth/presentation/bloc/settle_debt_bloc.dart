import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/expense_split_repository.dart';
import 'settle_debt_event.dart';
import 'settle_debt_state.dart';

class SettleDebtBloc extends Bloc<SettleDebtEvent, SettleDebtStateBase> {
  final ExpenseSplitRepository _repository;

  SettleDebtBloc(this._repository) : super(SettleDebtInitial()) {
    on<LoadMySplits>(_onLoadMySplits);
    on<ClaimPaymentRequested>(_onClaimPaymentRequested);
  }

  Future<void> _onLoadMySplits(
      LoadMySplits event, Emitter<SettleDebtStateBase> emit) async {
    emit(SettleDebtLoading());
    try {
      final splits = await _repository.getMySplits();
      final unsettled = splits
          .where((s) => !s.isSettled && s.remainingAmount > 0)
          .toList();
      emit(SettleDebtLoaded(splits: unsettled));
    } catch (e) {
      emit(SettleDebtError(e.toString().replaceAll("Exception: ", "")));
    }
  }

Future<void> _onClaimPaymentRequested(ClaimPaymentRequested event,
    Emitter<SettleDebtStateBase> emit) async {
  final current = state;
  if (current is! SettleDebtLoaded) return;

  final pending = {...current.pendingClaimSplitIds, event.splitId};
  emit(current.copyWith(pendingClaimSplitIds: pending));

  try {
    await _repository.claimPayment(
      splitId: event.splitId,
      amount: event.amount,
    );

    final newSplits = current.splits.map((s) {
      if (s.id != event.splitId) return s;
      return s.copyWith(hasPendingClaim: true);
    }).toList();

    final stillPending = {...pending}..remove(event.splitId);

    emit(ClaimPaymentSuccess(
      splitId: event.splitId,
      splits: newSplits,
      pendingClaimSplitIds: stillPending,
    ));
    emit(SettleDebtLoaded(
      splits: newSplits,
      pendingClaimSplitIds: stillPending,
    ));
  } catch (e) {
    final stillPending = {...pending}..remove(event.splitId);
    emit(SettleDebtError(e.toString().replaceAll("Exception: ", "")));
    emit(current.copyWith(pendingClaimSplitIds: stillPending));
  }
}
}
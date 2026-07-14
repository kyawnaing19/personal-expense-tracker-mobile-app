import 'package:expense_tracker/models/balance_model.dart';

abstract class BalanceStateBase {}

class BalanceInitial extends BalanceStateBase {}

class BalanceListLoading extends BalanceStateBase {}

class BalanceListLoaded extends BalanceStateBase {
  final String groupId;
  final List<MemberBalanceModel> members;
  BalanceListLoaded({required this.groupId, required this.members});
}

class BalanceDetailLoading extends BalanceStateBase {}

class BalanceDetailLoaded extends BalanceStateBase {
  final String userId;
  final MemberBalanceDetailModel detail;
  BalanceDetailLoaded({required this.userId, required this.detail});
}

class BalanceError extends BalanceStateBase {
  final String message;
  BalanceError(this.message);
}

// balance_state.dart
class SettlementHistoryLoading extends BalanceStateBase {}

class SettlementHistoryLoaded extends BalanceStateBase {
  final String userId;
  final SettlementHistoryModel history;
  SettlementHistoryLoaded({required this.userId, required this.history});
}
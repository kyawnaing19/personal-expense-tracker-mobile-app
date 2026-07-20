abstract class SettleDebtEvent {}

class LoadMySplits extends SettleDebtEvent {}

class ClaimPaymentRequested extends SettleDebtEvent {
  final String splitId;
  final int amount;

  ClaimPaymentRequested({required this.splitId, required this.amount});
}
abstract class SettleDebtEvent {}

// Settle Debt screen ဝင်တာနဲ့ / pull-to-refresh လုပ်တာနဲ့ debt list ခေါ်ဖို့
class LoadMySplits extends SettleDebtEvent {}

// "Settle Now" -> Pay Amount dialog ထဲက "Done" ကိုနှိပ်လိုက်ရင်
class ClaimPaymentRequested extends SettleDebtEvent {
  final String splitId;
  final int amount;

  ClaimPaymentRequested({required this.splitId, required this.amount});
}
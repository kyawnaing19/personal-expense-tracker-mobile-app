import '../../../../models/expense_split_model.dart';

abstract class SettleDebtStateBase {}

class SettleDebtInitial extends SettleDebtStateBase {}

class SettleDebtLoading extends SettleDebtStateBase {}

class SettleDebtLoaded extends SettleDebtStateBase {
  final List<ExpenseSplitModel> splits;

  // claim-payment API ကို ခေါ်နေဆဲဖြစ်တဲ့ split id တွေ (ဒီ card ရဲ့
  // "Settle Now" ခလုတ်ကို loading/disabled ပြဖို့)
  final Set<String> pendingClaimSplitIds;

  SettleDebtLoaded({
    required this.splits,
    this.pendingClaimSplitIds = const {},
  });

  SettleDebtLoaded copyWith({
    List<ExpenseSplitModel>? splits,
    Set<String>? pendingClaimSplitIds,
  }) {
    return SettleDebtLoaded(
      splits: splits ?? this.splits,
      pendingClaimSplitIds: pendingClaimSplitIds ?? this.pendingClaimSplitIds,
    );
  }
}

// claim-payment တစ်ခုအောင်မြင်ရင် တိုတိုတိုးဖြစ်ပေါ်တဲ့ transient state
// (SnackBar ပြဖို့) - ပြီးရင် ချက်ချင်း SettleDebtLoaded ဆီ ပြန်ပြောင်းမယ်
class ClaimPaymentSuccess extends SettleDebtStateBase {
  final String splitId;
  final List<ExpenseSplitModel> splits;
  final Set<String> pendingClaimSplitIds;

  ClaimPaymentSuccess({
    required this.splitId,
    required this.splits,
    this.pendingClaimSplitIds = const {},
  });
}

class SettleDebtError extends SettleDebtStateBase {
  final String message;
  SettleDebtError(this.message);
}
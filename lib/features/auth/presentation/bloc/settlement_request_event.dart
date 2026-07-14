import '../../../../models/settlement_request_model.dart';

abstract class SettlementRequestEvent {}

// Debt Requests screen ဝင်တာနဲ့ / tab ပြောင်းတာနဲ့ / pull-to-refresh
// လုပ်တာနဲ့ list ကို (re)load လုပ်ဖို့
class LoadSettlementRequests extends SettlementRequestEvent {
  final SettlementRequestRole role;
  LoadSettlementRequests({required this.role});
}

// "Received Requests" <-> "Sent Requests" navigation bar ကိုနှိပ်လိုက်ရင်
class ChangeSettlementRequestRole extends SettlementRequestEvent {
  final SettlementRequestRole role;
  ChangeSettlementRequestRole(this.role);
}

// Filter bottom sheet ထဲက "OK" ကိုနှိပ်လိုက်ရင် (status == null ဆိုရင် "Clear Filter")
class ApplyStatusFilter extends SettlementRequestEvent {
  final SettlementRequestStatus? status;
  ApplyStatusFilter(this.status);
}

// "Confirm" ခလုတ်
class ConfirmSettlementRequested extends SettlementRequestEvent {
  final String requestId;
  ConfirmSettlementRequested(this.requestId);
}

// "Reject" ခလုတ်
class RejectSettlementRequested extends SettlementRequestEvent {
  final String requestId;
  RejectSettlementRequested(this.requestId);
}
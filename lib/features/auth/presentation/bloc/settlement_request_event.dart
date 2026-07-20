import '../../../../models/settlement_request_model.dart';

abstract class SettlementRequestEvent {}

class LoadSettlementRequests extends SettlementRequestEvent {
  final SettlementRequestRole role;
  LoadSettlementRequests({required this.role});
}

class ChangeSettlementRequestRole extends SettlementRequestEvent {
  final SettlementRequestRole role;
  ChangeSettlementRequestRole(this.role);
}

class ApplyStatusFilter extends SettlementRequestEvent {
  final SettlementRequestStatus? status;
  ApplyStatusFilter(this.status);
}

class ConfirmSettlementRequested extends SettlementRequestEvent {
  final String requestId;
  ConfirmSettlementRequested(this.requestId);
}

class RejectSettlementRequested extends SettlementRequestEvent {
  final String requestId;
  RejectSettlementRequested(this.requestId);
}
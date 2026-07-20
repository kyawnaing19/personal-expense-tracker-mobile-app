import '../../../../models/settlement_request_model.dart';

abstract class SettlementRequestStateBase {}

class SettlementRequestInitial extends SettlementRequestStateBase {}

class SettlementRequestLoading extends SettlementRequestStateBase {
  final SettlementRequestRole role;
  final SettlementRequestStatus? statusFilter;
  SettlementRequestLoading({required this.role, this.statusFilter});
}

class SettlementRequestLoaded extends SettlementRequestStateBase {
  final SettlementRequestRole role;
  final SettlementRequestStatus? statusFilter;
  final List<SettlementRequestModel> requests;
  final Set<String> processingRequestIds;

  SettlementRequestLoaded({
    required this.role,
    this.statusFilter,
    required this.requests,
    this.processingRequestIds = const {},
  });

  SettlementRequestLoaded copyWith({
    SettlementRequestRole? role,
    SettlementRequestStatus? statusFilter,
    bool clearStatusFilter = false,
    List<SettlementRequestModel>? requests,
    Set<String>? processingRequestIds,
  }) {
    return SettlementRequestLoaded(
      role: role ?? this.role,
      statusFilter:
          clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
      requests: requests ?? this.requests,
      processingRequestIds:
          processingRequestIds ?? this.processingRequestIds,
    );
  }
}

class SettlementRequestActionError extends SettlementRequestStateBase {
  final SettlementRequestRole role;
  final SettlementRequestStatus? statusFilter;
  final List<SettlementRequestModel> requests;
  final String message;

  SettlementRequestActionError({
    required this.role,
    this.statusFilter,
    required this.requests,
    required this.message,
  });
}

class SettlementRequestError extends SettlementRequestStateBase {
  final SettlementRequestRole role;
  final SettlementRequestStatus? statusFilter;
  final String message;
  SettlementRequestError(
    this.message, {
    required this.role,
    this.statusFilter,
  });
}
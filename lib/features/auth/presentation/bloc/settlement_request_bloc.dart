import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/settlement_request_repository.dart';
import '../../../../models/settlement_request_model.dart';
import 'settlement_request_event.dart';
import 'settlement_request_state.dart';

class SettlementRequestBloc
    extends Bloc<SettlementRequestEvent, SettlementRequestStateBase> {
  final SettlementRequestRepository _repository;

  SettlementRequestBloc(this._repository)
      : super(SettlementRequestInitial()) {
    on<LoadSettlementRequests>(_onLoadSettlementRequests);
    on<ChangeSettlementRequestRole>(_onChangeRole);
    on<ApplyStatusFilter>(_onApplyStatusFilter);
    on<ConfirmSettlementRequested>(_onConfirmRequested);
    on<RejectSettlementRequested>(_onRejectRequested);
  }

  SettlementRequestStatus? _currentStatusFilter() {
    final current = state;
    if (current is SettlementRequestLoaded) return current.statusFilter;
    if (current is SettlementRequestLoading) return current.statusFilter;
    if (current is SettlementRequestError) return current.statusFilter;
    return null;
  }

  Future<void> _fetch(
    SettlementRequestRole role,
    SettlementRequestStatus? statusFilter,
    Emitter<SettlementRequestStateBase> emit,
  ) async {
    emit(SettlementRequestLoading(role: role, statusFilter: statusFilter));
    try {
      final requests = await _repository.getSettlementRequests(
        role: role,
        status: statusFilter,
      );
      emit(SettlementRequestLoaded(
        role: role,
        statusFilter: statusFilter,
        requests: requests,
      ));
    } catch (e) {
      emit(SettlementRequestError(
        e.toString().replaceAll("Exception: ", ""),
        role: role,
        statusFilter: statusFilter,
      ));
    }
  }

  Future<void> _onLoadSettlementRequests(LoadSettlementRequests event,
      Emitter<SettlementRequestStateBase> emit) async {
    await _fetch(event.role, _currentStatusFilter(), emit);
  }

  Future<void> _onChangeRole(ChangeSettlementRequestRole event,
      Emitter<SettlementRequestStateBase> emit) async {
    await _fetch(event.role, _currentStatusFilter(), emit);
  }

  Future<void> _onApplyStatusFilter(
      ApplyStatusFilter event, Emitter<SettlementRequestStateBase> emit) async {
    final current = state;
    SettlementRequestRole role = SettlementRequestRole.payer;
    if (current is SettlementRequestLoaded) role = current.role;
    if (current is SettlementRequestLoading) role = current.role;
    if (current is SettlementRequestError) role = current.role;
    await _fetch(role, event.status, emit);
  }

  Future<void> _onConfirmRequested(ConfirmSettlementRequested event,
      Emitter<SettlementRequestStateBase> emit) async {
    final current = state;
    if (current is! SettlementRequestLoaded) return;

    final processing = {...current.processingRequestIds, event.requestId};
    emit(current.copyWith(processingRequestIds: processing));

    try {
      await _repository.confirmRequest(event.requestId);
      final requests = await _repository.getSettlementRequests(
        role: current.role,
        status: current.statusFilter,
      );
      emit(SettlementRequestLoaded(
        role: current.role,
        statusFilter: current.statusFilter,
        requests: requests,
      ));
    } catch (e) {
      final stillProcessing = {...current.processingRequestIds}
        ..remove(event.requestId);
      emit(SettlementRequestActionError(
        role: current.role,
        statusFilter: current.statusFilter,
        requests: current.requests,
        message: e.toString().replaceAll("Exception: ", ""),
      ));
      emit(current.copyWith(processingRequestIds: stillProcessing));
    }
  }

  Future<void> _onRejectRequested(RejectSettlementRequested event,
      Emitter<SettlementRequestStateBase> emit) async {
    final current = state;
    if (current is! SettlementRequestLoaded) return;

    final processing = {...current.processingRequestIds, event.requestId};
    emit(current.copyWith(processingRequestIds: processing));

    try {
      await _repository.rejectRequest(event.requestId);
      final requests = await _repository.getSettlementRequests(
        role: current.role,
        status: current.statusFilter,
      );
      emit(SettlementRequestLoaded(
        role: current.role,
        statusFilter: current.statusFilter,
        requests: requests,
      ));
    } catch (e) {
      final stillProcessing = {...current.processingRequestIds}
        ..remove(event.requestId);
      emit(SettlementRequestActionError(
        role: current.role,
        statusFilter: current.statusFilter,
        requests: current.requests,
        message: e.toString().replaceAll("Exception: ", ""),
      ));
      emit(current.copyWith(processingRequestIds: stillProcessing));
    }
  }
}
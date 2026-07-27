import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'connectivity_service.dart';

enum ConnectivityStatus { initial, online, offline }

class ConnectivityState {
  final ConnectivityStatus status;
  final ConnectivityStatus previousStatus;

  const ConnectivityState({
    required this.status,
    required this.previousStatus,
  });

  bool get isOnline => status == ConnectivityStatus.online;
  bool get isOffline => status == ConnectivityStatus.offline;

  bool get justReconnected =>
      status == ConnectivityStatus.online &&
      previousStatus == ConnectivityStatus.offline;

  ConnectivityState copyWith({ConnectivityStatus? status}) {
    return ConnectivityState(
      status: status ?? this.status,
      previousStatus: this.status,
    );
  }
}

class ConnectivityCubit extends Cubit<ConnectivityState> {
  ConnectivityCubit()
      : super(const ConnectivityState(
          status: ConnectivityStatus.initial,
          previousStatus: ConnectivityStatus.initial,
        )) {
    _startListening();
  }

  static const _offlineConfirmDelay = Duration(seconds: 2);

  StreamSubscription<bool>? _sub;
  Timer? _offlineDebounce;

  Future<void> _startListening() async {
    final isOnline = await ConnectivityService.instance.checkConnection();
    _applyStatus(isOnline);

    _sub = ConnectivityService.instance.onStatusChange.listen(_applyStatus);
  }

  void _applyStatus(bool isOnline) {
    if (isOnline) {
      _offlineDebounce?.cancel();
      _offlineDebounce = null;
      emit(state.copyWith(status: ConnectivityStatus.online));
      return;
    }

    _offlineDebounce?.cancel();
    _offlineDebounce = Timer(_offlineConfirmDelay, () {
      emit(state.copyWith(status: ConnectivityStatus.offline));
    });
  }

  Future<void> refreshStatus() async {
    final isOnline = await ConnectivityService.instance.checkConnection();
    _applyStatus(isOnline);
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    _offlineDebounce?.cancel();
    return super.close();
  }
}
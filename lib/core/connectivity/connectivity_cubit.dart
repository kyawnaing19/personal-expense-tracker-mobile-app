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

  StreamSubscription<bool>? _sub;

  Future<void> _startListening() async {
    final isOnline = await ConnectivityService.instance.checkConnection();
    emit(state.copyWith(
      status: isOnline ? ConnectivityStatus.online : ConnectivityStatus.offline,
    ));

    _sub = ConnectivityService.instance.onStatusChange.listen((isOnline) {
      emit(state.copyWith(
        status: isOnline ? ConnectivityStatus.online : ConnectivityStatus.offline,
      ));
    });
  }

  Future<void> refreshStatus() async {
    final isOnline = await ConnectivityService.instance.checkConnection();
    emit(state.copyWith(
      status: isOnline ? ConnectivityStatus.online : ConnectivityStatus.offline,
    ));
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ConnectivityService {
  ConnectivityService._internal() {
    _init();
  }

  static final ConnectivityService instance = ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  final InternetConnection _internetChecker = InternetConnection.createInstance(
    checkInterval: const Duration(seconds: 10),
  );

  final StreamController<bool> _statusController =
      StreamController<bool>.broadcast();

  StreamSubscription<InternetStatus>? _internetSub;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  bool _lastKnownStatus = true;
  bool get lastKnownStatus => _lastKnownStatus;

  Stream<bool> get onStatusChange => _statusController.stream;

  void _init() {
    _connectivitySub = _connectivity.onConnectivityChanged.listen((results) async {
      if (results.contains(ConnectivityResult.none)) {
        _emit(false);
      } else {
        final hasReal = await _internetChecker.hasInternetAccess;
        _emit(hasReal);
      }
    });

    _internetSub = _internetChecker.onStatusChange.listen((status) {
      _emit(status == InternetStatus.connected);
    });
  }

  void _emit(bool isOnline) {
    if (_lastKnownStatus != isOnline) {
      _lastKnownStatus = isOnline;
      _statusController.add(isOnline);
    }
  }

  Future<bool> checkConnection() async {
    try {
      final hasReal = await _internetChecker.hasInternetAccess;
      _lastKnownStatus = hasReal;
      return hasReal;
    } catch (_) {
      _lastKnownStatus = false;
      return false;
    }
  }

  void dispose() {
    _internetSub?.cancel();
    _connectivitySub?.cancel();
    _statusController.close();
  }
}
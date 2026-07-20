class SilentRefreshRegistry {
  SilentRefreshRegistry._internal();
  static final SilentRefreshRegistry instance = SilentRefreshRegistry._internal();

  final Map<String, void Function()> _callbacks = {};

  void register(String featureKey, void Function() onReconnect) {
    _callbacks[featureKey] = onReconnect;
  }

  void unregister(String featureKey) {
    _callbacks.remove(featureKey);
  }

  void triggerAllRefresh() {
    for (final callback in _callbacks.values) {
      callback();
    }
  }
}
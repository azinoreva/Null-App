import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum NetworkState {
  online,
  offline,
}

class NetworkStateManager {
  NetworkStateManager({
    required SharedPreferences preferences,
    Connectivity? connectivity,
  })  : _preferences = preferences,
        _connectivity = connectivity ?? Connectivity();

  static const String _networkAvailableKey = 'network_available';

  final SharedPreferences _preferences;
  final Connectivity _connectivity;

  final StreamController<NetworkState> _stateController =
      StreamController<NetworkState>.broadcast();

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  NetworkState _state = NetworkState.offline;

  NetworkState get state => _state;

  bool get isOnline => _state == NetworkState.online;

  Stream<NetworkState> get stateChanges => _stateController.stream;

  bool get persistedState =>
      _preferences.getBool(_networkAvailableKey) ?? false;

  Future<void> start() async {
    // Use the persisted value immediately.
    _state = persistedState ? NetworkState.online : NetworkState.offline;

    // Establish the current state.
    await _checkCurrentState();

    // Listen for future changes.
    _subscription ??= _connectivity.onConnectivityChanged.listen(
      _handleConnectivityChange,
    );
  }

  Future<void> _checkCurrentState() async {
    final result = await _connectivity.checkConnectivity();
    await _handleConnectivityChange(result);
  }

  Future<void> _handleConnectivityChange(
    List<ConnectivityResult> results,
  ) async {
    final online = results.any(
      (result) =>
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.ethernet ||
          result == ConnectivityResult.vpn,
    );

    final newState =
        online ? NetworkState.online : NetworkState.offline;

    if (newState == _state) {
      // Still persist the value in case SharedPreferences was
      // changed elsewhere.
      await _preferences.setBool(
        _networkAvailableKey,
        online,
      );
      return;
    }

    _state = newState;

    await _preferences.setBool(
      _networkAvailableKey,
      online,
    );

    if (!_stateController.isClosed) {
      _stateController.add(_state);
    }
  }

  Future<void> refresh() async {
    await _checkCurrentState();
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;

    await _stateController.close();
  }
}
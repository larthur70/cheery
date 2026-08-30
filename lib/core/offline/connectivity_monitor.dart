import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Tracks whether the device currently has a network interface.
class ConnectivityMonitor {
  ConnectivityMonitor({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;
  final _controller = StreamController<bool>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _sub;
  bool _online = true;

  bool get isOnline => _online;

  Stream<bool> get changes => _controller.stream;

  Future<void> start() async {
    final initial = await _connectivity.checkConnectivity();
    _setOnline(_hasLink(initial));
    _sub ??= _connectivity.onConnectivityChanged.listen((results) {
      _setOnline(_hasLink(results));
    });
  }

  void _setOnline(bool value) {
    if (_online == value) return;
    _online = value;
    _controller.add(value);
  }

  static bool _hasLink(List<ConnectivityResult> results) {
    return results.any((result) => result != ConnectivityResult.none);
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    await _controller.close();
  }
}

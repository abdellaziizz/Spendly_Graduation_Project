import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

/// Wraps `connectivity_plus` + `internet_connection_checker` into a single
/// broadcast stream of `bool` (true = online, false = offline).
///
/// Why two packages?
///   `connectivity_plus` detects network adapter state (WiFi/mobile/none)
///   but does NOT verify actual internet reachability (captive portals, etc.).
///   `internet_connection_checker` pings real hosts to confirm true internet.
class ConnectivityService {
  final _connectivity = Connectivity();
  final _checker = InternetConnectionChecker.createInstance(
    checkTimeout: const Duration(seconds: 5),
    checkInterval: const Duration(seconds: 10),
  );

  final _controller = StreamController<bool>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _sub;

  bool _isOnline = true;

  bool get isOnline => _isOnline;
  Stream<bool> get onConnectivityChanged => _controller.stream;

  ConnectivityService() {
    _init();
  }

  void _init() async {
    // 1. Check current state immediately
    _isOnline = await _checker.hasConnection;
    _controller.add(_isOnline);

    // 2. React to adapter changes, then confirm with actual ping
    _sub = _connectivity.onConnectivityChanged.listen((results) async {
      final hasAdapter = results.any((r) => r != ConnectivityResult.none);
      if (!hasAdapter) {
        _setOnline(false);
      } else {
        final hasInternet = await _checker.hasConnection;
        _setOnline(hasInternet);
      }
    });
  }

  void _setOnline(bool value) {
    if (_isOnline == value) return; // no duplicate events
    _isOnline = value;
    _controller.add(value);
  }

  /// Force a real connectivity check — called by "Try Again" button.
  Future<bool> checkNow() async {
    final result = await _checker.hasConnection;
    _setOnline(result);
    return result;
  }

  void dispose() {
    _sub?.cancel();
    _controller.close();
  }
}

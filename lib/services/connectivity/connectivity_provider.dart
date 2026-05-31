import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'connectivity_service.dart';

/// Single shared instance of [ConnectivityService].
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  ref.onDispose(service.dispose);
  return service;
});

/// Convenience: synchronous read of current connectivity.
class ConnectivityNotifier extends Notifier<bool> {
  @override
  bool build() {
    final service = ref.watch(connectivityServiceProvider);
    
    // Listen to changes and update state
    final sub = service.onConnectivityChanged.listen((online) {
      state = online;
    });
    ref.onDispose(sub.cancel);
    
    return service.isOnline;
  }
}

/// Reactive online/offline state.
/// Emits `true` when internet is reachable, `false` when offline.
final isOnlineProvider = NotifierProvider<ConnectivityNotifier, bool>(() {
  return ConnectivityNotifier();
});

/// Convenience: synchronous read of current connectivity.
/// Use `ref.isOnline` in build methods.
extension IsOnlineExt on WidgetRef {
  bool get isOnline => watch(isOnlineProvider);
}

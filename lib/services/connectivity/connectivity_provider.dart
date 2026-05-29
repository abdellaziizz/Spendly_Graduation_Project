import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'connectivity_service.dart';

/// Single shared instance of [ConnectivityService].
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  ref.onDispose(service.dispose);
  return service;
});

/// Reactive online/offline state.
/// Emits `true` when internet is reachable, `false` when offline.
/// The `when` data defaults to `true` so the first frame is not blocked.
final isOnlineProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.onConnectivityChanged;
});

/// Convenience: synchronous read of current connectivity.
/// Use `ref.watch(isOnlineProvider).value ?? true` in build methods.
extension IsOnlineExt on WidgetRef {
  bool get isOnline => watch(isOnlineProvider).value ?? true;
}

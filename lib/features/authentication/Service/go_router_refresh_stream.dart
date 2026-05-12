import 'dart:async';

import 'package:flutter/foundation.dart';

/// A [ChangeNotifier] that listens to a [Stream] and calls
/// [notifyListeners] whenever the stream emits a new event.
///
/// This is the standard pattern for connecting Supabase's
/// `onAuthStateChange` stream to GoRouter's `refreshListenable`,
/// ensuring the router re-evaluates its redirect logic whenever
/// the authentication state changes.
///
/// Usage:
/// ```dart
/// GoRouter(
///   refreshListenable: GoRouterRefreshStream(
///     supabase.auth.onAuthStateChange,
///   ),
///   // ...
/// );
/// ```
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners(); // Trigger an initial evaluation.
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

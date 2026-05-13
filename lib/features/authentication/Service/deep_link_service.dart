import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spendly/go_route.dart';

class DeepLinkService {
  StreamSubscription<AuthState>? _sub;

  void initialize() {
    _sub = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      debugPrint('Auth event: $event');

      if (event == AuthChangeEvent.passwordRecovery) {
        // Navigate to password reset screen
        router.go('/reset-password');
      }
    });
  }

  void dispose() {
    _sub?.cancel();
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spendly/go_route.dart';

/// Provider for SharedPreferences, initialized in `main.dart` and overridden in the `ProviderScope`.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider was not overridden');
});

/// Notifier responsible for loading, saving, and exposing onboarding completion status.
class OnboardingStateNotifier extends Notifier<bool> {
  static const _onboardingCompletedKey = 'onboarding_completed';

  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(_onboardingCompletedKey) ?? false;
  }

  /// Marks onboarding as completed and persists this setting to SharedPreferences.
  Future<void> completeOnboarding() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_onboardingCompletedKey, true);
    state = true;
    
    // Trigger GoRouter to immediately evaluate the redirect logic
    router.refresh();
  }
}

/// Provider that exposes the current onboarding completed state.
final onboardingStateProvider = NotifierProvider<OnboardingStateNotifier, bool>(
  OnboardingStateNotifier.new,
);

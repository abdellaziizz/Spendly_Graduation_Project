import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardProvider extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) {
    state = index;
  }
}

final onboardingPageIndexProvider = NotifierProvider<OnboardProvider, int>(
  (OnboardProvider.new),
);

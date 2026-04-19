import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Whether the user is currently recording or not
final isRecordingProvider = StateProvider<bool>((ref) => false);

// Elapsed recording seconds (max 30)
final recordingSecondsProvider = StateProvider<int>((ref) => 0);

// Timer notifier that manages the recording countdown
class RecordingTimerNotifier extends StateNotifier<Timer?> {
  RecordingTimerNotifier(this.ref) : super(null);
  final Ref ref;

  void startRecording() {
    ref.read(recordingSecondsProvider.notifier).state = 0;
    ref.read(isRecordingProvider.notifier).state = true;

    state = Timer.periodic(const Duration(seconds: 1), (timer) {
      final current = ref.read(recordingSecondsProvider);
      if (current >= 30) {
        stopRecording();
      } else {
        ref.read(recordingSecondsProvider.notifier).state = current + 1;
      }
    });
  }

  void stopRecording() {
    state?.cancel();
    state = null;
    ref.read(isRecordingProvider.notifier).state = false;
  }

  @override
  void dispose() {
    state?.cancel();
    super.dispose();
  }
}

final recordingTimerProvider =
    StateNotifierProvider<RecordingTimerNotifier, Timer?>((ref) {
      return RecordingTimerNotifier(ref);
    });

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tspendly/features/chatbot/Model/chat_message.dart';
import 'package:tspendly/features/chatbot/Service/gemini_service.dart';

/// Provider for the GeminiService singleton instance.
final geminiProvider = Provider<GeminiService>((ref) => GeminiService());

/// Provider that tracks whether the bot is currently generating a response.
final isLoadingProvider = StateProvider<bool>((ref) => false);

/// Provider for the chat message list, managed by ChatNotifier.
final chatProvider = StateNotifierProvider<ChatNotifier, List<Message>>((ref) {
  return ChatNotifier(ref);
});

class ChatNotifier extends StateNotifier<List<Message>> {
  final Ref ref;

  ChatNotifier(this.ref) : super([]);

  Future<void> sendMessage(String text) async {
    // Add user message
    state = [...state, Message(text: text, isUser: true)];

    // Set loading state
    ref.read(isLoadingProvider.notifier).state = true;

    // Call Gemini API
    final response = await ref.read(geminiProvider).sendMessage(text);

    // Add bot response
    state = [...state, Message(text: response, isUser: false)];

    // Clear loading state
    ref.read(isLoadingProvider.notifier).state = false;
  }

  void clearChat() {
    state = [];
  }
}

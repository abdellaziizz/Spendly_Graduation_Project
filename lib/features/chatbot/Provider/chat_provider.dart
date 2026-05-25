import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/features/chatbot/Model/chat_message.dart';
import 'package:spendly/features/chatbot/Service/gemini_service.dart';
import 'package:spendly/features/chatbot/Service/user_context_service.dart';

/// Provider for the GeminiService singleton instance.
final geminiProvider = Provider<GeminiService>((ref) => GeminiService());

/// Provider for the UserContextService singleton instance.
final userContextServiceProvider =
    Provider<UserContextService>((ref) => UserContextService());

/// Provider that tracks whether the bot is currently generating a response.
final isLoadingProvider = StateProvider<bool>((ref) => false);

/// Provider for the chat message list, managed by ChatNotifier.
final chatProvider = StateNotifierProvider<ChatNotifier, List<Message>>((ref) {
  return ChatNotifier(ref);
});

class ChatNotifier extends StateNotifier<List<Message>> {
  final Ref ref;

  /// Tracks whether the user's financial context has already been injected
  /// into the current Gemini chat session.
  bool _contextInjected = false;

  ChatNotifier(this.ref) : super([]);

  Future<void> sendMessage(String text) async {
    // Add user message immediately for a responsive feel.
    state = [...state, Message(text: text, isUser: true)];
    ref.read(isLoadingProvider.notifier).state = true;

    // On the first message of a session, prepend the user context snapshot
    // to the message itself — this avoids an extra API call.
    String messageToSend = text;
    if (!_contextInjected) {
      _contextInjected = true;
      try {
        final contextBlock = await ref
            .read(userContextServiceProvider)
            .buildContext();
        if (contextBlock.isNotEmpty) {
          messageToSend = '$contextBlock\n\nUser question: $text';
        }
      } catch (_) {
        // Context fetch failed — send the message without personalisation.
      }
    }

    final response = await ref.read(geminiProvider).sendMessage(messageToSend);

    state = [...state, Message(text: response, isUser: false)];
    ref.read(isLoadingProvider.notifier).state = false;
  }

  /// Clears the chat history and resets the Gemini session so fresh context
  /// is fetched and injected on the next message in the new conversation.
  void clearChat() {
    state = [];
    _contextInjected = false;
    ref.read(geminiProvider).resetSession();
  }
}

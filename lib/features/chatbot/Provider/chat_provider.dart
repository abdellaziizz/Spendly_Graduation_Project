import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tspendly/features/chatbot/Model/chat_message.dart';
import 'package:tspendly/features/chatbot/Service/gemini_service.dart';
import 'package:tspendly/features/chatbot/Service/ml_chatbot_service.dart';

/// Provider for the ML-Integrated Chatbot Service
final mlChatbotProvider = Provider<MLChatbotService>((ref) => MLChatbotService());

/// Provider for the Gemini AI service (external model)
final geminiProvider = Provider<GeminiService>((ref) => GeminiService());

/// Provider that tracks whether the bot is currently generating a response.
final isLoadingProvider = StateProvider<bool>((ref) => false);

/// Provider for user's financial data (for ML integration)
final userFinancialDataProvider = StateProvider<Map<String, dynamic>>((ref) => {});

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

    try {
      // Get services
      final mlService = ref.read(mlChatbotProvider);
      final gemini = ref.read(geminiProvider);

      // Get user financial data
      final financialData = ref.read(userFinancialDataProvider);

      final shouldInclude = mlService.shouldIncludeFinancialContext(text);

      if (shouldInclude && financialData.isNotEmpty) {
        // 1) Immediate local reply
        final local = await mlService.sendMessage(text, financialData: financialData);
        state = [...state, Message(text: local, isUser: false)];

        // 2) Background Gemini-enhanced reply appended when ready
        final ctx = mlService.formatContextForModel(financialData);
        Future(() async {
          try {
            final enhanced = await gemini.sendMessage(text + '\n' + ctx);
            // Append enhanced reply as a follow-up
            state = [...state, Message(text: enhanced, isUser: false)];
          } catch (e) {
            // ignore Gemini errors silently (local reply already provided)
          }
        });
      } else {
        // Non-financial queries go straight to Gemini
        final response = await ref.read(geminiProvider).sendMessage(text);

        // Add bot response
        state = [...state, Message(text: response, isUser: false)];
      }
    } catch (e) {
      // Error handling
      state = [...state, Message(text: 'Sorry, I encountered an error. Please try again.', isUser: false)];
    } finally {
      // Clear loading state
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  /// Updates financial data for the chatbot context
  void updateFinancialData(Map<String, dynamic> data) {
    ref.read(userFinancialDataProvider.notifier).state = data;
  }

  void clearChat() {
    state = [];
    ref.read(mlChatbotProvider).clearCache();
  }
}

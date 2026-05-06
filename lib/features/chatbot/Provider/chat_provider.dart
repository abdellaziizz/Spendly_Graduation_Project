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

        // Append local reply
        state = [...state, Message(text: local, isUser: false)];

        // If Gemini available, append a loading placeholder and replace it
        try {
          if ((gemini is GeminiService) && gemini.isAvailable) {
            final placeholder = Message(
              text: 'Loading enhanced answer...',
              isUser: false,
              isEnhancedLoading: true,
              isRetryable: true,
            );
            state = [...state, placeholder];

            final ctx = mlService.formatContextForModel(financialData);
            Future(() async {
              try {
                final enhanced = await gemini.sendMessage(text + '\n' + ctx);
                // Replace placeholder with enhanced reply
                final current = [...state];
                final idx = current.indexWhere((m) => m.id == placeholder.id);
                if (idx != -1) {
                  current[idx] = Message(
                    id: placeholder.id,
                    text: enhanced,
                    isUser: false,
                    isEnhanced: true,
                    isRetryable: false,
                  );
                  state = current;
                } else {
                  state = [...state, Message(text: enhanced, isUser: false, isEnhanced: true)];
                }
              } catch (e) {
                // Update placeholder to indicate failure but keep retry option
                final current = [...state];
                final idx = current.indexWhere((m) => m.id == placeholder.id);
                if (idx != -1) {
                  current[idx] = Message(
                    id: placeholder.id,
                    text: 'Enhanced AI failed. Tap to retry.',
                    isUser: false,
                    isEnhancedLoading: false,
                    isRetryable: true,
                  );
                  state = current;
                }
              }
            });
          }
        } catch (_) {}
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

  /// Retry an enhanced generation for a previously failed placeholder message.
  Future<void> retryEnhanced(String placeholderId, String originalUserText) async {
    final mlService = ref.read(mlChatbotProvider);
    final gemini = ref.read(geminiProvider);
    final financialData = ref.read(userFinancialDataProvider);

    if (!(gemini is GeminiService) || !gemini.isAvailable) return;

    // Set the placeholder back to loading state if it exists
    final current = [...state];
    final idx = current.indexWhere((m) => m.id == placeholderId);
    if (idx == -1) return;

    current[idx] = Message(
      id: placeholderId,
      text: 'Loading enhanced answer...',
      isUser: false,
      isEnhancedLoading: true,
      isRetryable: true,
    );
    state = current;

    final ctx = mlService.formatContextForModel(financialData);
    try {
      final enhanced = await gemini.sendMessage(originalUserText + '\n' + ctx);
      final updated = [...state];
      final i2 = updated.indexWhere((m) => m.id == placeholderId);
      if (i2 != -1) {
        updated[i2] = Message(
          id: placeholderId,
          text: enhanced,
          isUser: false,
          isEnhanced: true,
          isRetryable: false,
        );
        state = updated;
      }
    } catch (e) {
      final updated = [...state];
      final i2 = updated.indexWhere((m) => m.id == placeholderId);
      if (i2 != -1) {
        updated[i2] = Message(
          id: placeholderId,
          text: 'Enhanced AI failed. Tap to retry.',
          isUser: false,
          isEnhancedLoading: false,
          isRetryable: true,
        );
        state = updated;
      }
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

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

/// Wrapper around Google Generative AI (Gemini) with safe fallback when
/// API key is not available or initialization fails.
class GeminiService {
  static final String? _apiKey = dotenv.env['API_KEY'];
  GenerativeModel? _model;
  ChatSession? _chat;
  bool _initialized = false;

  GeminiService();

  bool get isAvailable => _apiKey != null && _apiKey!.isNotEmpty;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    _initialized = true;

    if (!isAvailable) return;

    try {
      _model = GenerativeModel(
        model: 'gemini-3-flash-preview',
        apiKey: _apiKey!,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 1024,
        ),
        systemInstruction: Content.text(
          'You are Spendly AI Assistant — a friendly, concise, and helpful '
          'financial assistant. Help users with budgeting tips, expense tracking '
          'advice, savings strategies, and general financial literacy. '
          'Keep responses clear, actionable, and under 200 words unless the user '
          'asks for more detail.',
        ),
      );
      _chat = _model!.startChat();
    } catch (e) {
      // Initialization failed - mark as unavailable silently.
      _model = null;
      _chat = null;
    }
  }

  /// Sends a message and returns the AI response. If Gemini is unavailable
  /// returns a short graceful message indicating enhanced AI is disabled.
  Future<String> sendMessage(String message) async {
    if (!isAvailable) return 'Enhanced AI currently unavailable.';

    await _ensureInitialized();
    if (_chat == null) return 'Enhanced AI currently unavailable.';

    try {
      final response = await _chat!.sendMessage(Content.text(message));
      return response.text ?? 'No response received.';
    } on GenerativeAIException catch (e) {
      return 'Enhanced AI error: ${e.message}';
    } catch (e) {
      return 'Enhanced AI error: $e';
    }
  }
}

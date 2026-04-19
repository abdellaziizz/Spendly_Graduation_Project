import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static const String _apiKey = "AIzaSyBjRbKFOUS56qMIUVLNDT4pS-6c7OpUePk";

  late final GenerativeModel _model;
  late final ChatSession _chat;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-3-flash-preview',
      apiKey: _apiKey,
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
    _chat = _model.startChat();
  }

  /// Sends a message and returns the AI response.
  /// The ChatSession automatically maintains conversation history.
  Future<String> sendMessage(String message) async {
    try {
      final response = await _chat.sendMessage(Content.text(message));
      return response.text ?? 'No response received.';
    } on GenerativeAIException catch (e) {
      return 'AI Error: ${e.message}';
    } catch (e) {
      return 'Error: $e';
    }
  }
}

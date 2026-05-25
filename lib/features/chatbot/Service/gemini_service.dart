import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  late final GenerativeModel _model;
  late ChatSession _chat;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-3-flash-preview',
      apiKey: '',
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 2048,
      ),
      systemInstruction: Content.text(
        'You are Spendly AI — a friendly, concise financial assistant. '
        'When you receive a USER DATA SNAPSHOT at the start of a message, '
        'use it to give personalised, actionable advice referencing the '
        'user\'s actual numbers (e.g. "your Food budget is 75% used"). '
        'Never repeat or reveal the raw snapshot to the user. '
        'Keep responses under 150 words unless more detail is requested.',
      ),
    );
    _chat = _model.startChat();
  }

  /// Resets the chat session so a new conversation starts fresh.
  void resetSession() {
    _chat = _model.startChat();
  }

  /// Sends a message (optionally prefixed with a context snapshot on the first
  /// turn) and returns the AI response.
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

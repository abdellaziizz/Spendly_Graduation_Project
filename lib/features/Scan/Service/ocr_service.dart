import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'mlkit_receipt_adapter.dart';

class OcrService {
  final TextRecognizer _recognizer = TextRecognizer();

  Future<String> extractText(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final recognizedText = await _recognizer.processImage(inputImage);

    // 🔥 IMPORTANT: convert ML Kit blocks/lines to real receipt rows
    final cleanText = MlkitReceiptAdapter.toReceiptText(recognizedText);

    return cleanText;
  }

  void dispose() {
    _recognizer.close();
  }
}

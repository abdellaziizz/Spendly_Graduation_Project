import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class MlkitReceiptAdapter {
  static String toReceiptText(RecognizedText recognizedText) {
    final buffer = StringBuffer();

    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        buffer.writeln(line.text);
      }
      buffer.writeln();
    }

    return buffer.toString();
  }
}

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class ReceiptData {
  final String vendor;
  final String amount;
  final String category;
  final String date;

  ReceiptData({
    required this.vendor,
    required this.amount,
    required this.category,
    required this.date,
  });
}

class ReceiptParser {
  static ReceiptData parse(RecognizedText recognizedText) {
    String text = recognizedText.text;
    List<String> lines = text.split('\n').where((l) => l.trim().isNotEmpty).toList();

    String vendor = 'Unknown Vendor';
    String amount = '0.00';
    String category = 'Uncategorized';
    String date = 'Unknown Date';

    if (lines.isNotEmpty) {
      // Usually, the first line or two is the vendor name
      vendor = lines.first;
    }

    // Amount extraction logic (look for highest currency value or keywords like Total/Amount)
    final RegExp amountRegex = RegExp(r'\$?\s?(\d+\.\d{2})');
    double maxAmount = 0.0;
    
    for (String line in lines) {
      // Find amount
      final amountMatches = amountRegex.allMatches(line);
      for (final match in amountMatches) {
        if (match.groupCount >= 1) {
          final valStr = match.group(1);
          if (valStr != null) {
            final val = double.tryParse(valStr);
            if (val != null && val > maxAmount) {
              maxAmount = val;
              amount = val.toStringAsFixed(2);
            }
          }
        }
      }

      // Simple keywords for category guessing
      final lowerLine = line.toLowerCase();
      if (lowerLine.contains('grocery') || lowerLine.contains('supermarket')) {
        category = 'Groceries';
      } else if (lowerLine.contains('restaurant') || lowerLine.contains('cafe') || lowerLine.contains('coffee')) {
        category = 'Food & Dining';
      } else if (lowerLine.contains('uber') || lowerLine.contains('taxi') || lowerLine.contains('station')) {
        category = 'Transport';
      }

      // Find date
      final RegExp dateRegex = RegExp(r'(\d{1,2}[\/\-]\d{1,2}[\/\-]\d{2,4})');
      final dateMatch = dateRegex.firstMatch(line);
      if (dateMatch != null && date == 'Unknown Date') {
        date = dateMatch.group(0) ?? 'Unknown Date';
      }
    }

    return ReceiptData(
      vendor: vendor,
      amount: amount,
      category: category,
      date: date,
    );
  }
}

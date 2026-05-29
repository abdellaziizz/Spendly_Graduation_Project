/// Parsed data extracted from a scanned receipt.
class ParsedReceiptData {
  final String title;
  final double amount;
  final String
  categoryName; // human-readable name used to look up/create the category
  final String description;

  const ParsedReceiptData({
    required this.title,
    required this.amount,
    required this.categoryName,
    required this.description,
  });

  ParsedReceiptData copyWith({
    String? title,
    double? amount,
    String? categoryName,
    String? description,
  }) {
    return ParsedReceiptData(
      title: title ?? this.title,
      amount: amount ?? this.amount,
      categoryName: categoryName ?? this.categoryName,
      description: description ?? this.description,
    );
  }
}

/// Parses raw OCR text from a receipt and extracts structured fields.
/// Supports both Arabic and English receipts.
/// Mirrors the style of `voice_parser.dart` for consistency.
class ReceiptParser {
  // ── English keyword → category name ──────────────────────────────────────
  static const Map<String, List<String>> _enKeywords = {
    'Food / Dining': [
      'restaurant',
      'cafe',
      'coffee',
      'burger',
      'pizza',
      'dining',
      'grill',
      'kitchen',
      'bakery',
      'food',
      'meal',
      'lunch',
      'dinner',
      'breakfast',
      'thai',
      'sushi',
      'shawarma',
    ],
    'Groceries': [
      'supermarket',
      'grocery',
      'groceries',
      'market',
      'walmart',
      'carrefour',
      'hypermarket',
      'store',
      'shop',
    ],
    'Transportation': [
      'uber',
      'lyft',
      'taxi',
      'fuel',
      'gas',
      'petrol',
      'parking',
      'bus',
      'train',
      'metro',
      'flight',
      'ticket',
      'transport',
    ],
    'Bills & Subscriptions': [
      'bill',
      'invoice',
      'subscription',
      'internet',
      'netflix',
      'spotify',
      'electricity',
      'water',
      'utility',
      'telecom',
    ],
    'Shopping': [
      'amazon',
      'mall',
      'clothes',
      'clothing',
      'shoe',
      'fashion',
      'retail',
      'purchase',
      'buy',
      'order',
    ],
    'Health': [
      'pharmacy',
      'clinic',
      'hospital',
      'doctor',
      'dental',
      'medicine',
      'medical',
      'lab',
      'test',
    ],
    'Gym / Fitness': [
      'gym',
      'fitness',
      'sport',
      'workout',
      'yoga',
      'pilates',
      'protein',
      'supplement',
    ],
  };

  // ── Arabic keyword → category name ───────────────────────────────────────
  static const Map<String, List<String>> _arKeywords = {
    'Food / Dining': [
      'مطعم',
      'كافيه',
      'قهوة',
      'بيتزا',
      'برجر',
      'وجبة',
      'طعام',
      'أكل',
      'اكل',
      'غداء',
      'عشاء',
      'فطور',
      'شاورما',
      'مشويات',
      'فول',
      'كشري',
      'دليفري',
      'توصيل',
    ],
    'Groceries': [
      'سوبرماركت',
      'سوبر ماركت',
      'بقالة',
      'خضار',
      'فاكهة',
      'سوق',
      'هايبر',
      'كارفور',
      'لبن',
      'حليب',
      'خبز',
      'عيش',
      'بيض',
    ],
    'Transportation': [
      'أوبر',
      'اوبر',
      'كريم',
      'تاكسي',
      'بنزين',
      'وقود',
      'طيران',
      'مواصلات',
      'مترو',
      'باص',
      'قطار',
      'تذكرة',
      'موقف',
    ],
    'Bills & Subscriptions': [
      'فاتورة',
      'فواتير',
      'اشتراك',
      'إنترنت',
      'نت',
      'نتفلكس',
      'كهرباء',
      'مياه',
      'غاز',
      'تليفون',
      'موبايل',
      'شحن',
    ],
    'Shopping': ['ملابس', 'أحذية', 'تسوق', 'بضاعة', 'قميص', 'جلباب', 'شنطة'],
    'Health': ['صيدلية', 'دواء', 'طبيب', 'مستشفى', 'عيادة', 'تحليل', 'أشعة'],
    'Gym / Fitness': ['جيم', 'نادي', 'رياضة', 'تمرين', 'لياقة', 'بروتين'],
  };

  /// Convert Arabic-Indic digits (٠١٢٣٤٥٦٧٨٩) → ASCII digits
  static String _normalizeDigits(String input) {
    const ar = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    var result = input;
    for (var i = 0; i < ar.length; i++) {
      result = result.replaceAll(ar[i], '$i');
    }
    return result;
  }

  static double _parseAmount(String text) {
    final normalized = _normalizeDigits(text);
    final lines = normalized.split('\n');

    final totalRegex = RegExp(
      r'(total|subtotal|amount|grand total|الإجمالي|المجموع)[^\d]*([\d\.,]+)',
      caseSensitive: false,
    );

    for (final line in lines) {
      final m = totalRegex.firstMatch(line);
      if (m != null) {
        final raw = m.group(2)!.replaceAll(',', '.');
        final val = double.tryParse(raw);
        if (val != null) return val;
      }
    }

    // fallback to your old logic
    final regex = RegExp(r'\b\d+(?:[\.,]\d{1,2})?\b');
    double best = 0.0;
    for (final m in regex.allMatches(normalized)) {
      final raw = m.group(0)!.replaceAll(',', '.');
      final val = double.tryParse(raw);
      if (val != null && val > best) best = val;
    }
    return best;
  }

  /// Detect category name from both EN and AR keywords.
  static String _detectCategory(String text) {
    final lower = text.toLowerCase();

    // Arabic first (more specific)
    for (final entry in _arKeywords.entries) {
      for (final kw in entry.value) {
        if (text.contains(kw)) return entry.key;
      }
    }
    // English fallback
    for (final entry in _enKeywords.entries) {
      for (final kw in entry.value) {
        if (lower.contains(kw)) return entry.key;
      }
    }
    return 'Other';
  }

  /// Extract a short, human-readable title from the first non-empty line.
  static String _extractTitle(String text) {
    final lines = text
        .split(RegExp(r'[\r\n]+'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    if (lines.isEmpty) return 'Receipt';
    var title = lines.first;
    // Trim to 40 chars max
    if (title.length > 40) title = '${title.substring(0, 40)}…';
    return title;
  }

  /// Main entry point. Returns structured [ParsedReceiptData].
  static ParsedReceiptData parse(String ocrText) {
    if (ocrText.trim().isEmpty) {
      return const ParsedReceiptData(
        title: 'Scanned Receipt',
        amount: 0.0,
        categoryName: 'Other',
        description: '',
      );
    }

    return ParsedReceiptData(
      title: _extractTitle(ocrText),
      amount: _parseAmount(ocrText),
      categoryName: _detectCategory(ocrText),
      description: '',
    );
  }
}

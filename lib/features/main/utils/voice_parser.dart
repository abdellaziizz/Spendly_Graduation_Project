class VoiceExpenseData {
  final String title;
  final String description;
  final String category;
  final double amount;

  VoiceExpenseData({
    required this.title,
    required this.description,
    required this.category,
    required this.amount,
  });
}

class VoiceParser {
  // English keywords for category detection
  static final Map<String, List<String>> _categoryKeywords = {
    'Gym / Fitness': ['gym', 'workout', 'fitness', 'membership', 'protein'],
    'Food / Dining': ['dinner', 'lunch', 'restaurant', 'food', 'cafe', 'coffee', 'burger', 'pizza', 'breakfast'],
    'Transportation': ['uber', 'taxi', 'fuel', 'gas', 'car', 'bus', 'train', 'flight', 'ticket'],
    'Groceries': ['supermarket', 'groceries', 'market', 'walmart', 'store', 'milk', 'bread'],
    'Bills & Subscriptions': ['bill', 'subscription', 'payment', 'internet', 'netflix', 'spotify', 'electricity', 'water'],
  };

  // Arabic keywords for category detection
  static final Map<String, List<String>> _arabicCategoryKeywords = {
    'Gym / Fitness': ['جيم', 'رياضة', 'تمرين', 'نادي', 'بروتين', 'صالة', 'لياقة'],
    'Food / Dining': [
      'اكل', 'أكل', 'طعام', 'عشا', 'عشاء', 'غدا', 'غداء', 'فطار', 'فطور', 'إفطار',
      'مطعم', 'كافيه', 'قهوة', 'بيتزا', 'برجر', 'وجبة', 'سندوتش', 'شاورما',
      'كشري', 'فول', 'طبخ', 'دليفري', 'توصيل',
    ],
    'Transportation': [
      'اوبر', 'أوبر', 'تاكسي', 'كريم', 'بنزين', 'وقود', 'عربية', 'سيارة',
      'باص', 'أتوبيس', 'قطر', 'قطار', 'مترو', 'مواصلات', 'نقل', 'تذكرة', 'طيارة', 'طيران',
    ],
    'Groceries': [
      'سوبر ماركت', 'سوبرماركت', 'بقالة', 'خضار', 'فاكهة', 'سوق',
      'لبن', 'حليب', 'عيش', 'خبز', 'بيض', 'جبنة', 'زيت', 'رز', 'أرز', 'سكر',
    ],
    'Bills & Subscriptions': [
      'فاتورة', 'فواتير', 'اشتراك', 'نت', 'انترنت', 'إنترنت', 'نتفلكس',
      'كهرباء', 'مية', 'ماء', 'غاز', 'تليفون', 'موبايل', 'شحن',
    ],
  };

  // Arabic number words to their numeric values
  static final Map<String, double> _arabicNumberWords = {
    'صفر': 0,
    'واحد': 1, 'واحده': 1,
    'اتنين': 2, 'اثنين': 2, 'اثنان': 2,
    'تلاتة': 3, 'ثلاثة': 3, 'ثلاث': 3, 'تلات': 3,
    'اربعة': 4, 'أربعة': 4, 'اربع': 4, 'أربع': 4,
    'خمسة': 5, 'خمس': 5,
    'ستة': 6, 'ست': 6,
    'سبعة': 7, 'سبع': 7,
    'تمانية': 8, 'ثمانية': 8, 'تمن': 8, 'ثمان': 8,
    'تسعة': 9, 'تسع': 9,
    'عشرة': 10, 'عشر': 10,
    'حداشر': 11, 'إحدى عشر': 11, 'احدعشر': 11,
    'اتناشر': 12, 'اثنا عشر': 12, 'اثناعشر': 12,
    'تلتاشر': 13, 'ثلاثة عشر': 13, 'ثلاثعشر': 13,
    'أربعتاشر': 14, 'اربعتاشر': 14, 'أربعة عشر': 14,
    'خمستاشر': 15, 'خمسة عشر': 15, 'خمسطاشر': 15,
    'سطاشر': 16, 'ستة عشر': 16, 'ستاشر': 16,
    'سبعتاشر': 17, 'سبعة عشر': 17,
    'تمنتاشر': 18, 'ثمانية عشر': 18, 'تمنطاشر': 18,
    'تسعتاشر': 19, 'تسعة عشر': 19,
    'عشرين': 20, 'عشرون': 20,
    'تلاتين': 30, 'ثلاثين': 30, 'ثلاثون': 30,
    'اربعين': 40, 'أربعين': 40, 'أربعون': 40,
    'خمسين': 50, 'خمسون': 50,
    'ستين': 60, 'ستون': 60,
    'سبعين': 70, 'سبعون': 70,
    'تمانين': 80, 'ثمانين': 80, 'ثمانون': 80,
    'تسعين': 90, 'تسعون': 90,
    'مية': 100, 'ميه': 100, 'مئة': 100, 'مائة': 100,
    'ميتين': 200, 'مئتين': 200, 'مائتين': 200,
    'تلتمية': 300, 'ثلاثمائة': 300, 'ثلاثمية': 300,
    'ربعمية': 400, 'أربعمائة': 400, 'اربعمية': 400,
    'خمسمية': 500, 'خمسمائة': 500,
    'ستمية': 600, 'ستمائة': 600,
    'سبعمية': 700, 'سبعمائة': 700,
    'تمنمية': 800, 'ثمانمائة': 800,
    'تسعمية': 900, 'تسعمائة': 900,
    'ألف': 1000, 'الف': 1000,
    'ألفين': 2000, 'الفين': 2000,
  };

  /// Convert Arabic-Indic numerals (٠١٢٣٤٥٦٧٨٩) to Western digits (0123456789)
  static String _convertArabicNumerals(String input) {
    const arabicNumerals = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    String result = input;
    for (int i = 0; i < arabicNumerals.length; i++) {
      result = result.replaceAll(arabicNumerals[i], i.toString());
    }
    return result;
  }

  /// Extract amount from Arabic text using number words and "و" (and) connector
  static double _extractArabicAmount(String text) {
    // First convert any Arabic-Indic numerals to Western
    String normalized = _convertArabicNumerals(text);

    // Try to find Western digits first (might have been converted from Arabic-Indic)
    final digitRegex = RegExp(r'\b(\d+[.,]?\d*)\b');
    final digitMatches = digitRegex.allMatches(normalized);
    double maxDigitAmount = 0.0;
    for (final match in digitMatches) {
      final valStr = match.group(1)?.replaceAll(',', '');
      if (valStr != null) {
        final val = double.tryParse(valStr);
        if (val != null && val > maxDigitAmount) {
          maxDigitAmount = val;
        }
      }
    }

    // Try to find Arabic number words
    double wordAmount = 0.0;
    // Split by "و" (and) to handle compound numbers like "مية و خمسين" (150)
    // Also handle words directly
    final words = normalized.split(RegExp(r'\s+'));

    for (int i = 0; i < words.length; i++) {
      final word = words[i];
      if (_arabicNumberWords.containsKey(word)) {
        final value = _arabicNumberWords[word]!;
        // If the previous number is a large unit (100s, 1000s) and current is smaller, add
        // If current is a large unit (100, 1000) and previous is small (1-9), multiply
        if (value >= 100 && wordAmount > 0 && wordAmount < 10) {
          wordAmount = wordAmount * value; // e.g., "تلاتة آلاف" = 3 * 1000
        } else {
          wordAmount += value;
        }
      }
    }

    // Return whichever is larger
    return maxDigitAmount > wordAmount ? maxDigitAmount : wordAmount;
  }

  static VoiceExpenseData parse(String transcribedText) {
    if (transcribedText.isEmpty) {
      return VoiceExpenseData(title: 'Unknown', description: '', category: 'Other', amount: 0.0);
    }

    final lowerText = transcribedText.toLowerCase();

    // 1. Extract Amount — try Arabic parsing first, then English
    double amount = _extractArabicAmount(transcribedText);

    if (amount == 0.0) {
      // Fallback to English regex
      final amountRegex = RegExp(r'\$?\b(\d+[.,]?\d*)\b');
      final matches = amountRegex.allMatches(lowerText);
      for (final match in matches) {
        final valStr = match.group(1)?.replaceAll(',', '');
        if (valStr != null) {
          final val = double.tryParse(valStr);
          if (val != null && val > amount) {
            amount = val;
          }
        }
      }
    }

    // 2. Extract Category — try Arabic keywords first, then English
    String detectedCategory = 'Other';

    // Check Arabic keywords
    for (final entry in _arabicCategoryKeywords.entries) {
      for (final keyword in entry.value) {
        if (transcribedText.contains(keyword)) {
          detectedCategory = entry.key;
          break;
        }
      }
      if (detectedCategory != 'Other') break;
    }

    // If no Arabic match, try English keywords
    if (detectedCategory == 'Other') {
      for (final entry in _categoryKeywords.entries) {
        for (final keyword in entry.value) {
          if (lowerText.contains(keyword)) {
            detectedCategory = entry.key;
            break;
          }
        }
        if (detectedCategory != 'Other') break;
      }
    }

    // 3. Synthesize Title (in English, based on category)
    String title = detectedCategory;
    if (detectedCategory == 'Other') {
      final words = transcribedText.split(RegExp(r'\s+'));
      if (words.length > 2) {
        title = '${words[0]} ${words[1]}';
      } else {
        title = transcribedText;
      }
    } else {
      // For English keywords, try to find the exact keyword used
      if (_categoryKeywords.containsKey(detectedCategory)) {
        for (final keyword in _categoryKeywords[detectedCategory]!) {
          if (lowerText.contains(keyword)) {
            title = keyword[0].toUpperCase() + keyword.substring(1);
            break;
          }
        }
      }
    }

    // Ensure title is reasonably short
    if (title.length > 20) {
      title = title.substring(0, 20);
    }

    // 4. Description is the full Arabic sentence
    String description = transcribedText;

    return VoiceExpenseData(
      title: title,
      description: description,
      category: detectedCategory,
      amount: amount,
    );
  }
}

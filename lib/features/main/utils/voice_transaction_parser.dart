import 'package:spendly/features/main/models/parsed_transaction.dart';
import 'package:spendly/features/main/utils/voice_intent_detector.dart';

/// Full voice-transaction parser.
///
/// Responsibilities:
///  1. Normalise Arabic-Indic numerals → Western digits.
///  2. Detect overall intent (expense / income) of the full sentence.
///  3. Split the sentence on conjunction words to find multiple transactions.
///  4. For each segment: extract amount, detect category, resolve intent.
///  5. Return a [VoiceParseResult] containing one or more [ParsedTransaction]s.
class VoiceTransactionParser {
  // ── Category keywords ──────────────────────────────────────────────────────

  static const Map<String, List<String>> _enCategory = {
    'Gym / Fitness': [
      'gym', 'workout', 'fitness', 'membership', 'protein',
      'exercise', 'yoga', 'pilates',
    ],
    'Food / Dining': [
      'dinner', 'lunch', 'restaurant', 'food', 'cafe', 'coffee',
      'burger', 'pizza', 'breakfast', 'meal', 'snack',
      'shawarma', 'sushi', 'kebab', 'takeaway', 'takeout',
    ],
    'Transportation': [
      'uber', 'taxi', 'fuel', 'gas', 'car', 'bus', 'train',
      'flight', 'ticket', 'careem', 'metro', 'transport', 'petrol',
    ],
    'Groceries': [
      'supermarket', 'groceries', 'grocery', 'market',
      'walmart', 'store', 'milk', 'bread', 'vegetables', 'fruits',
    ],
    'Bills & Subscriptions': [
      'bill', 'subscription', 'internet', 'netflix', 'spotify',
      'electricity', 'water', 'phone', 'mobile', 'utility',
    ],
    'Health': [
      'doctor', 'hospital', 'medicine', 'pharmacy', 'clinic',
      'dental', 'health', 'medical', 'checkup',
    ],
    'Shopping': [
      'clothes', 'shoes', 'shopping', 'mall', 'amazon',
      'online', 'dress', 'shirt', 'pants', 'jacket',
    ],
    'Education': [
      'school', 'university', 'course', 'book', 'books',
      'tuition', 'education', 'study', 'training',
    ],
    'Entertainment': [
      'cinema', 'movie', 'concert', 'games', 'gaming',
      'playstation', 'game', 'netflix', 'show',
    ],
    'Salary': ['salary', 'wage', 'paycheck', 'payslip', 'monthly pay'],
    'Freelance': ['freelance', 'freelancing', 'project', 'client', 'gig'],
    'Investment': ['dividend', 'profit', 'investment', 'stock', 'crypto'],
    // Personal income sources — catches "got 2000 from dad / mom / friend"
    'Personal Transfer': ['dad', 'mom', 'mother', 'father', 'friend', 'brother', 'sister', 'family'],
  };

  static const Map<String, List<String>> _arCategory = {
    'Gym / Fitness': [
      'جيم', 'رياضة', 'تمرين', 'نادي', 'بروتين', 'صالة', 'لياقة', 'يوغا',
    ],
    'Food / Dining': [
      'اكل', 'أكل', 'طعام', 'عشا', 'عشاء', 'غدا', 'غداء',
      'فطار', 'فطور', 'إفطار', 'مطعم', 'كافيه', 'قهوة',
      'بيتزا', 'برجر', 'وجبة', 'سندوتش', 'شاورما', 'كشري',
      'فول', 'طبخ', 'دليفري', 'توصيل', 'كافيتيريا',
    ],
    'Transportation': [
      'اوبر', 'أوبر', 'تاكسي', 'كريم', 'بنزين', 'وقود',
      'عربية', 'سيارة', 'باص', 'أتوبيس', 'قطر', 'قطار',
      'مترو', 'مواصلات', 'نقل', 'تذكرة', 'طيارة', 'طيران',
    ],
    'Groceries': [
      'سوبر ماركت', 'سوبرماركت', 'بقالة', 'خضار', 'فاكهة', 'سوق',
      'لبن', 'حليب', 'عيش', 'خبز', 'بيض', 'جبنة',
      'زيت', 'رز', 'أرز', 'سكر',
    ],
    'Bills & Subscriptions': [
      'فاتورة', 'فواتير', 'اشتراك', 'نت', 'انترنت', 'إنترنت',
      'نتفلكس', 'كهرباء', 'مية', 'ماء', 'غاز',
      'تليفون', 'موبايل', 'شحن',
    ],
    'Health': [
      'دكتور', 'مستشفى', 'دوا', 'دواء', 'صيدلية',
      'عيادة', 'اسنان', 'صحة', 'تحاليل',
    ],
    'Shopping': [
      'هدوم', 'ملابس', 'جزمة', 'حذاء', 'شوبينج', 'مول', 'شراء',
    ],
    'Education': [
      'مدرسة', 'جامعة', 'كورس', 'كتاب', 'كتب',
      'رسوم', 'تعليم', 'دراسة',
    ],
    'Entertainment': [
      'سينما', 'فيلم', 'حفلة', 'العاب', 'بلايستيشن',
    ],
    'Salary': ['مرتب', 'راتب', 'القبض', 'اجر', 'أجر'],
    'Freelance': ['فريلانس', 'شغل حر', 'مشروع'],
    'Investment': ['ارباح', 'ربح', 'استثمار', 'اسهم', 'كريبتو'],
  };

  // ── Arabic number words ────────────────────────────────────────────────────

  static const Map<String, double> _arNumbers = {
    'صفر': 0,
    'واحد': 1, 'واحده': 1, 'واحدة': 1,
    'اتنين': 2, 'اثنين': 2, 'اثنان': 2,
    'تلاتة': 3, 'ثلاثة': 3, 'ثلاث': 3, 'تلات': 3,
    'اربعة': 4, 'أربعة': 4, 'اربع': 4, 'أربع': 4,
    'خمسة': 5, 'خمس': 5,
    'ستة': 6, 'ست': 6,
    'سبعة': 7, 'سبع': 7,
    'تمانية': 8, 'ثمانية': 8, 'تمن': 8, 'ثمان': 8,
    'تسعة': 9, 'تسع': 9,
    'عشرة': 10, 'عشر': 10,
    'حداشر': 11, 'إحدى عشر': 11,
    'اتناشر': 12, 'اثنا عشر': 12,
    'تلتاشر': 13, 'ثلاثة عشر': 13,
    'أربعتاشر': 14, 'اربعتاشر': 14,
    'خمستاشر': 15, 'خمسة عشر': 15,
    'سطاشر': 16, 'ستة عشر': 16, 'ستاشر': 16,
    'سبعتاشر': 17, 'سبعة عشر': 17,
    'تمنتاشر': 18, 'ثمانية عشر': 18,
    'تسعتاشر': 19, 'تسعة عشر': 19,
    'عشرين': 20, 'عشرون': 20,
    'تلاتين': 30, 'ثلاثين': 30,
    'اربعين': 40, 'أربعين': 40,
    'خمسين': 50,
    'ستين': 60,
    'سبعين': 70,
    'تمانين': 80, 'ثمانين': 80,
    'تسعين': 90,
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

  // ── Conjunction splitter ───────────────────────────────────────────────────

  /// Splits the full utterance on conjunction words that introduce a NEW
  /// transaction clause.
  ///
  /// Pattern notes:
  ///  - Uses `\b` (word-boundary) on both sides so "band" is not matched.
  ///  - Surrounding \s* (not \s+) tolerates tight punctuation or extra spaces.
  ///  - Works even if ASR drops a leading space before "and".
  static final _splitPattern = RegExp(
    r'\s*\b(?:and|also|plus|then|و|وكمان|وبرضو|وكذلك|كمان)\b\s*',
    caseSensitive: false,
  );

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Parses [text] into a [VoiceParseResult].
  static VoiceParseResult parse(String text) {
    if (text.trim().isEmpty) {
      return VoiceParseResult(transactions: [], rawText: text);
    }

    // 1. Normalise Arabic-Indic numerals
    final norm = _normalise(text);

    // 2. Detect overall intent for the whole sentence (fallback for segments)
    final overallIntent = VoiceIntentDetector.detect(norm);

    // 3. Split into segments on conjunction words
    final segments = norm
        .split(_splitPattern)
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    // 4. Parse each segment
    final transactions = <ParsedTransaction>[];
    for (final seg in segments) {
      final tx = _parseSegment(seg, overallIntent: overallIntent);
      if (tx != null) transactions.add(tx);
    }

    // 5. Fallback: parse whole text as one transaction
    if (transactions.isEmpty) {
      final tx = _parseSegment(norm, overallIntent: overallIntent);
      if (tx != null) transactions.add(tx);
    }

    return VoiceParseResult(transactions: transactions, rawText: text);
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  static String _normalise(String input) {
    const ar = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    var result = input;
    for (int i = 0; i < ar.length; i++) {
      result = result.replaceAll(ar[i], i.toString());
    }
    return result;
  }

  static ParsedTransaction? _parseSegment(
    String segment, {
    required TransactionIntent overallIntent,
  }) {
    // Amount
    final amount = _extractAmount(segment);

    // Category
    final category = _detectCategory(segment);

    // Intent — prefer explicit local signal, else use whole-sentence intent
    final TransactionIntent intent;
    if (VoiceIntentDetector.hasIncomeSignal(segment)) {
      intent = TransactionIntent.income;
    } else if (VoiceIntentDetector.hasExpenseSignal(segment)) {
      intent = TransactionIntent.expense;
    } else {
      intent = overallIntent;
    }

    // Guard: discard a segment that has NO meaningful content.
    // A segment is meaningful when it has a non-zero amount OR at least one
    // explicit intent signal (e.g. "got 2000" has both; "i got" has signal
    // but zero amount — keep it so the user sees it in the dialog rather
    // than silently dropping it).
    final hasSignal = intent != TransactionIntent.unknown ||
        VoiceIntentDetector.hasIncomeSignal(segment) ||
        VoiceIntentDetector.hasExpenseSignal(segment);
    if (amount == 0.0 && !hasSignal) return null;

    // Title
    final title = _buildTitle(category, segment);

    return ParsedTransaction(
      title: title,
      description: segment.trim(),
      category: category,
      amount: amount,
      intent: intent,
    );
  }

  /// Extracts the largest numeric amount from [text].
  /// Tries Western digits first, then Arabic number words.
  static double _extractAmount(String text) {
    double maxDigit = 0.0;
    final digitRx = RegExp(r'\b(\d+[.,]?\d*)\b');
    for (final m in digitRx.allMatches(text)) {
      final v = double.tryParse(m.group(1)!.replaceAll(',', ''));
      if (v != null && v > maxDigit) maxDigit = v;
    }

    double wordAmt = 0.0;
    final words = text.split(RegExp(r'\s+'));
    for (final w in words) {
      final v = _arNumbers[w];
      if (v == null) continue;
      if (v >= 100 && wordAmt > 0 && wordAmt < 10) {
        wordAmt = wordAmt * v; // e.g. "تلاتة آلاف" = 3 * 1000
      } else {
        wordAmt += v;
      }
    }

    return maxDigit > wordAmt ? maxDigit : wordAmt;
  }

  /// Detects category by matching Arabic then English keywords.
  static String _detectCategory(String segment) {
    // Arabic first (longer / more specific matches take priority)
    for (final entry in _arCategory.entries) {
      for (final kw in entry.value) {
        if (segment.contains(kw)) return entry.key;
      }
    }
    // English
    final lower = segment.toLowerCase();
    for (final entry in _enCategory.entries) {
      for (final kw in entry.value) {
        if (lower.contains(kw)) return entry.key;
      }
    }
    return 'Other';
  }

  /// Builds a human-readable title from the detected category / segment.
  static String _buildTitle(String category, String segment) {
    if (category != 'Other') {
      // Try to use the exact matched English keyword as a capitalised title
      final lower = segment.toLowerCase();
      for (final kw in (_enCategory[category] ?? [])) {
        if (lower.contains(kw)) {
          return kw[0].toUpperCase() + kw.substring(1);
        }
      }
      return category;
    }
    // Fallback: first two words, max 20 chars
    final words = segment.trim().split(RegExp(r'\s+'));
    final raw = words.take(2).join(' ');
    return raw.length > 20 ? raw.substring(0, 20) : raw;
  }
}

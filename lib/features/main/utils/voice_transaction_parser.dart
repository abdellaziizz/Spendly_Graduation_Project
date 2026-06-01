import 'package:spendly/core/categories/category_helpers.dart';
import 'package:spendly/features/main/models/parsed_transaction.dart';
import 'package:spendly/features/main/utils/voice_intent_detector.dart';

/// Full voice-transaction parser.
///
/// Responsibilities:
///  1. Normalise Arabic-Indic numerals → Western digits.
///  2. Detect overall intent (expense / income) of the full sentence.
///  3. Split the sentence on conjunction words to find multiple transactions.
///  4. For each segment: extract amount, detect category, resolve intent.
///  5. Return a [VoiceParseResult] with one or more [ParsedTransaction]s.
///
/// All category names produced here are guaranteed to exist in
/// [kAllCategories] because they pass through [CategoryHelpers.canonicalise].
class VoiceTransactionParser {
  // ── Expense category keywords ─────────────────────────────────────────────

  /// Maps raw detected names → canonical expense category keywords.
  static const Map<String, List<String>> _enExpenseCategory = {
    'Gym': [
      'gym', 'workout', 'fitness', 'membership', 'protein',
      'exercise', 'yoga', 'pilates',
    ],
    'Food': [
      'dinner', 'lunch', 'restaurant', 'food', 'cafe', 'coffee',
      'burger', 'pizza', 'breakfast', 'meal', 'snack',
      'shawarma', 'sushi', 'kebab', 'takeaway', 'takeout',
      'supermarket', 'groceries', 'grocery', 'market',
      'walmart', 'store', 'milk', 'bread', 'vegetables', 'fruits',
    ],
    'Transportation': [
      'uber', 'taxi', 'fuel', 'gas', 'car', 'bus', 'train',
      'flight', 'ticket', 'careem', 'metro', 'transport', 'petrol',
    ],
    'Bills': [
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
      'playstation', 'game', 'show',
    ],
    'Travel': [
      'hotel', 'resort', 'trip', 'vacation', 'travel', 'airbnb',
    ],
  };

  /// Income category keywords (English).
  static const Map<String, List<String>> _enIncomeCategory = {
    'Salary': ['salary', 'wage', 'paycheck', 'payslip', 'monthly pay'],
    'Freelance': ['freelance', 'freelancing', 'project', 'client', 'gig'],
    'Investment': ['dividend', 'profit', 'investment', 'stock', 'crypto'],
    'Family': ['dad', 'mom', 'mother', 'father', 'friend', 'brother', 'sister', 'family'],
    'Bonus': ['bonus', 'reward', 'incentive'],
    'Refund': ['refund', 'cashback', 'return'],
    'Business': ['business', 'revenue', 'sales'],
  };

  // ── Arabic expense keywords ────────────────────────────────────────────────
  static const Map<String, List<String>> _arExpenseCategory = {
    'Gym': [
      'جيم', 'رياضة', 'تمرين', 'نادي', 'بروتين', 'صالة', 'لياقة', 'يوغا',
    ],
    'Food': [
      'اكل', 'أكل', 'طعام', 'عشا', 'عشاء', 'غدا', 'غداء',
      'فطار', 'فطور', 'إفطار', 'مطعم', 'كافيه', 'قهوة',
      'بيتزا', 'برجر', 'وجبة', 'سندوتش', 'شاورما', 'كشري',
      'فول', 'طبخ', 'دليفري', 'توصيل', 'كافيتيريا',
      'سوبر ماركت', 'سوبرماركت', 'بقالة', 'خضار', 'فاكهة', 'سوق',
      'لبن', 'حليب', 'عيش', 'خبز', 'بيض', 'جبنة',
      'زيت', 'رز', 'أرز', 'سكر',
    ],
    'Transportation': [
      'اوبر', 'أوبر', 'تاكسي', 'كريم', 'بنزين', 'وقود',
      'عربية', 'سيارة', 'باص', 'أتوبيس', 'قطر', 'قطار',
      'مترو', 'مواصلات', 'نقل', 'تذكرة', 'طيارة', 'طيران',
    ],
    'Bills': [
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
    'Travel': [
      'فندق', 'رحلة', 'سفر', 'منتجع',
    ],
  };

  /// Arabic income keywords.
  static const Map<String, List<String>> _arIncomeCategory = {
    'Salary': ['مرتب', 'راتب', 'القبض', 'اجر', 'أجر'],
    'Freelance': ['فريلانس', 'شغل حر', 'مشروع'],
    'Investment': ['ارباح', 'ربح', 'استثمار', 'اسهم', 'كريبتو'],
    'Family': ['ابويا', 'بابا', 'ماما', 'اخو', 'اخت', 'عيلة', 'ابويه'],
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

    final norm = _normalise(text);
    final overallIntent = VoiceIntentDetector.detect(norm);

    final segments = norm
        .split(_splitPattern)
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final transactions = <ParsedTransaction>[];
    for (final seg in segments) {
      final tx = _parseSegment(seg, overallIntent: overallIntent);
      if (tx != null) transactions.add(tx);
    }

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
    final amount = _extractAmount(segment);

    // Determine intent first so we can pick the right category list
    final TransactionIntent intent;
    if (VoiceIntentDetector.hasIncomeSignal(segment)) {
      intent = TransactionIntent.income;
    } else if (VoiceIntentDetector.hasExpenseSignal(segment)) {
      intent = TransactionIntent.expense;
    } else {
      intent = overallIntent;
    }

    // Detect category from the correct type-specific keyword list,
    // then canonicalise it to a guaranteed-valid category name.
    final rawCategory = _detectCategory(segment, intent);
    final isExpense = intent != TransactionIntent.income;
    final category = CategoryHelpers.canonicalise(rawCategory, isExpense: isExpense);

    final hasSignal = intent != TransactionIntent.unknown ||
        VoiceIntentDetector.hasIncomeSignal(segment) ||
        VoiceIntentDetector.hasExpenseSignal(segment);
    if (amount == 0.0 && !hasSignal) return null;

    final title = _buildTitle(category, rawCategory, segment, isExpense);

    return ParsedTransaction(
      title: title,
      description: segment.trim(),
      category: category,
      amount: amount,
      intent: intent,
    );
  }

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
        wordAmt = wordAmt * v;
      } else {
        wordAmt += v;
      }
    }

    return maxDigit > wordAmt ? maxDigit : wordAmt;
  }

  /// Detects raw category by checking type-appropriate keyword maps.
  /// Returns a string that may be a legacy name — callers must canonicalise.
  static String _detectCategory(String segment, TransactionIntent intent) {
    final isIncome = intent == TransactionIntent.income;

    // For income: check income keyword maps
    if (isIncome) {
      // Arabic first
      for (final entry in _arIncomeCategory.entries) {
        for (final kw in entry.value) {
          if (segment.contains(kw)) return entry.key;
        }
      }
      final lower = segment.toLowerCase();
      for (final entry in _enIncomeCategory.entries) {
        for (final kw in entry.value) {
          if (lower.contains(kw)) return entry.key;
        }
      }
      return 'Other'; // income Other
    }

    // For expense (or unknown): check expense keyword maps
    for (final entry in _arExpenseCategory.entries) {
      for (final kw in entry.value) {
        if (segment.contains(kw)) return entry.key;
      }
    }
    final lower = segment.toLowerCase();
    for (final entry in _enExpenseCategory.entries) {
      for (final kw in entry.value) {
        if (lower.contains(kw)) return entry.key;
      }
    }
    return 'Other'; // expense Other
  }

  /// Builds a human-readable title from the detected category / segment.
  static String _buildTitle(
    String canonicalCategory,
    String rawCategory,
    String segment,
    bool isExpense,
  ) {
    if (canonicalCategory != 'Other') {
      // Try to find the triggering English keyword for a more natural title
      final lower = segment.toLowerCase();
      final keywordMap = isExpense ? _enExpenseCategory : _enIncomeCategory;
      for (final kw in (keywordMap[rawCategory] ?? keywordMap[canonicalCategory] ?? [])) {
        if (lower.contains(kw)) {
          return kw[0].toUpperCase() + kw.substring(1);
        }
      }
      return canonicalCategory;
    }
    // Fallback: first two words, max 20 chars
    final words = segment.trim().split(RegExp(r'\s+'));
    final raw = words.take(2).join(' ');
    return raw.length > 20 ? raw.substring(0, 20) : raw;
  }
}

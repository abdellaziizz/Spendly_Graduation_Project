import 'package:spendly/features/main/models/parsed_transaction.dart';

/// Detects whether a voice sentence is an [expense], [income], or [unknown].
///
/// Uses a weighted keyword-scoring approach: the intent with the higher
/// cumulative score wins. Handles mixed Arabic / English sentences.
class VoiceIntentDetector {
  // ── English expense signals ────────────────────────────────────────────────
  static const _enExpense = [
    'spent', 'spend', 'spending',
    'paid', 'pay', 'paying',
    'bought', 'buy', 'buying',
    'purchased', 'purchase',
    'cost', 'costs',
    'charged', 'charge',
    'expense', 'expenses',
    'withdrew', 'withdrawal',
    'fee', 'subscribed',
  ];

  // ── English income signals ─────────────────────────────────────────────────
  static const _enIncome = [
    'received', 'receive',
    'got', 'gotten',
    'earned', 'earn',
    'salary', 'wage', 'wages',
    'income',
    'deposited', 'deposit',
    'collected', 'collect',
    'gained', 'gain',
    'bonus', 'allowance',
    'freelance', 'freelancing',
    'dividend', 'profit',
    'refund', 'cashback',
    'got paid',
  ];

  // ── Arabic expense signals ─────────────────────────────────────────────────
  static const _arExpense = [
    'صرفت', 'صرف', 'اصرف',
    'دفعت', 'دفع', 'ادفع',
    'اشتريت', 'اشترى', 'اشتري',
    'خرجت', 'خرج',
    'كلفت', 'كلف',
    'خصمت', 'خصم',
    'سحبت', 'سحب',
    'انفقت', 'انفق',
    'مصاريف', 'مصروف',
    'خلصت',
  ];

  // ── Arabic income signals ──────────────────────────────────────────────────
  static const _arIncome = [
    'استلمت', 'استلم',
    'اخدت', 'اخذت', 'اخد', 'اخذ',
    'جالي', 'جاء لي', 'جاءلي',
    'ربحت', 'ربح',
    'كسبت', 'كسب',
    'حصلت', 'حصل',
    'القبض', 'قبضت', 'قبض',
    'مرتب', 'راتب',
    'دخل',
    'مكافأة', 'بونص', 'حافز',
    'فريلانس',
    'وصلني', 'وصلتلي',
    'رد فلوس', 'استرجعت',
    'بدل',
    'حولي', 'حولولي', 'اتحول',
  ];

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Returns the detected [TransactionIntent] for [text].
  /// Defaults to [TransactionIntent.expense] when signals are absent or tied.
  static TransactionIntent detect(String text) {
    final lower = text.toLowerCase();
    int expenseScore = 0;
    int incomeScore = 0;

    for (final kw in _enExpense) {
      if (lower.contains(kw)) expenseScore++;
    }
    for (final kw in _enIncome) {
      if (lower.contains(kw)) incomeScore++;
    }
    for (final kw in _arExpense) {
      if (text.contains(kw)) expenseScore++;
    }
    for (final kw in _arIncome) {
      if (text.contains(kw)) incomeScore++;
    }

    if (incomeScore > expenseScore) return TransactionIntent.income;
    // Default to expense — most transactions are expenses
    return TransactionIntent.expense;
  }

  /// Returns true if [text] contains any explicit income keyword.
  static bool hasIncomeSignal(String text) {
    final lower = text.toLowerCase();
    for (final kw in _enIncome) {
      if (lower.contains(kw)) return true;
    }
    for (final kw in _arIncome) {
      if (text.contains(kw)) return true;
    }
    return false;
  }

  /// Returns true if [text] contains any explicit expense keyword.
  static bool hasExpenseSignal(String text) {
    final lower = text.toLowerCase();
    for (final kw in _enExpense) {
      if (lower.contains(kw)) return true;
    }
    for (final kw in _arExpense) {
      if (text.contains(kw)) return true;
    }
    return false;
  }
}

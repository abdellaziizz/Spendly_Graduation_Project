import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/features/main/providers/main_finance_provider.dart';
import 'package:spendly/features/main/providers/transactions_list_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spendly/features/Scan/ocr_service.dart';
import 'package:spendly/features/Scan/receipt_parser.dart';
import 'package:spendly/features/main/providers/transaction_provider.dart';
import 'package:spendly/features/main/transaction_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// STATE
// ─────────────────────────────────────────────────────────────────────────────

/// All possible states the receipt-scan flow can be in.
sealed class ScanReceiptState {
  const ScanReceiptState();
}

/// Default idle state — camera is ready.
class ScanInitial extends ScanReceiptState {
  const ScanInitial();
}

/// OCR is running — show loading overlay.
class ScanScanning extends ScanReceiptState {
  const ScanScanning();
}

/// OCR succeeded — data ready to display on Screen 2.
class ScanParsed extends ScanReceiptState {
  final ParsedReceiptData data;
  const ScanParsed(this.data);
}

/// Supabase INSERT is in progress.
class ScanSaving extends ScanReceiptState {
  const ScanSaving();
}

/// Insert succeeded — navigate home.
class ScanSaved extends ScanReceiptState {
  const ScanSaved();
}

/// Something went wrong — show snackbar.
class ScanError extends ScanReceiptState {
  final String message;
  const ScanError(this.message);
}

// ─────────────────────────────────────────────────────────────────────────────
// NOTIFIER
// ─────────────────────────────────────────────────────────────────────────────

class ScanReceiptNotifier extends StateNotifier<ScanReceiptState> {
  ScanReceiptNotifier(this._ref) : super(const ScanInitial());

  final Ref _ref;
  final OcrService _ocr = OcrService();
  final SupabaseClient _supabase = Supabase.instance.client;

  // ── Step 1: Camera → OCR → Parse ──────────────────────────────────────────

  Future<void> scanImage(File imageFile) async {
    state = const ScanScanning();
    try {
      final rawText = await _ocr.extractText(imageFile);
      final parsed = ReceiptParser.parse(rawText);
      state = ScanParsed(parsed);
    } on OcrException catch (e) {
      state = ScanError(e.message);
    } catch (e) {
      state = ScanError('Unexpected error: $e');
    }
  }

  // ── Step 2: Confirm → Insert into Supabase → refresh home ─────────────────

  Future<void> saveTransaction(ParsedReceiptData data) async {
    state = const ScanSaving();
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated.');

      // ① Resolve category_id (required by schema for expense transactions)
      final categoryId = await _resolveOrCreateCategory(
        userId,
        data.categoryName,
      );

      // ② Insert transaction into public.transactions
      //    Column names taken verbatim from spendly_schema.sql
      await _supabase.from('transactions').insert({
        'users_id': userId,
        'type': 'expense',
        'amount': data.amount > 0 ? data.amount : 1.0, // amount CHECK > 0
        'title': data.title.isNotEmpty ? data.title : 'Scanned Receipt',
        'description': data.description,
        'category_id': categoryId,
        'input_method': 'receipt_scan',
        // transaction_date defaults to CURRENT_DATE in Postgres
      });

      // ③ Also push to local in-memory provider so home_screen shows it instantly
      final localModel = TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: data.title.isNotEmpty ? data.title : 'Scanned Receipt',
        description: data.description,
        amount: data.amount > 0 ? data.amount : 1.0,
        category: data.categoryName,
        type: 'expense',
        dateTime: DateTime.now(),
      );
      _ref.read(transactionProvider.notifier).addTransaction(localModel);
      _ref.invalidate(transactionsListProvider);
      _ref.invalidate(mainFinanceProvider);
      state = const ScanSaved();
    } catch (e) {
      state = ScanError('Failed to save: $e');
    }
  }

  /// Looks up an existing category by name for this user.
  /// Creates one with a default icon if it doesn't exist yet.
  /// Returns the category UUID needed for the composite FK.
  Future<String> _resolveOrCreateCategory(
    String userId,
    String categoryName,
  ) async {
    // Query the user's categories for a matching name
    final existing = await _supabase
        .from('categories')
        .select('id')
        .eq('users_id', userId)
        .eq('name', categoryName)
        .maybeSingle();

    if (existing != null) {
      return existing['id'] as String;
    }

    // Category doesn't exist yet — create it with a sensible default icon
    final iconName = _defaultIconFor(categoryName);
    final inserted = await _supabase
        .from('categories')
        .insert({'users_id': userId, 'name': categoryName, 'icon': iconName})
        .select('id')
        .single();

    return inserted['id'] as String;
  }

  /// Maps a category name to a Flutter icon name string for the `icon` column.
  String _defaultIconFor(String categoryName) {
    switch (categoryName) {
      case 'Food / Dining':
        return 'restaurant_rounded';
      case 'Groceries':
        return 'shopping_basket_rounded';
      case 'Transportation':
        return 'directions_car_rounded';
      case 'Bills & Subscriptions':
        return 'receipt_long_rounded';
      case 'Shopping':
        return 'shopping_bag_rounded';
      case 'Health':
        return 'local_hospital_rounded';
      case 'Gym / Fitness':
        return 'fitness_center_rounded';
      default:
        return 'category_rounded';
    }
  }

  /// Reset back to idle (e.g. after an error, or when navigating away).
  void reset() => state = const ScanInitial();
}

// ─────────────────────────────────────────────────────────────────────────────
// PROVIDER
// ─────────────────────────────────────────────────────────────────────────────

final scanReceiptProvider =
    StateNotifierProvider<ScanReceiptNotifier, ScanReceiptState>((ref) {
      return ScanReceiptNotifier(ref);
    });

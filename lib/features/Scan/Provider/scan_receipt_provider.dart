import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/core/categories/category_helpers.dart';
import 'package:spendly/features/main/providers/main_finance_provider.dart';
import 'package:spendly/features/main/providers/transactions_list_provider.dart';
import 'package:spendly/features/wallet/providers/category_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spendly/features/Scan/Service/ocr_service.dart';
import 'package:spendly/features/Scan/Service/receipt_parser.dart';
import 'package:spendly/features/main/providers/transaction_notifier.dart';
import 'package:spendly/features/main/models/transaction_model.dart';

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
    } catch (e) {
      state = ScanError('OCR failed: $e');
    }
  }

  // ── Step 2: Confirm → Insert into Supabase → refresh home ─────────────────

  Future<void> saveTransaction(ParsedReceiptData data) async {
    state = const ScanSaving();
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated.');

      // ① The categoryName from ReceiptParser is already canonical.
      //    Use CategoryHelpers to resolve the icon key for the DB row.
      final category = CategoryHelpers.findByName(data.categoryName);
      final categoryId = await _resolveOrCreateCategory(
        userId,
        category.name,
        category.iconKey,
      );

      // ② Insert transaction into public.transactions
      await _supabase.from('transactions').insert({
        'users_id': userId,
        'type': 'expense',
        'amount': data.amount > 0 ? data.amount : 1.0,
        'title': data.title.isNotEmpty ? data.title : 'Scanned Receipt',
        'description': data.description,
        'category_id': categoryId,
        'input_method': 'receipt_scan',
      });

      // ③ Push to local in-memory provider so home_screen shows it instantly
      final localModel = TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: data.title.isNotEmpty ? data.title : 'Scanned Receipt',
        description: data.description,
        amount: data.amount > 0 ? data.amount : 1.0,
        category: category.name, // canonical name for correct icon display
        type: 'expense',
        dateTime: DateTime.now(),
      );
      _ref.read(transactionProvider.notifier).addTransaction(localModel);
      _ref.invalidate(transactionsListProvider);
      await _ref.read(mainFinanceProvider.notifier).refreshFinance();
      await _ref.read(walletProvider.notifier).refresh();
      state = const ScanSaved();
    } catch (e) {
      state = ScanError('Failed to save: $e');
    }
  }

  /// Looks up an existing category row by canonical name.
  /// Creates one with the correct icon key if it does not exist.
  Future<String> _resolveOrCreateCategory(
    String userId,
    String canonicalName,
    String iconKey,
  ) async {
    final existing = await _supabase
        .from('categories')
        .select('id')
        .eq('users_id', userId)
        .eq('name', canonicalName)
        .maybeSingle();

    if (existing != null) return existing['id'] as String;

    // Create with the icon key from the centralized category definition
    final inserted = await _supabase
        .from('categories')
        .insert({
          'users_id': userId,
          'name': canonicalName,
          'icon': iconKey,
        })
        .select('id')
        .single();

    return inserted['id'] as String;
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

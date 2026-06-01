import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/features/main/Repository/category_repository.dart';
import 'package:spendly/features/main/providers/main_finance_provider.dart';
import 'package:spendly/features/main/providers/transactions_list_provider.dart';
import 'package:spendly/features/authentication/providers/currency_provider.dart';
import 'package:spendly/features/main/models/parsed_transaction.dart';
import 'package:spendly/features/wallet/providers/category_provider.dart';
import 'package:spendly/theme/app_radius.dart';
import 'package:spendly/theme/colors.dart';
import 'package:spendly/theme/theme_extensions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VoiceConfirmationBottomSheet extends ConsumerStatefulWidget {
  final VoiceParseResult result;
  final String confirmedText;
  final String selectedLocale;

  const VoiceConfirmationBottomSheet({
    super.key,
    required this.result,
    required this.confirmedText,
    required this.selectedLocale,
  });

  @override
  ConsumerState<VoiceConfirmationBottomSheet> createState() =>
      _VoiceConfirmationBottomSheetState();
}

class _VoiceConfirmationBottomSheetState
    extends ConsumerState<VoiceConfirmationBottomSheet> {
  bool _isSaving = false;

  /// Saves all [ParsedTransaction]s from [result] to Supabase.
  Future<void> _saveVoiceTransactions() async {
    setState(() => _isSaving = true);
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      for (final tx in widget.result.transactions) {
        final isExpense = tx.intent != TransactionIntent.income;
        String? categoryId;

        if (isExpense) {
          categoryId = await resolveOrCreateCategory(
            supabase,
            userId,
            tx.category,
          );
        }

        final description = isExpense
            ? tx.description
            : (tx.description.isEmpty
                ? tx.category
                : '${tx.category} | ${tx.description}');

        await supabase.from('transactions').insert({
          'users_id': userId,
          'type': tx.intentString,
          'amount': tx.amount > 0 ? tx.amount : 1.0,
          'title': tx.title.isNotEmpty ? tx.title : 'Voice Transaction',
          'description': description,
          'category_id': categoryId,
          'input_method': 'voice',
        });
      }

      // Invalidate providers so all screens (including Track tab) rebuild
      // reactively with the latest spending data.
      ref.invalidate(transactionsListProvider);
      ref.invalidate(mainFinanceProvider);
      // walletProvider is a StateNotifierProvider — call refresh() instead of
      // invalidate() to reload data without recreating the notifier.
      unawaited(ref.read(walletProvider.notifier).refresh());
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save transactions: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
        Navigator.pop(context);
      }
    }
  }

  Widget _buildTxRow(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.subtitleColor,
          ),
        ),
        Text(
          value,
          style: context.textTheme.titleSmall?.copyWith(
            color: valueColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final curSymbol = ref.watch(currencySymbolProvider);
    final dominant = widget.result.dominantIntent;
    final isIncome = dominant == TransactionIntent.income;
    final accentColor = isIncome ? AppColors.income : AppColors.expense;

    return Container(
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: AppRadius.bottomSheetRadius,
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ────────────────────────────────────────────
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: context.onSurface.withValues(alpha: 0.15),
                  borderRadius: AppRadius.fullBorderRadius,
                ),
              ),
            ),
            Text(
              'Confirm Voice Transaction',
              textAlign: TextAlign.center,
              style: context.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // ── Intent badge ──────────────────────────────────────
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: AppRadius.fullBorderRadius,
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isIncome
                          ? Icons.arrow_downward_rounded
                          : Icons.arrow_upward_rounded,
                      size: 16,
                      color: accentColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isIncome ? 'Income' : 'Expense',
                      style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Raw text bubble ───────────────────────────────────
            Text(
              'You said:',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.subtitleColor,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerHighest,
                borderRadius: AppRadius.mdBorderRadius,
                border: Border.all(color: context.colors.outline),
              ),
              child: Text(
                widget.confirmedText,
                textDirection: widget.selectedLocale == 'ar'
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                style: context.textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 16),

            // ── Transaction list ──────────────────────────────────
            ...widget.result.transactions.asMap().entries.map((entry) {
              final i = entry.key;
              final tx = entry.value;
              final txIsIncome = tx.intent == TransactionIntent.income;
              final txColor = txIsIncome
                  ? AppColors.income
                  : AppColors.expense;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.colors.surfaceContainerHighest,
                  borderRadius: AppRadius.lgBorderRadius,
                  border: Border.all(color: txColor.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.result.isMultiple)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Transaction ${i + 1}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: context.subtitleColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    _buildTxRow(context, 'Category', tx.category),
                    const SizedBox(height: 6),
                    _buildTxRow(
                      context,
                      'Amount',
                      '$curSymbol${tx.amount.toStringAsFixed(2)}',
                      valueColor: txColor,
                    ),
                    const SizedBox(height: 6),
                    _buildTxRow(
                      context,
                      'Type',
                      txIsIncome ? 'Income' : 'Expense',
                      valueColor: txColor,
                    ),
                  ],
                ),
              );
            }),

            // ── Total (only for multiple transactions) ────────────
            if (widget.result.isMultiple)
              Container(
                margin: const EdgeInsets.only(top: 4, bottom: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.08),
                  borderRadius: AppRadius.lgBorderRadius,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '$curSymbol${widget.result.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // ── Action buttons ────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSaving ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveVoiceTransactions,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Confirm'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

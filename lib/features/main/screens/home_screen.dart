import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:skeletonizer/skeletonizer.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:spendly/features/main/CategoryRepository.dart';
import 'package:spendly/features/main/providers/main_finance_provider.dart';
import 'package:spendly/features/main/providers/transactions_list_provider.dart';
import 'package:spendly/features/authentication/providers/currency_provider.dart';
import 'dart:async';

import 'package:spendly/features/main/widgets/budget_Card.dart';
import 'package:spendly/features/main/widgets/headersection.dart';
import 'package:spendly/features/main/widgets/transaction_item.dart';

import 'package:spendly/features/main/utils/voice_transaction_parser.dart';
import 'package:spendly/features/main/models/parsed_transaction.dart';
import 'package:spendly/features/main/transaction_bottom.dart';
import 'package:spendly/theme/app_radius.dart';
import 'package:spendly/theme/colors.dart';
import 'package:spendly/theme/theme_extensions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spendly/services/connectivity/connectivity_provider.dart';
import 'package:spendly/services/sync/offline_sync_manager.dart';
import 'package:spendly/widgets/offline_banner.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool   _isListening    = false;

  /// Running display text — updated on every partial result for the live UI.
  String _text           = '';

  /// The last text confirmed with finalResult == true.
  /// This is what gets parsed — never a truncated partial.
  String _finalText      = '';

  /// Set to true once the engine emits finalResult == true, so
  /// _stopListening knows it can safely parse without racing.
  bool   _hasFinalResult = false;

  /// Completer resolved when the speech engine delivers its final result.
  Completer<void>? _finalResultCompleter;

  String _selectedLocale = 'ar';
  Timer? _timer;
  int    _recordDuration = 0;
  final int _maxDuration = 30;

  void _openAddTransactionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddTransactionBottomSheet(),
    );
  }

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    await _speech.initialize(
      onError:  (val) => print('onError: $val'),
      onStatus: (val) => print('onStatus: $val'),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startListening() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission denied')),
      );
      return;
    }

    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (_isListening) _stopListening();
        }
      },
      onError: (e) => print('Error: $e'),
    );

    if (available) {
      // Reset all state for a fresh recording session.
      _finalResultCompleter = Completer<void>();
      setState(() {
        _isListening      = true;
        _text             = '';
        _finalText        = '';
        _hasFinalResult   = false;
        _recordDuration   = 0;
      });

      _speech.listen(
        onResult: (val) {
          // Always update the running display so the user sees live words.
          setState(() => _text = val.recognizedWords);

          // Only commit to _finalText when the engine is confident the
          // utterance is complete.  val.finalResult is true exactly once
          // per recognised utterance (or once when the engine decides to
          // finalise on silence / stop()).
          if (val.finalResult && val.recognizedWords.trim().isNotEmpty) {
            _finalText      = val.recognizedWords;
            _hasFinalResult = true;
            if (!(_finalResultCompleter?.isCompleted ?? true)) {
              _finalResultCompleter!.complete();
            }
          }
        },
        listenFor:     Duration(seconds: _maxDuration),
        pauseFor:      const Duration(seconds: 3),
        listenOptions: stt.SpeechListenOptions(partialResults: true),
        localeId:      _selectedLocale,
      );

      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        setState(() => _recordDuration++);
        if (_recordDuration >= _maxDuration) _stopListening();
      });
    }
  }

  void _stopListening() async {
    _timer?.cancel();

    // Ask the engine to stop.  After stop(), the engine may still
    // fire one final onResult with finalResult == true — we must
    // wait for it rather than using a fixed timer.
    await _speech.stop();
    setState(() => _isListening = false);

    // Wait up to 1.5 s for the engine to deliver its final result.
    // If it already arrived (hasFinalResult == true) the completer
    // is already resolved and this returns instantly.
    if (!_hasFinalResult && _finalResultCompleter != null) {
      await _finalResultCompleter!.future
          .timeout(const Duration(milliseconds: 1500), onTimeout: () {});
    }

    // Use the engine-confirmed final text; fall back to the last
    // partial text if (for some reason) no final result arrived.
    final textToProcess =
        _finalText.isNotEmpty ? _finalText : _text;

    if (textToProcess.trim().isNotEmpty) {
      _showConfirmationSheet(textToProcess);
    }
  }

  void _showConfirmationSheet(String confirmedText) {
    final result = VoiceTransactionParser.parse(confirmedText);
    if (result.isEmpty) return;

    final curSymbol = ref.read(currencySymbolProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final dominant = result.dominantIntent;
        final isIncome = dominant == TransactionIntent.income;
        final accentColor =
            isIncome ? AppColors.income : AppColors.expense;

        return Container(
          decoration: BoxDecoration(
            color: ctx.surface,
            borderRadius: AppRadius.bottomSheetRadius,
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
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
                    width: 40, height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: ctx.onSurface.withValues(alpha: 0.15),
                      borderRadius: AppRadius.fullBorderRadius,
                    ),
                  ),
                ),
                Text(
                  'Confirm Voice Transaction',
                  textAlign: TextAlign.center,
                  style: ctx.textTheme.titleLarge,
                ),
                const SizedBox(height: 16),

                // ── Intent badge ──────────────────────────────────────
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      borderRadius: AppRadius.fullBorderRadius,
                      border: Border.all(
                          color: accentColor.withValues(alpha: 0.4)),
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
                  style: ctx.textTheme.bodySmall
                      ?.copyWith(color: ctx.subtitleColor),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ctx.colors.surfaceContainerHighest,
                    borderRadius: AppRadius.mdBorderRadius,
                    border: Border.all(color: ctx.colors.outline),
                  ),
                  child: Text(
                    confirmedText,
                    textDirection: _selectedLocale == 'ar'
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    style: ctx.textTheme.bodyLarge,
                  ),
                ),
                const SizedBox(height: 16),

                // ── Transaction list ──────────────────────────────────
                ...result.transactions.asMap().entries.map((entry) {
                  final i = entry.key;
                  final tx = entry.value;
                  final txIsIncome = tx.intent == TransactionIntent.income;
                  final txColor =
                      txIsIncome ? AppColors.income : AppColors.expense;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: ctx.colors.surfaceContainerHighest,
                      borderRadius: AppRadius.lgBorderRadius,
                      border: Border.all(
                          color: txColor.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (result.isMultiple)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              'Transaction ${i + 1}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: ctx.subtitleColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        _buildTxRow(ctx, 'Category', tx.category),
                        const SizedBox(height: 6),
                        _buildTxRow(
                          ctx,
                          'Amount',
                          '$curSymbol${tx.amount.toStringAsFixed(2)}',
                          valueColor: txColor,
                        ),
                        const SizedBox(height: 6),
                        _buildTxRow(
                          ctx,
                          'Type',
                          txIsIncome ? 'Income' : 'Expense',
                          valueColor: txColor,
                        ),
                      ],
                    ),
                  );
                }),

                // ── Total (only for multiple transactions) ────────────
                if (result.isMultiple)
                  Container(
                    margin: const EdgeInsets.only(top: 4, bottom: 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.08),
                      borderRadius: AppRadius.lgBorderRadius,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: ctx.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '$curSymbol${result.totalAmount.toStringAsFixed(2)}',
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
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await _saveVoiceTransactions(result);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Confirm'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Saves all [ParsedTransaction]s from [result] to Supabase.
  Future<void> _saveVoiceTransactions(VoiceParseResult result) async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    for (final tx in result.transactions) {
      final isExpense = tx.intent != TransactionIntent.income;
      String? categoryId;

      if (isExpense) {
        categoryId = await resolveOrCreateCategory(
          supabase,
          userId,
          tx.category,
        );
      }

      await supabase.from('transactions').insert({
        'users_id': userId,
        'type': tx.intentString,
        'amount': tx.amount > 0 ? tx.amount : 1.0,
        'title': tx.title.isNotEmpty ? tx.title : 'Voice Transaction',
        'description': tx.description,
        'category_id': categoryId,
        'input_method': 'voice',
      });
    }

    ref.invalidate(transactionsListProvider);
    ref.invalidate(mainFinanceProvider);
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
        Text(label,
            style: context.textTheme.bodySmall
                ?.copyWith(color: context.subtitleColor)),
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

  String _formatDuration(int seconds) {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final txAsync = ref.watch(transactionsListProvider);
    final isOnline = ref.watch(connectivityServiceProvider).isOnline;
    
    // Ensure the sync manager is active
    ref.watch(offlineSyncProvider);

    return txAsync.when(
      data: (transactions) {
        return Scaffold(
          body: Stack(
            children: [
              // Background image
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Image.asset(
                  'assets/images/main background.png',
                  fit: BoxFit.cover,
                  height: 320,
                ),
              ),

              SafeArea(
                child: Column(
                  children: [
                    if (!isOnline) const OfflineBanner(),
                    const Headersection(),
                    const BudgetCard(),
Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Transactions',
                                    style: context.textTheme.headlineSmall,
                                  ),
                                  GestureDetector(
                                    onTap: _openAddTransactionSheet,
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: context.colors.outline,
                                        ),
                                        borderRadius:
                                            AppRadius.mdBorderRadius,
                                      ),
                                      child: Icon(
                                        Icons.add,
                                        color: context.onSurface,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // ── Recent / See all ─────────────────────────
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 4,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Recent Transactions',
                                    style: context.textTheme.titleSmall,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      context.push('/all-transactions');
                                    },
                                    child: Text(
                                      'See all',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: context.colors.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            

                            // ── Transaction list or empty state ───────────
                            if (transactions.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 40,
                                ),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.flag_outlined,
                                        size: 64,
                                        color: context.hintColor,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No Transactions yet',
                                        style:
                                            context.textTheme.headlineSmall,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Set your first Transaction\nand start tracking your progress.',
                                        textAlign: TextAlign.center,
                                        style:
                                            context.textTheme.bodySmall?.copyWith(
                                          color: context.subtitleColor,
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              Column(
                                children: transactions.take(5).map((tx) {
                                  final isIncome = tx.type == 'income';
                                  return TransactionItem(
                                    data: TransactionData(
                                      id: tx.id,
                                      title: tx.title,
                                      subtitle: tx.description.isNotEmpty
                                          ? tx.description
                                          : tx.category,
                                      amount: isIncome
                                          ? tx.amount
                                          : -tx.amount,
                                      icon: _getCategoryIcon(tx.category),
                                      iconBgColor: _getCategoryColor(
                                        tx.category,
                                      ).withValues(alpha: 0.1),
                                      iconColor:
                                          _getCategoryColor(tx.category),
                                    ),
                                    onDelete: () async {
                                      if (!isOnline) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Cannot delete transactions while offline')),
                                        );
                                        return;
                                      }
                                      await ref.read(transactionsListProvider.notifier).deleteTransaction(tx.id);
                                      await ref.read(mainFinanceProvider.notifier).refreshFinance();
                                    },
                                    onEdit: () {
                                      if (!isOnline) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Cannot edit transactions while offline')),
                                        );
                                        return;
                                      }
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (_) => AddTransactionBottomSheet(transactionToEdit: tx),
                                      );
                                    },
                                  );
                                }).toList(),
                              ),

                            const SizedBox(height: 120),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Recording dim overlay
              if (_isListening)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.3),
                  ),
                ),

              // FAB area: mic + language toggle + timer
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    if (_isListening)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: AppRadius.fullBorderRadius,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.expense,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${_formatDuration(_recordDuration)} / 0:$_maxDuration',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!_isListening) ...[
                          GestureDetector(
                            onTap: () => setState(
                              () => _selectedLocale = _selectedLocale == 'ar'
                                  ? 'en_US'
                                  : 'ar',
                            ),
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: context.surface,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  _selectedLocale == 'ar' ? 'ع' : 'EN',
                                  style: TextStyle(
                                    fontSize: _selectedLocale == 'ar' ? 20 : 14,
                                    fontWeight: FontWeight.bold,
                                    color: context.colors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                        // Mic button
                        GestureDetector(
                          onTap: () {
                            if (!isOnline) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Voice commands require an internet connection')),
                              );
                              return;
                            }
                            if (_isListening) {
                              _stopListening();
                            } else {
                              _startListening();
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width:  _isListening ? 70 : 60,
                            height: _isListening ? 70 : 60,
                            decoration: BoxDecoration(
                              color: _isListening
                                  ? AppColors.expense
                                  : AppColors.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: (_isListening
                                          ? AppColors.expense
                                          : AppColors.primary)
                                      .withValues(alpha: 0.4),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              _isListening ? Icons.stop : Icons.mic,
                              color: Colors.white,
                              size: _isListening ? 36 : 30,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
loading: () => Skeletonizer(
  enabled: true,
  child: Scaffold(
    body: Stack(
      children: [
        // Background image
        
        SafeArea(
          child: Column(
            children: [
              // Fake header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const CircleAvatar(radius: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 14,
                            width: 120,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 12,
                            width: 80,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Fake budget card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: context.surface,
                  borderRadius: AppRadius.lgBorderRadius,
                ),
              ),

              const SizedBox(height: 24),

              // Transactions title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 18,
                      width: 140,
                      color: Colors.white,
                    ),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppRadius.mdBorderRadius,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Fake transaction list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: 5,
                  itemBuilder: (_, __) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: context.surface,
                        borderRadius: AppRadius.lgBorderRadius,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 14,
                                  width: 120,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  height: 12,
                                  width: 80,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),

                          Container(
                            height: 14,
                            width: 60,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // Fake FAB
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    ),
  ),
),      error: (e, _) => Padding(
        padding: const EdgeInsets.all(24),
        child: Text('Failed to load transactions: $e'),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food':      return Icons.restaurant_rounded;
      case 'Transport': return Icons.directions_car_rounded;
      case 'Shopping':  return Icons.shopping_bag_rounded;
      case 'Bills':     return Icons.receipt_long_rounded;
      case 'Salary':    return Icons.account_balance_wallet_rounded;
      default:          return Icons.category_rounded;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food':      return const Color(0xFFFF9800);
      case 'Transport': return const Color(0xFFF44336);
      case 'Shopping':  return const Color(0xFF9C27B0);
      case 'Bills':     return const Color(0xFF2196F3);
      case 'Salary':    return const Color(0xFF1A237E);
      default:          return const Color(0xFF607D8B);
    }
  }
}

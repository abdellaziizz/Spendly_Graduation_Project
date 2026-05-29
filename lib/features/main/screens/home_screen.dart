import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:skeletonizer/skeletonizer.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:spendly/features/main/providers/main_finance_provider.dart';
import 'package:spendly/features/main/providers/transactions_list_provider.dart';
import 'package:spendly/features/authentication/providers/currency_provider.dart';
import 'dart:async';

import 'package:spendly/features/main/widgets/budget_Card.dart';
import 'package:spendly/features/main/widgets/headersection.dart';
import 'package:spendly/features/main/widgets/transaction_list_view.dart';
import 'package:spendly/features/main/widgets/voice_confirmation_bottom_sheet.dart';

import 'package:spendly/features/main/utils/voice_transaction_parser.dart';
import 'package:spendly/features/main/models/parsed_transaction.dart';
import 'package:spendly/features/main/widgets/transaction_bottom.dart';
import 'package:spendly/features/main/utils/category_utils.dart';
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
  bool _isListening = false;

  /// Running display text — updated on every partial result for the live UI.
  String _text = '';

  /// The last text confirmed with finalResult == true.
  /// This is what gets parsed — never a truncated partial.
  String _finalText = '';

  /// Set to true once the engine emits finalResult == true, so
  /// _stopListening knows it can safely parse without racing.
  bool _hasFinalResult = false;

  /// Completer resolved when the speech engine delivers its final result.
  Completer<void>? _finalResultCompleter;

  String _selectedLocale = 'ar';
  Timer? _timer;
  int _recordDuration = 0;
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
      onError: (val) => print('onError: $val'),
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
        _isListening = true;
        _text = '';
        _finalText = '';
        _hasFinalResult = false;
        _recordDuration = 0;
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
            _finalText = val.recognizedWords;
            _hasFinalResult = true;
            if (!(_finalResultCompleter?.isCompleted ?? true)) {
              _finalResultCompleter!.complete();
            }
          }
        },
        listenFor: Duration(seconds: _maxDuration),
        pauseFor: const Duration(seconds: 3),
        listenOptions: stt.SpeechListenOptions(partialResults: true),
        localeId: _selectedLocale,
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
      await _finalResultCompleter!.future.timeout(
        const Duration(milliseconds: 1500),
        onTimeout: () {},
      );
    }

    // Use the engine-confirmed final text; fall back to the last
    // partial text if (for some reason) no final result arrived.
    final textToProcess = _finalText.isNotEmpty ? _finalText : _text;

    if (textToProcess.trim().isNotEmpty) {
      final result = VoiceTransactionParser.parse(textToProcess);
      if (!result.isEmpty && mounted) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (ctx) => VoiceConfirmationBottomSheet(
            result: result,
            confirmedText: textToProcess,
            selectedLocale: _selectedLocale,
          ),
        );
      }
    }
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                borderRadius: AppRadius.mdBorderRadius,
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                        style: context.textTheme.headlineSmall,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Set your first Transaction\nand start tracking your progress.',
                                        textAlign: TextAlign.center,
                                        style: context.textTheme.bodySmall
                                            ?.copyWith(
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
                                      amount: isIncome ? tx.amount : -tx.amount,
                                      icon: CategoryUtils.getIcon(tx.category),
                                      iconBgColor: CategoryUtils.getColor(
                                        tx.category,
                                      ).withValues(alpha: 0.1),
                                      iconColor: CategoryUtils.getColor(tx.category),
                                    ),
                                    onDelete: () async {
                                      if (!isOnline) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Cannot delete transactions while offline',
                                            ),
                                          ),
                                        );
                                        return;
                                      }
                                      await ref
                                          .read(
                                            transactionsListProvider.notifier,
                                          )
                                          .deleteTransaction(tx.id);
                                      await ref
                                          .read(mainFinanceProvider.notifier)
                                          .refreshFinance();
                                    },
                                    onEdit: () {
                                      if (!isOnline) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Cannot edit transactions while offline',
                                            ),
                                          ),
                                        );
                                        return;
                                      }
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (_) =>
                                            AddTransactionBottomSheet(
                                              transactionToEdit: tx,
                                            ),
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
                  child: Container(color: Colors.black.withValues(alpha: 0.3)),
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
                                const SnackBar(
                                  content: Text(
                                    'Voice commands require an internet connection',
                                  ),
                                ),
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
                            width: _isListening ? 70 : 60,
                            height: _isListening ? 70 : 60,
                            decoration: BoxDecoration(
                              color: _isListening
                                  ? AppColors.expense
                                  : AppColors.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      (_isListening
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
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(24),
        child: Text('Failed to load transactions: $e'),
      ),
    );
  }

}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
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
import 'package:spendly/features/main/utils/voice_parser.dart';
import 'package:spendly/features/main/transaction_bottom.dart';
import 'package:spendly/theme/app_radius.dart';
import 'package:spendly/theme/colors.dart';
import 'package:spendly/theme/theme_extensions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool   _isListening    = false;
  String _text           = '';
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
      setState(() {
        _isListening    = true;
        _text           = '';
        _recordDuration = 0;
      });

      _speech.listen(
        onResult: (val) =>
            setState(() => _text = val.recognizedWords),
        listenFor:  Duration(seconds: _maxDuration),
        pauseFor:   const Duration(seconds: 5),
        partialResults: true,
        localeId:   _selectedLocale,
      );

      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        setState(() => _recordDuration++);
        if (_recordDuration >= _maxDuration) _stopListening();
      });
    }
  }

  void _stopListening() async {
    _timer?.cancel();
    await _speech.stop();
    setState(() => _isListening = false);
    await Future.delayed(const Duration(milliseconds: 300));
    if (_text.isNotEmpty) _showConfirmationSheet();
  }

  void _showConfirmationSheet() {
    final extractedData = VoiceParser.parse(_text);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: context.surface,
            borderRadius: AppRadius.bottomSheetRadius,
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Confirm your record',
                textAlign: TextAlign.center,
                style: context.textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              Text(
                'Did you say:',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.subtitleColor,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.colors.surfaceContainerHighest,
                  borderRadius: AppRadius.mdBorderRadius,
                  border: Border.all(color: context.colors.outline),
                ),
                child: Text(
                  _text,
                  textDirection: _selectedLocale == 'ar'
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  style: context.textTheme.bodyLarge,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.colors.surfaceContainerHighest,
                  borderRadius: AppRadius.lgBorderRadius,
                ),
                child: Column(
                  children: [
                    _buildExtractedRow(
                      context,
                      'Category',
                      extractedData.category,
                    ),
                    Divider(color: context.colors.outline),
                    _buildExtractedRow(
                      context,
                      'Amount',
                      '${ref.read(currencySymbolProvider)}${extractedData.amount.toStringAsFixed(2)}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('NO'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);

                        final supabase = Supabase.instance.client;
                        final userId   = supabase.auth.currentUser?.id;
                        if (userId == null) return;

                        final categoryId = await resolveOrCreateCategory(
                          supabase,
                          userId,
                          extractedData.category,
                        );

                        await supabase.from('transactions').insert({
                          'users_id':     userId,
                          'type':         'expense',
                          'amount':       extractedData.amount > 0
                              ? extractedData.amount
                              : 1.0,
                          'title':        extractedData.title.isNotEmpty
                              ? extractedData.title
                              : 'Voice Expense',
                          'description':  extractedData.description,
                          'category_id':  categoryId,
                          'input_method': 'voice',
                        });

                        ref.invalidate(transactionsListProvider);
                        ref.invalidate(mainFinanceProvider);
                      },
                      child: const Text('YES'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExtractedRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: context.textTheme.bodySmall),
        Text(
          value,
          style: context.textTheme.titleSmall,
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
                    const Headersection(),
                    const BudgetCard(),

                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Transactions header ──────────────────────
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
                                  Text(
                                    'See all',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: context.colors.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),

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
                                children: transactions.map((tx) {
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
                                      await ref.read(transactionsListProvider.notifier).deleteTransaction(tx.id);
                                      await ref.read(mainFinanceProvider.notifier).refreshFinance();
                                    },
                                    onEdit: () {
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
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Padding(
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:spendly/features/main/CategoryRepository.dart';
import 'package:spendly/features/main/providers/main_finance_provider.dart';
import 'package:spendly/features/main/providers/transactions_list_provider.dart';
import 'dart:async';

import 'package:spendly/features/main/widgets/budget_Card.dart';
import 'package:spendly/features/main/widgets/headersection.dart';
import 'package:spendly/features/main/widgets/transaction_item.dart';
import 'package:spendly/features/main/utils/voice_parser.dart';
import 'package:spendly/features/main/transaction_model.dart';
import 'package:spendly/features/main/transaction_bottom.dart';
import 'package:spendly/features/main/providers/transaction_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _text = '';

  // Language toggle: 'ar' for Arabic, 'en_US' for English
  String _selectedLocale = 'ar';

  // Timer for 30s max
  Timer? _timer;
  int _recordDuration = 0;
  final int _maxDuration = 30;

  void _openAddTransactionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const AddTransactionBottomSheet();
      },
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
      onError: (errorNotification) => print('Error: $errorNotification'),
    );

    if (available) {
      setState(() {
        _isListening = true;
        _text = '';
        _recordDuration = 0;
      });

      _speech.listen(
        onResult: (val) => setState(() {
          _text = val.recognizedWords;
        }),
        listenFor: Duration(seconds: _maxDuration),
        pauseFor: const Duration(seconds: 5),
        partialResults: true,
        localeId: _selectedLocale,
      );

      _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
        setState(() {
          _recordDuration++;
        });

        if (_recordDuration >= _maxDuration) {
          _stopListening();
        }
      });
    }
  }

  void _stopListening() async {
    _timer?.cancel();
    await _speech.stop();
    setState(() => _isListening = false);
    await Future.delayed(const Duration(milliseconds: 300));
    if (_text.isNotEmpty) {
      _showConfirmationSheet();
    }
  }

  void _showConfirmationSheet() {
    final extractedData = VoiceParser.parse(_text);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Confirm you record',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Did you say:',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8FC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E5EA)),
                ),
                child: Text(
                  _text,
                  textDirection: _selectedLocale == 'ar'
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF1A1A2E),
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildExtractedRow('Category', extractedData.category),
                    const Divider(),
                    _buildExtractedRow(
                      'Amount',
                      '\$${extractedData.amount.toStringAsFixed(2)}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: Color(0xFFD1D1D6)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'NO',
                        style: TextStyle(
                          color: Color(0xFF8E8E93),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2F5D8C),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        Navigator.pop(context);

                        final supabase = Supabase.instance.client;
                        final userId = supabase.auth.currentUser?.id;
                        if (userId == null) return;

                        // Voice always creates an EXPENSE (per app spec)
                        final categoryId = await resolveOrCreateCategory(
                          supabase,
                          userId,
                          extractedData.category,
                        );

                        // SQL:
                        // INSERT INTO public.transactions
                        //   (users_id, type, amount, title, description, category_id, input_method)
                        // VALUES ($userId, 'expense', $amount, $title, $desc, $catId, 'voice');
                        await supabase.from('transactions').insert({
                          'users_id': userId,
                          'type': 'expense',
                          'amount': extractedData.amount > 0
                              ? extractedData.amount
                              : 1.0,
                          'title': extractedData.title.isNotEmpty
                              ? extractedData.title
                              : 'Voice Expense',
                          'description': extractedData.description,
                          'category_id': categoryId,
                          'input_method': 'voice',
                        });

                        ref.invalidate(transactionsListProvider);
                        ref.invalidate(mainFinanceProvider);

                        // if (mounted) {
                        //   ScaffoldMessenger.of(context).showSnackBar(
                        //     const SnackBar(content: Text('Expense Added!')),
                        //   );
                        // }
                      },
                      child: const Text(
                        'YES',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  Widget _buildExtractedRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.black54, fontSize: 14),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black87,
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

    return txAsync.when(
      data: (transactions) {
        return Scaffold(
          body: Stack(
            children: [
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

                    // Transactions section
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: _openAddTransactionSheet,
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.add,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

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
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      //Add see all transaction screen
                                      // context.go('/seeall');
                                    },
                                    child: const Text(
                                      'See all',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF397BBD),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            transactions.isEmpty
                                ? const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 40),
                                    child: Center(
                                      child: Column(
                                        children: [
                                          const Icon(
                                            Icons.flag_outlined,
                                            size: 64,
                                            color: Color(0xFFCCCCDD),
                                          ),
                                          const SizedBox(height: 16),
                                          const Text(
                                            'No Transactions yet',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF1A1A2E),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            'Set your first Transaction\nand start tracking your progress.',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14,
                                              height: 1.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Column(
                                    children: transactions.map((tx) {
                                      final isIncome = tx.type == 'income';
                                      return TransactionItem(
                                        data: TransactionData(
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
                                          ).withOpacity(0.1),
                                          iconColor: _getCategoryColor(
                                            tx.category,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),

                            // Add padding so bottom items aren't obscured by FAB
                            const SizedBox(height: 120),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Dim overlay when recording
              if (_isListening)
                Positioned.fill(
                  child: Container(color: Colors.black.withOpacity(0.3)),
                ),

              // Floating Mic Button, Language Toggle & Timer
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
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${_formatDuration(_recordDuration)} / 0:${_maxDuration}',
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
                        // Language toggle button (hidden while recording)
                        if (!_isListening)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedLocale = _selectedLocale == 'ar'
                                    ? 'en_US'
                                    : 'ar';
                              });
                            },
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
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
                                    color: const Color(0xFF397BBD),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (!_isListening) const SizedBox(width: 16),
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
                            width: _isListening ? 70 : 60,
                            height: _isListening ? 70 : 60,
                            decoration: BoxDecoration(
                              color: _isListening
                                  ? Colors.red
                                  : const Color(0xFF397BBD),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      (_isListening
                                              ? Colors.red
                                              : const Color(0xFF397BBD))
                                          .withOpacity(0.4),
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
      loading: () => const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(24),
        child: Text('Failed to load transactions: $e'),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant_rounded;
      case 'Transport':
        return Icons.directions_car_rounded;
      case 'Shopping':
        return Icons.shopping_bag_rounded;
      case 'Bills':
        return Icons.receipt_long_rounded;
      case 'Salary':
        return Icons.account_balance_wallet_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food':
        return const Color(0xFFFF9800);
      case 'Transport':
        return const Color(0xFFF44336);
      case 'Shopping':
        return const Color(0xFF9C27B0);
      case 'Bills':
        return const Color(0xFF2196F3);
      case 'Salary':
        return const Color(0xFF1A237E);
      default:
        return const Color(0xFF607D8B);
    }
  }
}

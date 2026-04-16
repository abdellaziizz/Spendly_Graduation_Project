import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

import 'package:tspendly/features/main/widgets/budget_Card.dart';
import 'package:tspendly/features/main/widgets/headersection.dart';
import 'package:tspendly/features/main/widgets/transaction_item.dart';
import 'package:tspendly/features/main/utils/voice_parser.dart';
import 'package:tspendly/features/main/transaction_model.dart';
import 'package:tspendly/features/main/transaction_bottom.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _text = '';

  // Timer for 30s max
  Timer? _timer;
  int _recordDuration = 0;
  final int _maxDuration = 30;

  // Manual transactions list
  final List<TransactionModel> _manualTransactions = [];

  void _openAddTransactionSheet() async {
    final TransactionModel? newTransaction =
        await showModalBottomSheet<TransactionModel>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) {
            return const AddTransactionBottomSheet();
          },
        );

    if (newTransaction != null) {
      setState(() {
        _manualTransactions.insert(0, newTransaction);
      });
    }
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
              const Text(
                'Confirm you record',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Did you say: $_text',
                style: const TextStyle(fontSize: 16, color: Color(0xFF1A1A2E)),
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
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Expense Added!')),
                        );
                        // TODO: Save to database via Riverpod
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
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: Stack(
        children: [
          // Background gradient image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/mesh-gradient.png',
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Transactions',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1A2E),
                                ),
                              ),
                              GestureDetector(
                                onTap: _openAddTransactionSheet,
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.black,
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Recent Transactions',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A1A2E),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  context.go('/seeall');
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

                        // Manually added transactions
                        ..._manualTransactions.map((tx) {
                          final isIncome = tx.type == 'income';
                          return TransactionItem(
                            data: TransactionData(
                              title: tx.title,
                              subtitle: tx.description.isNotEmpty
                                  ? tx.description
                                  : tx.category,
                              amount: isIncome ? tx.amount : -tx.amount,
                              icon: _getCategoryIcon(tx.category),
                              iconBgColor: _getCategoryColor(
                                tx.category,
                              ).withOpacity(0.1),
                              iconColor: _getCategoryColor(tx.category),
                            ),
                          );
                        }),

                        // Sample transaction items
                        ...sampleTransactions.map(
                          (tx) => TransactionItem(data: tx),
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

          // Floating Mic Button & Timer
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
          ),
        ],
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

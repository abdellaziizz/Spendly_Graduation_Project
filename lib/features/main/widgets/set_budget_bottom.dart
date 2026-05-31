import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/features/main/providers/main_finance_provider.dart';
import 'package:spendly/theme/app_radius.dart';
import 'package:spendly/theme/theme_extensions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spendly/features/authentication/providers/currency_provider.dart';

class SetBudgetSheet extends ConsumerStatefulWidget {
  const SetBudgetSheet({super.key});

  @override
  ConsumerState<SetBudgetSheet> createState() => _SetBudgetSheetState();
}

class _SetBudgetSheetState extends ConsumerState<SetBudgetSheet> {
  late TextEditingController _amountController;
  // Budget Suggestions in the same currency as the user's current balance
  final List<int> _suggestions = [1000, 2000, 3000, 4000, 5000];

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: '2,000.00');
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  String formatAmount(int amount) => amount.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );
  // Setting the selected suggestion as the input value when tapped
  void _onSuggestionTap(int amount) =>
      setState(() => _amountController.text = formatAmount(amount));

  @override
  Widget build(BuildContext context) {
    final netBalance = ref.watch(
      mainFinanceProvider.select((a) => a.value?.netBalance ?? 0.0),
    );
    final curSymbol = ref.watch(currencySymbolProvider);
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final currentMonth = months[DateTime.now().month - 1];

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 16,
      ),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: AppRadius.bottomSheetRadius,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Drag handle ──────────────────────────────────────────────────
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: context.onSurface.withValues(alpha: 0.15),
                  borderRadius: AppRadius.fullBorderRadius,
                ),
              ),
            ),

            // ── Header ───────────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Set Monthly Budget',
                  style: context.textTheme.headlineSmall,
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: context.subtitleColor),
                ),
              ],
            ),
            Text(
              'Define your spending limit for $currentMonth',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.subtitleColor,
              ),
            ),
            const SizedBox(height: 32),

            // ── Amount input ─────────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  curSymbol,
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: context.hintColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: context.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      filled: false,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Current spend badge ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.08),
                borderRadius: AppRadius.fullBorderRadius,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    color: context.colors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Current Balance: $curSymbol$netBalance',
                    style: TextStyle(
                      color: context.colors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── Quick suggestions ────────────────────────────────────────────
            Text(
              'QUICK SUGGESTIONS',
              style: context.textTheme.labelSmall?.copyWith(
                letterSpacing: 1.2,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _suggestions.map((amount) {
                  final formattedAmount = formatAmount(amount);
                  final isSelected =
                      _amountController.text
                          .replaceAll(',', '')
                          .split('.')[0] ==
                      amount.toString();
                  return GestureDetector(
                    onTap: () => _onSuggestionTap(amount),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? context.colors.primary.withValues(alpha: 0.1)
                            : context.colors.surfaceContainerHighest,
                        borderRadius: AppRadius.lgBorderRadius,
                        border: Border.all(
                          color: isSelected
                              ? context.colors.primary
                              : context.colors.outline,
                        ),
                      ),
                      child: Text(
                        '$curSymbol$formattedAmount',
                        style: TextStyle(
                          color: isSelected
                              ? context.colors.primary
                              : context.subtitleColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 40),

            // ── Save button ──────────────────────────────────────────────────
            ElevatedButton(
              onPressed: () async {
                final amount =
                    double.tryParse(
                      _amountController.text.replaceAll(',', ''),
                    ) ??
                    0.0;
                if (amount <= 0) return;

                final supabase = Supabase.instance.client;
                if (supabase.auth.currentUser?.id == null) return;

                // setBudget() does the upsert AND refreshes state — one call, correct order
                await ref.read(mainFinanceProvider.notifier).setBudget(amount);

                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save Budget'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

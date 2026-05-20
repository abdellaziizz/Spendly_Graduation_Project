import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:spendly/features/main/CategoryRepository.dart';
import 'package:spendly/features/main/providers/main_finance_provider.dart';
import 'package:spendly/features/main/providers/transactions_list_provider.dart';
import 'package:spendly/theme/app_radius.dart';
import 'package:spendly/theme/colors.dart';
import 'package:spendly/theme/theme_extensions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/features/authentication/providers/currency_provider.dart';
class AddTransactionBottomSheet extends ConsumerStatefulWidget {
  const AddTransactionBottomSheet({super.key});

  @override
  ConsumerState<AddTransactionBottomSheet> createState() =>
      _AddTransactionBottomSheetState();
}

class _AddTransactionBottomSheetState
    extends ConsumerState<AddTransactionBottomSheet> {
  int     _selectedType     = 0; // 0 = Expense, 1 = Income
  String? _selectedCategory;

  final _amountController      = TextEditingController();
  final _titleController       = TextEditingController();
  final _descriptionController = TextEditingController();

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Groceries',  'icon': Icons.shopping_basket_outlined},
    {'name': 'Transport',  'icon': Icons.directions_car_outlined},
    {'name': 'Dining Out', 'icon': Icons.restaurant_outlined},
    {'name': 'Leisure',    'icon': Icons.movie_creation_outlined},
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _confirm() async {
    if (_titleController.text.trim().isEmpty ||
        _amountController.text.trim().isEmpty ||
        _selectedCategory == null) return;

    final double amount =
        double.tryParse(_amountController.text.trim()) ?? 0.0;
    if (amount <= 0) return;

    final supabase = Supabase.instance.client;
    final userId   = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final isExpense = _selectedType == 0;
    String? categoryId;

    if (isExpense) {
      categoryId = await resolveOrCreateCategory(
        supabase,
        userId,
        _selectedCategory!,
      );
    }

    await supabase.from('transactions').insert({
      'users_id':    userId,
      'type':        isExpense ? 'expense' : 'income',
      'amount':      amount,
      'title':       _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'category_id': categoryId,
      'input_method': 'manual',
    });

    ref.invalidate(transactionsListProvider);
    ref.invalidate(mainFinanceProvider);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final curSymbol = ref.watch(currencySymbolProvider);
    final amountColor = _selectedType == 0
        ? AppColors.expense
        : AppColors.income;

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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Drag handle ───────────────────────────────────────────────
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

            // ── Header ────────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add Transaction',
                  style: context.textTheme.headlineSmall,
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  style: IconButton.styleFrom(
                    backgroundColor: context.colors.surfaceContainerHighest,
                  ),
                  icon: Icon(
                    Icons.close,
                    color: context.subtitleColor,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Amount input ──────────────────────────────────────────────
            Center(
              child: Text(
                'Transaction Amount',
                style: context.textTheme.labelMedium,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
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
                const SizedBox(width: 12),
                IntrinsicWidth(
                  child: TextField(
                    controller: _amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: amountColor,
                    ),
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: '0.00',
                      hintStyle: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: context.hintColor,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Expense / Income toggle ───────────────────────────────────
            Center(
              child: CustomSlidingSegmentedControl<int>(
                initialValue: _selectedType,
                children: {
                  0: Text(
                    'Expense',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: context.onSurface,
                    ),
                  ),
                  1: Text(
                    'Income',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: context.onSurface,
                    ),
                  ),
                },
                decoration: BoxDecoration(
                  color: context.colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(30),
                ),
                thumbDecoration: BoxDecoration(
                  color: context.surface,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInToLinear,
                onValueChanged: (v) => setState(() => _selectedType = v),
              ),
            ),
            const SizedBox(height: 24),

            // ── Title ─────────────────────────────────────────────────────
            Text('Title', style: context.textTheme.labelLarge),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'e.g. Weekly Groceries',
              ),
            ),
            const SizedBox(height: 20),

            // ── Category chips ────────────────────────────────────────────
            Text('Category', style: context.textTheme.labelLarge),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat['name'];
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedCategory = cat['name']),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? context.colors.primary.withValues(alpha: 0.1)
                          : context.colors.surfaceContainerHighest,
                      borderRadius: AppRadius.fullBorderRadius,
                      border: Border.all(
                        color: isSelected
                            ? context.colors.primary
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          cat['icon'] as IconData,
                          size: 18,
                          color: isSelected
                              ? context.colors.primary
                              : context.subtitleColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          cat['name'],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? context.colors.primary
                                : context.subtitleColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // ── Description ───────────────────────────────────────────────
            Text('Description', style: context.textTheme.labelLarge),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Add a note...',
              ),
            ),
            const SizedBox(height: 32),

            // ── Save button ───────────────────────────────────────────────
            ElevatedButton.icon(
              onPressed: _confirm,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Save Transaction'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:spendly/features/main/CategoryRepository.dart';
import 'package:spendly/features/main/providers/main_finance_provider.dart';
import 'package:spendly/features/main/providers/transactions_list_provider.dart';
import 'package:spendly/features/wallet/providers/category_provider.dart';
import 'package:spendly/features/wallet/models/budget_model.dart';
import 'package:spendly/theme/app_radius.dart';
import 'package:spendly/theme/colors.dart';
import 'package:spendly/theme/theme_extensions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/features/authentication/providers/currency_provider.dart';
import 'package:spendly/features/main/transaction_model.dart';

class AddTransactionBottomSheet extends ConsumerStatefulWidget {
  final TransactionModel? transactionToEdit;
  const AddTransactionBottomSheet({super.key, this.transactionToEdit});

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


  static const List<Map<String, dynamic>> _fallbackCategories = [
    {'name': 'Groceries',  'icon': Icons.shopping_basket_outlined},
    {'name': 'Transport',  'icon': Icons.directions_car_outlined},
    {'name': 'Dining Out', 'icon': Icons.restaurant_outlined},
    {'name': 'Health',     'icon': Icons.health_and_safety_outlined},
    {'name': 'Laptop',   'icon': Icons.laptop_mac_outlined},
    {'name': 'Beach',   'icon': Icons.beach_access_outlined},
    {'name': 'Home',   'icon': Icons.home_outlined},
    {'name': 'Flight',   'icon': Icons.flight_outlined},
    {'name': 'Gift',   'icon': Icons.card_giftcard_outlined},
    {'name': 'Date',   'icon': Icons.favorite_outline},
    {'name': 'Phone',   'icon': Icons.smartphone_outlined},
    {'name': 'School',   'icon': Icons.school_outlined},
  ];

  List<Map<String, dynamic>> _categoryOptions(List<BudgetModel> walletCategories) {
    final options = walletCategories
        .map(
          (budget) => <String, dynamic>{
            'name': budget.title,
            'icon': budget.icon,
          },
        )
        .toList();

    if (options.isEmpty) return List<Map<String, dynamic>>.from(_fallbackCategories);

    if (_selectedCategory != null &&
        !options.any((c) => c['name'] == _selectedCategory)) {
      options.add({
        'name': _selectedCategory,
        'icon': Icons.category_outlined,
      });
    }

    return options;
  }

  @override
  void initState() {
    super.initState();
    if (widget.transactionToEdit != null) {
      final tx = widget.transactionToEdit!;
      _selectedType = tx.type == 'expense' ? 0 : 1;
      _selectedCategory = tx.category.isNotEmpty ? tx.category : null;
      _amountController.text = tx.amount.toString();
      _titleController.text = tx.title;
      _descriptionController.text = tx.description;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _confirm() async {
    if (_titleController.text.trim().isEmpty ||
      _amountController.text.trim().isEmpty) return;

    final double amount =
        double.tryParse(_amountController.text.trim()) ?? 0.0;
    if (amount <= 0) return;

    final supabase = Supabase.instance.client;
    final userId   = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final isExpense = _selectedType == 0;
    String? categoryId;

    final categoryOptions = _categoryOptions(ref.read(walletProvider));

    if (isExpense) {
      _selectedCategory ??= categoryOptions.first['name'] as String;
      categoryId = await resolveOrCreateCategory(
        supabase,
        userId,
        _selectedCategory!,
      );
    } else if (_selectedCategory == null) {
      _selectedCategory = categoryOptions.first['name'] as String;
    }

    final dataMap = {
      'users_id':    userId,
      'type':        isExpense ? 'expense' : 'income',
      'amount':      amount,
      'title':       _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'category_id': categoryId,
      'input_method': 'manual',
    };

    if (widget.transactionToEdit == null) {
      await supabase.from('transactions').insert(dataMap);
    } else {
      await supabase.from('transactions').update(dataMap).eq('id', widget.transactionToEdit!.id);
    }

    if (mounted) Navigator.pop(context);

    unawaited(ref.read(transactionsListProvider.notifier).refresh());
    unawaited(ref.read(mainFinanceProvider.notifier).refreshFinance());
  }

  @override
  Widget build(BuildContext context) {
    final curSymbol = ref.watch(currencySymbolProvider);
    final walletCategories = ref.watch(walletProvider);
    final categoryOptions = _categoryOptions(walletCategories);
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
                  widget.transactionToEdit == null ? 'Add Transaction' : 'Edit Transaction',
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
                onValueChanged: (v) => setState(() {
                  _selectedType = v;
                  if (_selectedType == 0 && _selectedCategory == null && categoryOptions.isNotEmpty) {
                    _selectedCategory = categoryOptions.first['name'] as String;
                  }
                }),
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
            if (categoryOptions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  'Add wallet categories first so they appear here.',
                  style: TextStyle(color: context.subtitleColor),
                ),
              )
            else
              SizedBox(
                height: 120,
                child: GridView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categoryOptions.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    mainAxisExtent: 130,
                  ),
                  itemBuilder: (context, index) {
                    final cat = categoryOptions[index];
                    final isSelected = _selectedCategory == cat['name'];

                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat['name']),
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
                            Flexible(
                              child: Text(
                                cat['name'],
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? context.colors.primary
                                      : context.subtitleColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
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

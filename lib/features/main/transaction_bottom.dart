import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'transaction_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tspendly/features/main/providers/transaction_provider.dart';

class AddTransactionBottomSheet extends ConsumerStatefulWidget {
  const AddTransactionBottomSheet({super.key});

  @override
  ConsumerState<AddTransactionBottomSheet> createState() => _AddTransactionBottomSheetState();
}

class _AddTransactionBottomSheetState extends ConsumerState<AddTransactionBottomSheet> {
  int _selectedType = 0; // 0 for Expense, 1 for Income
  final _amountController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedCategory;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Groceries', 'icon': Icons.shopping_basket_outlined},
    {'name': 'Transport', 'icon': Icons.directions_car_outlined},
    {'name': 'Dining Out', 'icon': Icons.restaurant_outlined},
    {'name': 'Leisure', 'icon': Icons.movie_creation_outlined},
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _confirm() {
    if (_titleController.text.trim().isEmpty ||
        _amountController.text.trim().isEmpty ||
        _selectedCategory == null) {
      return;
    }
    final double amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    if (amount <= 0) return;

    final newTransaction = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      amount: amount,
      category: _selectedCategory!,
      type: _selectedType == 0 ? 'expense' : 'income',
      dateTime: DateTime.now(),
    );

    ref.read(transactionProvider.notifier).addTransaction(newTransaction);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final amountColor = _selectedType == 0 ? Colors.red : Colors.green;
    final hintColor = const Color(0xFFE5E5EA);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Add Transaction",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFF2F2FC),
                  ),
                  icon: const Icon(Icons.close, color: Colors.black54, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Amount Input
            Center(
              child: Text(
                "Transaction Amount",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "\$",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                IntrinsicWidth(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: amountColor,
                    ),
                    onChanged: (val) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      hintText: "0.00",
                      hintStyle: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: hintColor,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Toggle
            Center(
              child: CustomSlidingSegmentedControl<int>(
                initialValue: _selectedType,
                children: const {
                  0: Text('Expense', style: TextStyle(fontWeight: FontWeight.w600)),
                  1: Text('Income', style: TextStyle(fontWeight: FontWeight.w600)),
                },
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(30),
                ),
                thumbDecoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInToLinear,
                onValueChanged: (v) {
                  setState(() {
                    _selectedType = v;
                  });
                },
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              "Title",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF2F0FA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: "e.g. Weekly Groceries",
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Category
            Text(
              "Category",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat['name'];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = cat['name'];
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : const Color(0xFFF2F0FA),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF3730A3) : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          cat['icon'],
                          size: 18,
                          color: isSelected ? const Color(0xFF3730A3) : Colors.grey.shade700,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          cat['name'],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? const Color(0xFF3730A3) : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Description
            Text(
              "Description",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF2F0FA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _descriptionController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: "Add a note...",
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _confirm,
                icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                label: const Text(
                  "Save Transaction",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3730A3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spendly/features/Scan/receipt_parser.dart';
import 'package:spendly/features/Scan/scan_receipt_provider.dart';

/// Screen 2 — Shows OCR-parsed fields for user review + confirm / cancel.
/// The user can edit all 4 fields before saving.
class ScanResultScreen extends ConsumerStatefulWidget {
  final ParsedReceiptData initialData;

  const ScanResultScreen({super.key, required this.initialData});

  @override
  ConsumerState<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends ConsumerState<ScanResultScreen> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _amountCtrl;
  late final TextEditingController _categoryCtrl;
  late final TextEditingController _descriptionCtrl;

  @override
  void initState() {
    super.initState();
    final d = widget.initialData;
    _titleCtrl = TextEditingController(text: d.title);
    _amountCtrl =
        TextEditingController(text: d.amount > 0 ? d.amount.toStringAsFixed(2) : '');
    _categoryCtrl = TextEditingController(text: d.categoryName);
    _descriptionCtrl = TextEditingController(text: d.description);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _categoryCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  // ── Confirm tapped ─────────────────────────────────────────────────────────

  void _confirm() {
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (_titleCtrl.text.trim().isEmpty) {
      _showError('Please enter a title.');
      return;
    }
    if (amount == null || amount <= 0) {
      _showError('Please enter a valid amount greater than 0.');
      return;
    }
    if (_categoryCtrl.text.trim().isEmpty) {
      _showError('Please enter a category.');
      return;
    }

    final updated = ParsedReceiptData(
      title: _titleCtrl.text.trim(),
      amount: amount,
      categoryName: _categoryCtrl.text.trim(),
      description: _descriptionCtrl.text.trim(),
    );

    ref.read(scanReceiptProvider.notifier).saveTransaction(updated);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red.shade700));
  }

  @override
  Widget build(BuildContext context) {
    final scanState = ref.watch(scanReceiptProvider);
    final isSaving = scanState is ScanSaving;

    // Navigate to home on success
    ref.listen(scanReceiptProvider, (_, next) {
      if (next is ScanSaved) {
        if (mounted) context.go('/home');
      } else if (next is ScanError) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.message),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.chevron_left, size: 28),
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.document_scanner_outlined,
                        color: Colors.black54, size: 22),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // ── Success checkmark ─────────────────────────────────
                    Container(
                      width: 90,
                      height: 90,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF4CAF50),
                      ),
                      child: const Icon(Icons.check_rounded,
                          color: Colors.white, size: 52),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Scanning Confirmed',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Editable fields card ──────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9F9F9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFEEEEEE)),
                      ),
                      child: Column(
                        children: [
                          _EditableRow(
                            label: 'Title',
                            controller: _titleCtrl,
                            hint: 'e.g. Eye of Thai-ger',
                          ),
                          const _Divider(),
                          _EditableRow(
                            label: 'Amount (\$)',
                            controller: _amountCtrl,
                            hint: '0.00',
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+\.?\d{0,2}'))
                            ],
                          ),
                          const _Divider(),
                          _EditableRow(
                            label: 'Category',
                            controller: _categoryCtrl,
                            hint: 'e.g. Food / Dining',
                          ),
                          const _Divider(),
                          _EditableRow(
                            label: 'Description',
                            controller: _descriptionCtrl,
                            hint: 'Full receipt text…',
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // ── Confirm / Cancel buttons ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: isSaving
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF1B3A5C)))
                  : Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            label: 'Confirm',
                            onTap: _confirm,
                            filled: true,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _ActionButton(
                            label: 'Cancel',
                            onTap: () => context.pop(),
                            filled: false,
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LOCAL WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _EditableRow extends StatelessWidget {
  const _EditableRow({
    required this.label,
    required this.controller,
    this.hint = '',
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: maxLines > 1
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              maxLines: maxLines,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4CAF50),
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                    color: Colors.black26, fontWeight: FontWeight.normal),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, color: Color(0xFFEEEEEE));
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.onTap,
    required this.filled,
  });

  final String label;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? const Color(0xFF1B3A5C) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: filled
              ? null
              : Border.all(color: const Color(0xFFDDDDDD)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: filled ? Colors.white : Colors.black54,
          ),
        ),
      ),
    );
  }
}

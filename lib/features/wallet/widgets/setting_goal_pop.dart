import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/features/wallet/models/goal_model.dart';
import 'package:spendly/features/wallet/providers/goal_form_provider.dart';
import 'package:spendly/features/wallet/providers/goal_provider.dart';
import 'package:spendly/features/wallet/widgets/icon_picker_grid.dart';
import 'package:spendly/theme/app_radius.dart';
import 'package:spendly/theme/colors.dart';
import 'package:spendly/theme/theme_extensions.dart';

/// Bottom sheet for creating a new savings goal.
class AddGoal extends ConsumerStatefulWidget {
  const AddGoal({super.key});

  @override
  ConsumerState<AddGoal> createState() => _AddGoalState();
}

class _AddGoalState extends ConsumerState<AddGoal> {
  final _goalNameController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _deadlineDateController = TextEditingController();
  DateTime? _selectedDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _goalNameController.dispose();
    _targetAmountController.dispose();
    _deadlineDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      // DatePickerTheme is now set globally in AppTheme
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _deadlineDateController.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _submit() async {
    final name = _goalNameController.text.trim();
    final amountText = _targetAmountController.text.trim();

    if (name.isEmpty || amountText.isEmpty) {
      _showError('Please fill in Goal Name and Target Amount.');
      return;
    }

    final targetAmount = double.tryParse(amountText);
    if (targetAmount == null || targetAmount <= 0) {
      _showError('Please enter a valid target amount.');
      return;
    }

    final iconKey = ref.read(goalFormProvider).selectedIcon ?? 'savings';
    final newGoal = GoalModel(
      id: '',
      title: name,
      currentAmount: 0,
      targetAmount: targetAmount,
      icon: iconKey,
      status: 'active',
      deadlineDate: _selectedDate,
    );

    setState(() => _isLoading = true);
    try {
      await ref.read(goalProvider.notifier).addGoal(newGoal);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) _showError('Failed to save goal: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: context.errorColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + bottomInset),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: AppRadius.bottomSheetRadius,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Drag handle ────────────────────────────────────────────────
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.onSurface.withValues(alpha: 0.15),
                  borderRadius: AppRadius.fullBorderRadius,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Header ─────────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add New Goal',
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: context.colors.surfaceContainerHighest,
                      borderRadius: AppRadius.smBorderRadius,
                    ),
                    child: Icon(
                      Icons.close,
                      color: context.subtitleColor,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Goal Name ──────────────────────────────────────────────────
            _fieldLabel(context, 'Goal Name'),
            const SizedBox(height: 8),
            TextField(
              controller: _goalNameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(hintText: 'e.g. New Laptop'),
            ),
            const SizedBox(height: 20),

            // ── Icon Picker ────────────────────────────────────────────────
            _fieldLabel(context, 'Select Icon'),
            const SizedBox(height: 8),
            const IconPickerGrid(),
            const SizedBox(height: 20),

            // ── Target Amount ──────────────────────────────────────────────
            _fieldLabel(context, 'Target Amount'),
            const SizedBox(height: 8),
            TextField(
              controller: _targetAmountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: const InputDecoration(
                hintText: '0.00',
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
            const SizedBox(height: 20),

            // ── Deadline ───────────────────────────────────────────────────
            _fieldLabel(context, 'Deadline (optional)'),
            const SizedBox(height: 8),
            TextField(
              controller: _deadlineDateController,
              readOnly: true,
              onTap: () => _selectDate(context),
              decoration: const InputDecoration(
                hintText: 'Select a date',
                suffixIcon: Icon(Icons.calendar_today_outlined),
              ),
            ),
            const SizedBox(height: 32),

            // ── Submit ─────────────────────────────────────────────────────
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF397BBD),
                disabledBackgroundColor: AppColors.goalsAccent.withValues(
                  alpha: 0.5,
                ),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.lgBorderRadius,
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text(
                      'Save Goal',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(BuildContext context, String text) => Text(
    text,
    style: context.textTheme.labelLarge?.copyWith(color: context.subtitleColor),
  );
}

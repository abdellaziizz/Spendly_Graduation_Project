import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/features/authentication/providers/currency_provider.dart';
import 'package:spendly/features/wallet/models/goal_model.dart';
import 'package:spendly/features/wallet/providers/goal_provider.dart';
import 'package:spendly/theme/app_radius.dart';
import 'package:spendly/theme/colors.dart';
import 'package:spendly/theme/theme_extensions.dart';

class AddFundsSheet extends ConsumerStatefulWidget {
  const AddFundsSheet({super.key, required this.goal});

  final GoalModel goal;

  @override
  ConsumerState<AddFundsSheet> createState() => _AddFundsSheetState();
}

class _AddFundsSheetState extends ConsumerState<AddFundsSheet> {
  final TextEditingController _customController = TextEditingController();
  double _selectedAmount = 0.0;
  bool _isLoading = false;

  void _selectPreset(double amount) {
    setState(() {
      _selectedAmount = amount;
      _customController.text = amount.toStringAsFixed(0);
    });
  }

  Future<void> _addFunds() async {
    final amount = double.tryParse(_customController.text.trim()) ?? 0.0;
    if (amount <= 0) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newTotal = widget.goal.currentAmount + amount;
      await ref.read(goalProvider.notifier).updateGoalProgress(widget.goal.id, newTotal);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add funds: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final curSymbol = ref.watch(currencySymbolProvider);
    final bgColor = isDark ? AppColors.darkSurfaceElevated : Colors.white;
    final titleClr = isDark ? AppColors.textPrimaryDark : const Color(0xFF1E1E24);
    final labelClr = isDark ? AppColors.textSecondaryDark : const Color(0xFF5A5A65);
    final inputBg = isDark ? AppColors.darkSurface : const Color(0xFFF7F7FA);

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.bottomSheetRadius,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Add to ${widget.goal.title}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: titleClr,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.close, color: labelClr),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Quick Add',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: labelClr,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildPresetButton(10, curSymbol),
              const SizedBox(width: 12),
              _buildPresetButton(50, curSymbol),
              const SizedBox(width: 12),
              _buildPresetButton(100, curSymbol),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Custom Amount',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: labelClr,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _customController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(color: titleClr, fontSize: 18, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              prefixText: '$curSymbol ',
              prefixStyle: TextStyle(color: titleClr, fontSize: 18, fontWeight: FontWeight.w600),
              filled: true,
              fillColor: inputBg,
              border: OutlineInputBorder(
                borderRadius: AppRadius.mdBorderRadius,
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            onChanged: (val) {
              setState(() {
                _selectedAmount = double.tryParse(val) ?? 0.0;
              });
            },
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: (_isLoading || _selectedAmount <= 0) ? null : _addFunds,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.lgBorderRadius,
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      'Add Funds',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetButton(double amount, String symbol) {
    final isSelected = _selectedAmount == amount;
    final isDark = context.isDark;
    
    final selectedBg = AppColors.primary.withValues(alpha: 0.15);
    final unselectedBg = isDark ? AppColors.darkSurface : const Color(0xFFF1F0FA);
    
    final selectedText = AppColors.primary;
    final unselectedText = isDark ? AppColors.textPrimaryDark : const Color(0xFF1E1E24);
    
    final selectedBorder = AppColors.primary;
    final unselectedBorder = Colors.transparent;

    return Expanded(
      child: GestureDetector(
        onTap: () => _selectPreset(amount),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? selectedBg : unselectedBg,
            borderRadius: AppRadius.mdBorderRadius,
            border: Border.all(
              color: isSelected ? selectedBorder : unselectedBorder,
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            '+$symbol${amount.toStringAsFixed(0)}',
            style: TextStyle(
              color: isSelected ? selectedText : unselectedText,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}

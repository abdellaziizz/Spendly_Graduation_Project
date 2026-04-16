// 2. add_transaction_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tspendly/features/wallet/models/goal_model.dart';
import 'package:tspendly/features/wallet/providers/goal_form_provider.dart';
import 'package:tspendly/features/wallet/widgets/goal_preview_widget.dart';
import 'package:tspendly/features/wallet/widgets/icon_picker_widget.dart';

class AddGoal extends ConsumerStatefulWidget {
  const AddGoal({super.key});

  @override
  ConsumerState<AddGoal> createState() => _AddGoalState();
}

class _AddGoalState extends ConsumerState<AddGoal> {
  final _goalNameController = TextEditingController();
  final _targetMoneyController = TextEditingController();

  void _confirm() {
    if (_goalNameController.text.trim().isEmpty ||
        _targetMoneyController.text.trim().isEmpty) {
      return;
    }

    final double targetAmount =
        double.tryParse(_targetMoneyController.text.trim()) ?? 0.0;
    final double savedAmount =
        double.tryParse(_targetMoneyController.text.trim()) ?? 0.0;
    if (targetAmount <= 0) return;

    final newGoal = GoalModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _goalNameController.text.trim(),
      savedAmount: savedAmount,
      targetAmount: targetAmount,
      icon: Icons.person,
    );

    Navigator.pop(context, newGoal);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,

      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  "New Saving Goal",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                GoalPreviewCard(),
                const SizedBox(height: 8),
                TextField(
                  controller: _goalNameController,
                  onChanged: (value) {
                    ref.read(goalFormProvider.notifier).setGoalName(value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter the goal name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: _targetMoneyController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: '0.0',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const IconPickerGrid(),
                const SizedBox(height: 8),

                ElevatedButton(
                  onPressed: _confirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F5D8C),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Confirm',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

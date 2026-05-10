import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tspendly/features/wallet/models/goal_model.dart';
import 'package:tspendly/features/wallet/providers/goal_form_provider.dart';
import 'package:tspendly/features/wallet/widgets/icon_picker_grid.dart';

class AddGoal extends ConsumerStatefulWidget {
  const AddGoal({super.key});

  @override
  ConsumerState<AddGoal> createState() => _AddGoalState();
}

class _AddGoalState extends ConsumerState<AddGoal> {
  final _goalNameController = TextEditingController();
  final _targetMoneyController = TextEditingController();
  final _deadlineDateController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void dispose() {
    _goalNameController.dispose();
    _targetMoneyController.dispose();
    _deadlineDateController.dispose();
    super.dispose();
  }

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

    final selectedIcon =
        ref.read(goalFormProvider).selectedIcon ?? Icons.savings_outlined;

    final newGoal = GoalModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _goalNameController.text.trim(),
      savedAmount: savedAmount,
      targetAmount: targetAmount,
      icon: selectedIcon,
      deadlineDate: _selectedDate,
    );

    Navigator.pop(context, newGoal);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3B38D0), // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body text color
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _deadlineDateController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  final inputDecoration = InputDecoration(
    filled: true,
    fillColor: const Color(0xFFF5F5FA),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    hintStyle: const TextStyle(color: Colors.grey),
  );

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).viewInsets.top),
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
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Add New Goal",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF5F5FA),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.black,
                          size: 20,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                const Text(
                  "Goal Name",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A4A68),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _goalNameController,
                  onChanged: (value) {
                    ref.read(goalFormProvider.notifier).setGoalName(value);
                  },
                  decoration: inputDecoration.copyWith(
                    hintText: 'e.g. Savings, New Laptop',
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  "Select Icon",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A4A68),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                const IconPickerGrid(),
                const SizedBox(height: 20),

                const Text(
                  "Target Amount",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A4A68),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _targetMoneyController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: inputDecoration.copyWith(
                    hintText: '0.00',
                    prefixIcon: const Icon(
                      Icons.attach_money,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  "Deadline Date",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A4A68),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _deadlineDateController,
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  decoration: inputDecoration.copyWith(
                    hintText: 'Select date',
                    suffixIcon: const Icon(
                      Icons.calendar_today_outlined,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: _confirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B38D0),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Save Goal',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

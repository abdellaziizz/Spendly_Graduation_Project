import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/goal_form_provider.dart';

class IconPickerGrid extends ConsumerWidget {
  const IconPickerGrid({super.key});

  static const icons = [
    Icons.savings_outlined,
    Icons.home_outlined,
    Icons.directions_car_outlined,
    Icons.flight_outlined,
    Icons.card_giftcard_outlined,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIcon = ref.watch(goalFormProvider).selectedIcon;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: icons.map((icon) {
        final isSelected = selectedIcon == icon;
        
        return GestureDetector(
          onTap: () {
            ref.read(goalFormProvider.notifier).setIcon(icon);
          },
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF3B38D0) : const Color(0xFFF5F5FA),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              size: 28,
              color: isSelected ? Colors.white : const Color(0xFF4A4A68),
            ),
          ),
        );
      }).toList(),
    );
  }
}

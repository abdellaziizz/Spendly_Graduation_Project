import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/goal_form_provider.dart';

/// Icon picker row for the Add Goal sheet.
/// Stores the selected key string in [GoalFormState.selectedIcon].
class IconPickerGrid extends ConsumerWidget {
  const IconPickerGrid({super.key});

  static const _icons = <MapEntry<String, IconData>>[
    MapEntry('savings', Icons.savings_outlined),
    MapEntry('laptop', Icons.laptop_mac_outlined),
    MapEntry('beach', Icons.beach_access_outlined),
    MapEntry('home', Icons.home_outlined),
    MapEntry('car', Icons.directions_car_outlined),
    MapEntry('flight', Icons.flight_outlined),
    MapEntry('gift', Icons.card_giftcard_outlined),
    MapEntry('heart', Icons.favorite_outline),
    MapEntry('phone', Icons.smartphone_outlined),
    MapEntry('school', Icons.school_outlined),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedKey = ref.watch(goalFormProvider).selectedIcon;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _icons.map((entry) {
        final isSelected = selectedKey == entry.key;
        return GestureDetector(
          onTap: () => ref.read(goalFormProvider.notifier).setIcon(entry.key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF3B38D0)
                  : const Color(0xFFF5F5FA),
              borderRadius: BorderRadius.circular(16),
              border: isSelected
                  ? null
                  : Border.all(color: Colors.grey.shade200),
            ),
            child: Icon(
              entry.value,
              size: 26,
              color:
                  isSelected ? Colors.white : const Color(0xFF4A4A68),
            ),
          ),
        );
      }).toList(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/goal_form_provider.dart';

class IconPickerGrid extends ConsumerWidget {
  const IconPickerGrid({super.key});

  static const icons = [
    Icons.child_care,
    Icons.diamond,
    Icons.flight,
    Icons.sports_esports,
    Icons.account_balance,
    Icons.home,
    Icons.beach_access,
    Icons.checkroom,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIcon = ref.watch(goalFormProvider).selectedIcon;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: icons.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final icon = icons[index];
        final isSelected = selectedIcon == icon;

        return GestureDetector(
          onTap: () {
            ref.read(goalFormProvider.notifier).setIcon(icon);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(blurRadius: 8, color: Colors.black.withOpacity(0.06)),
              ],
            ),
            child: Icon(
              icon,
              size: 30,
              color: isSelected ? Colors.blue : Colors.grey,
            ),
          ),
        );
      },
    );
  }
}

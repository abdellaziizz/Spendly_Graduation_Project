import 'package:flutter/material.dart';

class WalletHeader extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabChanged;

  const WalletHeader({
    Key? key,
    required this.selectedIndex,
    required this.onTabChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          _buildSegment(context, 'Track', 0),
          _buildSegment(context, 'Goal', 1),
        ],
      ),
    );
  }

  Widget _buildSegment(BuildContext context, String title, int index) {
    final isSelected = selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTabChanged(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).colorScheme.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4.0,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ),
      ),
    );
  }
}

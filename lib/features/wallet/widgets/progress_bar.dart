import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0

  const ProgressBar({super.key, required this.progress});

  Color _getProgressColor() {
    if (progress < 0.5) return Colors.green;
    if (progress <= 0.8) return Colors.amber;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: 8.0,
        backgroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
        valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor()),
      ),
    );
  }
}

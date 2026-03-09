import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0

  const ProgressBar({Key? key, required this.progress}) : super(key: key);

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
        backgroundColor: Colors.grey[300],
        valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor()),
      ),
    );
  }
}

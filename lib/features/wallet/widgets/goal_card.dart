import 'package:flutter/material.dart';
import 'package:spendly/features/wallet/models/goal_model.dart';

/// A premium goal card matching the Figma mockup.
class GoalCard extends StatelessWidget {
  final GoalModel goal;

  const GoalCard({super.key, required this.goal});

  /// Returns a unique accent color per goal icon key.
  static Color _accentColor(String iconKey) {
    switch (iconKey) {
      case 'laptop':
        return const Color(0xFF3B38D0); // indigo
      case 'beach':
      case 'flight':
        return const Color(0xFF00C9A7); // teal
      case 'heart':
        return const Color(0xFFFF6B8A); // pink
      case 'home':
        return const Color(0xFF6C63FF); // violet
      case 'car':
        return const Color(0xFFFF9F43); // orange
      case 'gift':
        return const Color(0xFFFECA57); // yellow
      case 'school':
        return const Color(0xFF48DBFB); // cyan
      case 'phone':
        return const Color(0xFF1DD1A1); // emerald
      default:
        return const Color(0xFF3B38D0); // indigo default
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor(goal.icon);
    final progress = goal.progress;
    final pct = (progress * 100).toStringAsFixed(0);
    final left = goal.amountLeft;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top row: icon + badge ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon container
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(goal.iconData, color: accent, size: 24),
                ),
                const Spacer(),
                // "X% Saved" badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$pct% Saved',
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Title ──
            Text(
              goal.title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 4),

            // ── Amount display ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '\$${goal.currentAmount.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1A1A2E),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '/ \$${goal.targetAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFAAAAAA),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Progress bar ──
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 7,
                backgroundColor: const Color(0xFFF0F0F5),
                valueColor: AlwaysStoppedAnimation<Color>(accent),
              ),
            ),
            const SizedBox(height: 10),

            // ── Target / Left row ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Target: \$${goal.targetAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFAAAAAA),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '\$${left.toStringAsFixed(0)} left',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFAAAAAA),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

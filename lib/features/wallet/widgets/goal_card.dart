import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/features/wallet/models/goal_model.dart';
import 'package:spendly/theme/app_radius.dart';
import 'package:spendly/theme/theme_extensions.dart';
import 'package:spendly/features/authentication/providers/currency_provider.dart';
import 'package:spendly/features/wallet/widgets/add_funds_sheet.dart';

/// A premium goal card — accent colours are per-goal and intentional by design.
class GoalCard extends ConsumerWidget {
  final GoalModel goal;
  const GoalCard({super.key, required this.goal});

  static Color _accentColor(String iconKey) {
    switch (iconKey) {
      case 'laptop':   return const Color(0xFF3B38D0);
      case 'beach':
      case 'flight':   return const Color(0xFF00C9A7); // teal
      case 'heart':    return const Color(0xFFFF6B8A);
      case 'home':     return const Color(0xFF6C63FF);
      case 'car':      return const Color(0xFFFF9F43);
      case 'gift':     return const Color(0xFFFECA57);
      case 'school':   return const Color(0xFF48DBFB);
      case 'phone':    return const Color(0xFF1DD1A1);
      default:         return const Color(0xFF3B38D0);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curSymbol = ref.watch(currencySymbolProvider);
    final accent   = _accentColor(goal.icon);
    final progress = goal.progress;
    final pct      = (progress * 100).toStringAsFixed(0);
    final left     = goal.amountLeft;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: AppRadius.xlBorderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
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
            // ── Top row: icon + badge ─────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: AppRadius.lgBorderRadius,
                  ),
                  child: Icon(goal.iconData, color: accent, size: 24),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: AppRadius.fullBorderRadius,
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
                const SizedBox(width: 12),
                InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => AddFundsSheet(goal: goal),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Title ─────────────────────────────────────────────────────────
            Text(goal.title, style: context.textTheme.titleMedium),
            const SizedBox(height: 4),

            // ── Amount display ────────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '$curSymbol${goal.currentAmount.toStringAsFixed(0)}',
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '/ $curSymbol${goal.targetAmount.toStringAsFixed(0)}',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.hintColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Progress bar ──────────────────────────────────────────────────
            ClipRRect(
              borderRadius: AppRadius.smBorderRadius,
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 7,
                backgroundColor: context.colors.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(accent),
              ),
            ),
            const SizedBox(height: 10),

            // ── Target / Left row ─────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Target: $curSymbol${goal.targetAmount.toStringAsFixed(0)}',
                  style: context.textTheme.labelSmall,
                ),
                Text(
                  '$curSymbol${left.toStringAsFixed(0)} left',
                  style: context.textTheme.labelSmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

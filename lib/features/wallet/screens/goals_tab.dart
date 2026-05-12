import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tspendly/features/wallet/providers/goal_provider.dart';
import 'package:tspendly/features/wallet/widgets/goal_card.dart';
import 'package:tspendly/features/wallet/widgets/setting_goal_pop.dart';

class GoalsTab extends ConsumerWidget {
  const GoalsTab({super.key});

  void _openAddGoalSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddGoal(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: goalsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF3B38D0)),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                const SizedBox(height: 12),
                Text(
                  'Something went wrong',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  err.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => ref.invalidate(goalProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (goals) => CustomScrollView(
          slivers: [
            // ── Goal cards ──
            if (goals.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyGoalsState(onAdd: () => _openAddGoalSheet(context)),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => GoalCard(goal: goals[index]),
                    childCount: goals.length,
                  ),
                ),
              ),

            // ── "Dreaming bigger?" promo banner ──
            if (goals.isNotEmpty)
              SliverToBoxAdapter(
                child: _DreamingBiggerBanner(),
              ),

            // ── Spacing before bottom button ──
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),

      // ── "Add New Goal" bottom button ──
      bottomNavigationBar: goalsAsync.hasValue
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: SizedBox(
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: () => _openAddGoalSheet(context),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      'Add New Goal',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B38D0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

// ─────────────────────────────────────────────
// "Dreaming bigger?" promotional banner
// ─────────────────────────────────────────────
class _DreamingBiggerBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      height: 130,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF3B38D0), Color(0xFF6C63FF), Color(0xFF9B59B6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B38D0).withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles for mesh gradient effect
          Positioned(
            right: -20,
            bottom: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            right: 40,
            top: -30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Dreaming bigger?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Unlock automated savings rules\nto reach your goals 30% faster.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.80),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Empty state widget
// ─────────────────────────────────────────────
class _EmptyGoalsState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyGoalsState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 32),
        // Banner still appears in empty state
        _DreamingBiggerBanner(),
        const SizedBox(height: 40),
        const Icon(Icons.flag_outlined, size: 64, color: Color(0xFFCCCCDD)),
        const SizedBox(height: 16),
        const Text(
          'No goals yet',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Set your first savings goal\nand start tracking your progress.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/services/connectivity/connectivity_provider.dart';
import 'package:spendly/theme/colors.dart';
import 'package:spendly/theme/app_radius.dart';
import 'package:spendly/theme/theme_extensions.dart';

/// Full-screen offline placeholder used on screens that are entirely
/// network-dependent (Wallet, Report, Profile, Chatbot, Scan).
///
/// Usage:
/// ```dart
/// if (!isOnline) return const OfflineStateWidget();
/// ```
class OfflineStateWidget extends ConsumerStatefulWidget {
  /// Shown above the "You're Offline" title.
  final String? subtitle;

  /// If provided, shown in place of the generic description.
  final String? message;

  const OfflineStateWidget({super.key, this.subtitle, this.message});

  @override
  ConsumerState<OfflineStateWidget> createState() =>
      _OfflineStateWidgetState();
}

class _OfflineStateWidgetState extends ConsumerState<OfflineStateWidget>
    with SingleTickerProviderStateMixin {
  bool _checking = false;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _tryAgain() async {
    setState(() => _checking = true);
    await ref.read(connectivityServiceProvider).checkNow();
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) setState(() => _checking = false);
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = ref.watch(isOnlineProvider).value ?? true;

    // Auto-pop overlay when reconnected (useful when embedded inside a page)
    if (isOnline) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    }

    return Scaffold(
      backgroundColor: context.colors.surface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Animated cloud-off icon ──────────────────────────
                AnimatedBuilder(
                  animation: _pulseAnim,
                  builder: (_, __) => Opacity(
                    opacity: _pulseAnim.value,
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: AppColors.expense.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.cloud_off_rounded,
                        size: 48,
                        color: AppColors.expense,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // ── Title ─────────────────────────────────────────────
                Text(
                  "You're Offline",
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // ── Description ───────────────────────────────────────
                Text(
                  widget.message ??
                      'No internet connection detected.\n'
                          'Check your Wi-Fi or mobile data and try again.',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.subtitleColor,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // ── Try Again button ───────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _checking ? null : _tryAgain,
                    icon: _checking
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.refresh_rounded),
                    label: Text(_checking ? 'Checking...' : 'Try Again'),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Waiting indicator ─────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _pulseAnim,
                      builder: (_, __) => Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: context.subtitleColor
                              .withValues(alpha: _pulseAnim.value),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Waiting for reconnect...',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.subtitleColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Lighter inline version — shown inside a scrollable page
/// when only a section is network-dependent.
class OfflineInlineWidget extends ConsumerWidget {
  final VoidCallback? onRetry;
  final String message;

  const OfflineInlineWidget({
    super.key,
    this.onRetry,
    this.message = 'No internet connection.\nData shown may be outdated.',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.expense.withValues(alpha: 0.06),
        borderRadius: AppRadius.lgBorderRadius,
        border: Border.all(color: AppColors.expense.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded,
              color: AppColors.expense, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.subtitleColor,
                height: 1.5,
              ),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spendly/features/Profile/Provider/user_provider.dart';
import 'package:spendly/features/Profile/Widget/container_widget.dart';
import 'package:spendly/features/Profile/Widget/headsection_widget.dart';
import 'package:spendly/features/authentication/Service/auth_service.dart';
import 'package:spendly/features/authentication/Model/currency_data.dart';
import 'package:spendly/features/main/providers/user_provider.dart';
import 'package:spendly/features/authentication/providers/currency_provider.dart';
import 'package:spendly/theme/app_radius.dart';
import 'package:spendly/theme/theme_extensions.dart';
import 'package:spendly/widgets/toggle.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final code = ref.watch(currencyProvider).valueOrNull?.code ?? 'USD';
    final c = allCurrencies.firstWhere(
      (c) => c.code == code, 
      orElse: () => allCurrencies.firstWhere((c) => c.code == 'USD')
    );
    final currencySubtitle = '${c.code} ${c.flag}';
    final userasync = ref.watch(profileNameProvider);

    return userasync.when(
      data: (user) {
        final email    = user.email;
        final fullname = user.fullName;

        return Scaffold(
          appBar: AppBar(title: const Text('Profile')),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const Headsection(),
                  ContainerWidget(
                    icon: Icons.email,
                    title: 'Email',
                    subtitle: email,
                  ),
                  GestureDetector(
                    onTap: () => context.go('/currency', extra: true),
                    child: ContainerWidget(
                      icon: Icons.wallet_outlined,
                      title: 'Currency type',
                      subtitle: currencySubtitle,
                    ),
                  ),
                  ContainerWidget(
                    icon: Icons.person_outline,
                    title: 'Name',
                    subtitle: fullname,
                  ),
                  GestureDetector(
                    onTap: () => context.push('/legal'),
                    child: ContainerWidget(
                      icon: Icons.info_outline_rounded,
                      title: 'Legal Information',
                    ),
                  ),

                  // ── Dark mode toggle ───────────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: context.surface,
                      borderRadius: AppRadius.lgBorderRadius,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    height: 55,
                    child: Row(
                      children: [
                        Icon(
                          Icons.brightness_6_outlined,
                          color: context.onSurface,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Mode',
                          style: context.textTheme.titleSmall,
                        ),
                        const Spacer(),
                        const Toggle(),
                      ],
                    ),
                  ),

                  // ── Logout ─────────────────────────────────────────────
                  GestureDetector(
                    onTap: () async {
                      try {
                        await AuthService().signOut();
                        if (context.mounted) context.go('/login');
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Logout failed: $e'),
                            ),
                          );
                        }
                      }
                    },
                    child: ContainerWidget(
                      icon: Icons.logout,
                      title: 'Logout',
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      error: (e, _) => Center(
        child: Text(
          'Error loading profile: $e',
          style: TextStyle(color: context.errorColor),
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:spendly/features/Profile/Provider/user_provider.dart';
import 'package:spendly/services/connectivity/connectivity_provider.dart';

class Headsection extends ConsumerWidget {
  const Headsection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.isOnline;

    if (!isOnline) {
      return _buildHeaderContent(
        context: context,
        fullname: 'User',
        email: 'Guest',
        gender: 'male',
      );
    }

    final userAsync = ref.watch(profileNameProvider);

    return userAsync.when(
      data: (user) => _buildHeaderContent(
        context: context,
        fullname: user.fullName,
        email: user.email,
        gender: user.gender,
      ),
      loading: () => Skeletonizer(
        enabled: true,
        child: Container(
          height: 88,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      error: (_, _) => Center(child: const Text('Opps ! \nFailed Loading ')),
    );
  }

  Widget _buildHeaderContent({
    required BuildContext context,
    required String fullname,
    required String email,
    required String gender,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      margin: const EdgeInsets.symmetric(vertical: 8),
      height: 88,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: gender == "male"
                ? SvgPicture.asset(
                    'assets/icons/User_avatar.svg',
                    width: 40,
                    height: 40,
                    fit: BoxFit.fill,
                  )
                : SvgPicture.asset(
                    'assets/icons/female_avatar.svg',
                    width: 40,
                    height: 40,
                    fit: BoxFit.fill,
                  ),
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fullname,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                ),
              ),
              Text(
                email,
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

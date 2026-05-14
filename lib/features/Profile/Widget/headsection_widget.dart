import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:spendly/features/Profile/Provider/user_provider.dart';

class Headsection extends ConsumerWidget {
  const Headsection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(profileNameProvider);

    return userAsync.when(
      data: (user) {
        final email = user.email;
        final fullname = user.fullName;
        final gender = user.gender;
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
      },
      loading: () => Center(child: const CircularProgressIndicator()),
      error: (_, _) => Center(child: const Text('Opps ! \nFailed Loading ')),
    );
  }
}

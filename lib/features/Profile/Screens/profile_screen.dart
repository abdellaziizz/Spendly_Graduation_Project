import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tspendly/features/Profile/Widget/container_widget.dart';
import 'package:tspendly/features/Profile/Widget/headsection_widget.dart';
import 'package:tspendly/features/authentication/Service/auth_service.dart';
import 'package:tspendly/widgets/toggle.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('profile')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const Headsection(),
              ContainerWidget(
                icon: Icons.email,
                title: 'Email',
                subtitle: 'mrRobo999@gmail.com',
              ),
              GestureDetector(
                onTap: () {
                  context.go('/currency', extra: true);
                },
                child: ContainerWidget(
                  icon: Icons.wallet_outlined,
                  title: 'Currency type',
                ),
              ),
              ContainerWidget(
                icon: Icons.person_outline,
                title: 'Name',
                subtitle: 'Ahmed Mohamed',
              ),
              GestureDetector(
                onTap: () {
                  context.go('/legal');
                },
                child: ContainerWidget(
                  icon: Icons.info_outline_rounded,
                  title: 'Legal Information',
                ),
              ),
              // Container(
              //   padding: const EdgeInsets.symmetric(horizontal: 12),
              //   margin: const EdgeInsets.symmetric(vertical: 8),
              //   decoration: BoxDecoration(
              //     boxShadow: [
              //       BoxShadow(
              //         color: Colors.black.withOpacity(0.1),
              //         blurRadius: 6,
              //         offset: const Offset(0, 3),
              //       ),
              //     ],
              //     borderRadius: BorderRadius.circular(12),
              //     color: Theme.of(context).colorScheme.surface,
              //   ),
              //   height: 55,
              //   child: Row(
              //     children: [
              //       Icon(
              //         Icons.info_outline_rounded,
              //         color: Theme.of(context).colorScheme.onSurface,
              //       ),
              //       const SizedBox(width: 12),
              //       Text(
              //         'Legal Information',
              //         style: TextStyle(
              //           fontWeight: FontWeight.bold,
              //           color: Theme.of(context).colorScheme.onSurface,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).colorScheme.surface,
                ),
                height: 55,
                child: Row(
                  children: [
                    Text(
                      'Mode',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    const Toggle(),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () async {
                  try {
                    await AuthService().signOut();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Logout failed: $e')),
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
  }
}

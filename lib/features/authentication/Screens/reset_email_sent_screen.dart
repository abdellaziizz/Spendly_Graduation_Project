import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:spendly/features/authentication/Service/auth_service.dart';
import 'package:spendly/theme/colors.dart';
import 'package:spendly/theme/theme_extensions.dart';

class Fpassword extends StatelessWidget {
  final String email;
  Fpassword({super.key, required this.email});

  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/FPassword.jpg', width: 350, height: 250),
            const SizedBox(height: 30),
            Text(
              'Password Reset Email Sent',
              style: context.textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text(
              email,
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colors.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Your account security is our priority! We've sent you a secure link to safely change your password.",
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.subtitleColor,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 22),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              child: const Text('Done'),
            ),
            const SizedBox(height: 15),
            TextButton(
              onPressed: () async {
                try {
                  await _authService.forgotPassword(email: email);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Reset email resent to $email'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to resend: ${e.toString()}'),
                        backgroundColor: context.errorColor,
                      ),
                    );
                  }
                }
              },
              child: const Text('Resend Email'),
            ),
          ],
        ),
      ),
    );
  }
}

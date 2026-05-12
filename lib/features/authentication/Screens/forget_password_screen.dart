import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tspendly/features/authentication/Service/auth_service.dart';

// this is not forget password . it's just confirmation that email is sent
class Fpassword extends StatelessWidget {
  final String email;
  Fpassword({super.key, required this.email});

  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/FPassword.jpg', width: 350, height: 250),
            SizedBox(height: 30),

            Text(
              'Password Reset Email Sent',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 26,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 12),
            Text(
              email,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 20),
            ),
            SizedBox(height: 12),
            Text(
              "Your Account Security is our priority! We've sent you a security link to safety change your password and keep your account protected",
              style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 22),
            ElevatedButton(
              onPressed: () {
                context.go('/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff274C77),
                fixedSize: const Size(335, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(20),
                ),
              ),
              child: Text('Done', style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 15),

            // ───────── RESEND EMAIL BUTTON ─────────
            TextButton(
              onPressed: () async {
                try {
                  await _authService.forgotPassword(email: email);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Reset email resent to $email'),
                        backgroundColor: Colors.green.shade600,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to resend: ${e.toString()}'),
                        backgroundColor: Colors.red.shade600,
                      ),
                    );
                  }
                }
              },
              child: Text(
                'Resend Email',
                style: TextStyle(color: Color(0xff274C77)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

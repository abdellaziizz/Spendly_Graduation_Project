import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:tspendly/features/authentication/Widget/textform.dart';
import 'package:tspendly/features/authentication/Service/auth_service.dart';

class LoginScreen extends ConsumerWidget {
  LoginScreen({super.key});

  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  final obscureTextProvider = StateProvider<bool>((ref) => true);

  final _authService = AuthService();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isObscured = ref.watch(obscureTextProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 24),
                Image.asset(
                  'assets/logo/logo.png',
                  height: 116,
                  width: 115,
                  fit: BoxFit.contain,
                ),
                Text(
                  'Spendly',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 80),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Textform(
                    controller: emailController,
                    ispassword: false,
                    label: 'Email',
                    hint: 'Enter Your Email',
                    obscureTextProvider: obscureTextProvider,
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Textform(
                    controller: passwordController,
                    ispassword: true,
                    label: 'Password',
                    hint: '*******',
                    obscureTextProvider: obscureTextProvider,
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton(
                    child: Text(
                      'Forgot Your Password ?',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    onPressed: () {
                      context.push('/forgot-password');
                    },
                  ),
                ),
                const SizedBox(height: 18),

                // ───────── LOGIN BUTTON ─────────
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        final email = emailController.text.trim();
                        final password = passwordController.text.trim();

                        // Show loading indicator
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) =>
                              const Center(child: CircularProgressIndicator()),
                        );

                        await _authService.signIn(
                          email: email,
                          password: password,
                        );

                        // Dismiss loading
                        if (context.mounted) Navigator.of(context).pop();

                        // Navigate to home
                        if (context.mounted) context.go('/home');
                      } catch (e) {
                        // Dismiss loading if still showing
                        if (context.mounted) Navigator.of(context).pop();

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Login failed: ${e.toString()}'),
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.error,
                            ),
                          );
                        }
                      }
                    }
                  },
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  'OR CONTINUE WITH GOOGLE',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 12),

                // ───────── GOOGLE SIGN-IN BUTTON ─────────
                OutlinedButton(
                  onPressed: () async {
                    try {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) =>
                            const Center(child: CircularProgressIndicator()),
                      );

                      await _authService.signInWithGoogle();

                      if (context.mounted) Navigator.of(context).pop();
                      if (context.mounted) context.go('/home');
                    } catch (e) {
                      if (context.mounted) Navigator.of(context).pop();

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Google sign-in failed: ${e.toString()}',
                            ),
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.error,
                          ),
                        );
                      }
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    fixedSize: const Size(335, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: SvgPicture.asset(
                          'assets/icons/google-color-svgrepo-com.svg',
                          height: 26.54,
                          width: 26.54,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Text(
                        'Log in with your Google account',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account ?",
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        context.push('/register');
                      },
                      child: const Text("Sign Up"),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:spendly/features/authentication/Widget/textform.dart';
import 'package:spendly/features/authentication/Service/auth_service.dart';
import 'package:spendly/theme/theme_extensions.dart';

class LoginScreen extends ConsumerWidget {
  LoginScreen({super.key});

  final emailController    = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey           = GlobalKey<FormState>();
  final obscureTextProvider = StateProvider<bool>((ref) => true);
  final _authService        = AuthService();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isObscured = ref.watch(obscureTextProvider);

    return Scaffold(
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
                  'spendly',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: context.colors.primary,
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
                    onPressed: () => context.push('/forgot-password'),
                    child: const Text('Forgot Your Password ?'),
                  ),
                ),
                const SizedBox(height: 18),

                // ── Login button ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                          await _authService.signIn(
                            email: emailController.text.trim(),
                            password: passwordController.text.trim(),
                          );
                          if (context.mounted) Navigator.of(context).pop();
                          if (context.mounted) context.go('/home');
                        } catch (e) {
                          if (context.mounted) Navigator.of(context).pop();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Login failed: ${e.toString()}'),
                                backgroundColor: context.errorColor,
                              ),
                            );
                          }
                        }
                      }
                    },
                    child: const Text('Login'),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  'OR CONTINUE WITH GOOGLE',
                  style: TextStyle(color: context.subtitleColor),
                ),
                const SizedBox(height: 12),

                // ── Google sign-in button ─────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: OutlinedButton(
                    onPressed: () async {
                      try {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => const Center(
                            child: CircularProgressIndicator(),
                          ),
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
                              backgroundColor: context.errorColor,
                            ),
                          );
                        }
                      }
                    },
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
                          style: TextStyle(color: context.onSurface),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account ?",
                      style: TextStyle(color: context.subtitleColor),
                    ),
                    TextButton(
                      onPressed: () => context.push('/register'),
                      child: const Text('Sign Up'),
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

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:spendly/features/authentication/Service/auth_service.dart';
import 'package:spendly/theme/colors.dart';
import 'package:spendly/theme/theme_extensions.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey             = GlobalKey<FormState>();
  final _passwordController  = TextEditingController();
  final _confirmController   = TextEditingController();
  final _authService         = AuthService();
  bool _isLoading            = false;
  bool _obscurePassword      = true;
  bool _obscureConfirm       = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reset Password',
                  style: context.textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your new password below.',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.subtitleColor,
                  ),
                ),
                const SizedBox(height: 32),

                // New password
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 6) return 'At least 6 characters';
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    suffixIcon: IconButton(
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Confirm password
                TextFormField(
                  controller: _confirmController,
                  obscureText: _obscureConfirm,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Confirm your password';
                    if (v != _passwordController.text)
                      return 'Passwords do not match';
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    suffixIcon: IconButton(
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() => _isLoading = true);
                            try {
                              await _authService.resetPassword(
                                newPassword: _passwordController.text.trim(),
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Password reset successfully!'),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                                context.go('/login');
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('Reset failed: ${e.toString()}'),
                                    backgroundColor: context.errorColor,
                                  ),
                                );
                              }
                            } finally {
                              if (mounted) setState(() => _isLoading = false);
                            }
                          }
                        },
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text('Reset Password'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:tspendly/features/authentication/Screens/Login_Screen.dart';
import 'package:tspendly/features/authentication/Widget/register_textform.dart';
import 'package:tspendly/features/authentication/Service/auth_service.dart';

class RegisterationScreen extends StatefulWidget {
  RegisterationScreen({super.key});

  @override
  State<RegisterationScreen> createState() => _RegisterationScreenState();
}

class _RegisterationScreenState extends State<RegisterationScreen> {
  final firstNameCont = TextEditingController();
  final lastNameCont = TextEditingController();
  final EmailCont = TextEditingController();
  final PasswordCont = TextEditingController();
  final ConfirmPasswordCont = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final _authService = AuthService();

  // Gender: 1 = Male, 2 = Female
  int _selectedGender = 2;
  bool _isLoading = false;

  @override
  void dispose() {
    firstNameCont.dispose();
    lastNameCont.dispose();
    EmailCont.dispose();
    PasswordCont.dispose();
    ConfirmPasswordCont.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Image.asset(
                      'assets/logo/logo.png',
                      height: 126,
                      width: 135,
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
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: firstNameCont,
                            label: 'First Name',
                            validator: (value) => value == null || value.isEmpty
                                ? 'Required'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomTextField(
                            controller: lastNameCont,
                            label: 'Last Name',
                            validator: (value) => value == null || value.isEmpty
                                ? 'Required'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: EmailCont,
                      label: 'Email',
                      hint: "You@gmail.com",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email is required';
                        }
                        if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: PasswordCont,
                      label: 'Password',
                      hint: '******',
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        if (value.length < 6) return 'At least 6 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: ConfirmPasswordCont,
                      label: 'Confirm Your Password',
                      hint: '******',
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Confirm password';
                        }
                        if (value != PasswordCont.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CustomSlidingSegmentedControl<int>(
                          initialValue: _selectedGender,
                          fixedWidth: 103,
                          children: {
                            1: Text('Male', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                            2: Text('Female', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))
                          },
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(32),
                          ),
                          thumbDecoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(36),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(.1),
                                blurRadius: 4.0,
                                offset: const Offset(0.0, 2.0),
                              ),
                            ],
                          ),
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInToLinear,
                          onValueChanged: (v) {
                            setState(() {
                              _selectedGender = v;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // ───────── REGISTER BUTTON ─────────
                    ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() => _isLoading = true);

                                try {
                                  final gender =
                                      _selectedGender == 1 ? 'Male' : 'Female';

                                  await _authService.signUp(
                                    email: EmailCont.text.trim(),
                                    password: PasswordCont.text.trim(),
                                    firstName: firstNameCont.text.trim(),
                                    lastName: lastNameCont.text.trim(),
                                    gender: gender,
                                  );

                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                          'Registration successful! Please check your email to verify your account.',
                                        ),
                                        backgroundColor: Colors.green.shade600,
                                      ),
                                    );
                                    context.go('/home');
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Registration failed: ${e.toString()}',
                                        ),
                                        backgroundColor: Theme.of(context).colorScheme.error,
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
                          : const Text('Register'),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      'OR CONTINUE WITH GOOGLE',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                    ),
                    const SizedBox(height: 12),

                    // ───────── GOOGLE SIGN-IN BUTTON ─────────
                    OutlinedButton(
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
                                backgroundColor: Theme.of(context).colorScheme.error,
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
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already Have An Account ?",
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                        ),
                        TextButton(
                          onPressed: () {
                            context.push('/login');
                          },
                          child: const Text("Login"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

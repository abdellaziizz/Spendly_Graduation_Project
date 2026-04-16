import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tspendly/features/authentication/Registeration_Screen.dart';
import 'package:tspendly/features/authentication/Widget/textform.dart';
import 'package:tspendly/features/authentication/enterEmail_Screen.dart';
import 'package:tspendly/features/main/screens/home_screen.dart';

class LoginScreen extends ConsumerWidget {
  LoginScreen({super.key});

  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  final obscureTextProvider = StateProvider<bool>((ref) => true);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isObscured = ref.watch(obscureTextProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
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
              const SizedBox(height: 16),
              const Text(
                'Spendly',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff274C77),
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
              SizedBox(height: 30),
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
              SizedBox(height: 8),
              Align(
                alignment: AlignmentGeometry.centerEnd,
                child: TextButton(
                  child: Text(
                    'Forgot Your Password ?',
                    style: TextStyle(color: Color(0xff274C77)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Enteremail(),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 18),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      final email = emailController.text.trim();
                      final password = passwordController.text.trim();

                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => const MainScreen(),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Login failed: ${e.toString()}'),
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff274C77),
                  fixedSize: const Size(335, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(20),
                  ),
                ),
                child: Text('Login', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 20),

              Text(
                'OR CONTINUE WITH GOOGLE',
                style: TextStyle(color: Colors.grey.shade500),
              ),

              //google widget
              ElevatedButton(
                onPressed: () {
                  //Google Feature
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  fixedSize: Size(305, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(20),
                  ),
                ),
                child: Row(
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
                      style: TextStyle(color: Colors.black),
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
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegisterationScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "Sign Up",
                      style: TextStyle(color: Color(0xff79BDDA)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

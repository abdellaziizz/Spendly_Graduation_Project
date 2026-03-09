import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: null,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
            TextFormField(
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xff0000FF)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xff0000FF)),
                ),
                label: Text(
                  'Email',
                  style: TextStyle(color: Color(0xff0000FF)),
                ),
                hint: Text(
                  'You@gmail.com',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ),
            ),
            SizedBox(height: 34),
            TextFormField(
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xff0000FF)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xff0000FF)),
                ),
                label: Text(
                  'Password',
                  style: TextStyle(color: Color(0xff0000FF)),
                ),
                hint: Text(
                  '*************',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Forgot Your Password ?',
                  style: TextStyle(color: Color(0xff274C77)),
                ),
              ],
            ),
            SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                context.go('/home');
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
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                fixedSize: const Size(335, 55),
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
                ],
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'OR CONTINUE WITH GOOGLE',
              style: TextStyle(color: Colors.grey.shade500),
            ),

            const SizedBox(height: 32),
            RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.grey.shade500),
                children: [
                  TextSpan(text: "Don't have an account ?"),
                  TextSpan(
                    text: "Register",
                    style: TextStyle(color: Color(0xff79BDDA)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

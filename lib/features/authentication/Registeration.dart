import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              children: [
                SizedBox(height: 16),
                Image.asset(
                  'assets/logo/logo.png',
                  height: 126,
                  width: 135,
                  fit: BoxFit.contain,
                ),

                const Text(
                  'Spendly',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff00365A),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: firstNameCont,
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
                            'First Name',
                            style: TextStyle(color: Color(0xff0000FF)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: lastNameCont,
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
                            'Last Name',
                            style: TextStyle(color: Color(0xff0000FF)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: EmailCont,
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
                const SizedBox(height: 12),
                TextFormField(
                  controller: PasswordCont,
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
                      '**********',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: ConfirmPasswordCont,
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
                      'Confirm your password',
                      style: TextStyle(color: Color(0xff0000FF)),
                    ),
                    hint: Text(
                      '**********',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CustomSlidingSegmentedControl<int>(
                      initialValue: 2,
                      fixedWidth: 103,
                      children: {1: Text('Male'), 2: Text('Female')},
                      decoration: BoxDecoration(
                        color: Color(0xffDAE0E7),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      thumbDecoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(36),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.3),
                            blurRadius: 4.0,
                            spreadRadius: 1.0,
                            offset: Offset(0.0, 2.0),
                          ),
                        ],
                      ),
                      duration: Duration(milliseconds: 200),
                      curve: Curves.easeInToLinear,
                      onValueChanged: (v) {
                        print(v);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    context.go('/currency');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff274C77),
                    fixedSize: const Size(335, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(20),
                    ),
                  ),
                  child: Text(
                    'Register',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  'OR CONTINUE WITH GOOGLE',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
                const SizedBox(height: 12),
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
                      Text(
                        'Log in with your Google account',
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                const SizedBox(height: 32),
                RichText(
                  text: TextSpan(
                    style: TextStyle(color: Colors.grey.shade500),
                    children: [
                      TextSpan(text: "Already have an account ?"),
                      TextSpan(
                        text: "Sign Up",
                        style: TextStyle(color: Color(0xff79BDDA)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

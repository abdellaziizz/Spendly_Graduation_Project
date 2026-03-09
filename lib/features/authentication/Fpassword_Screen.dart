import 'package:flutter/material.dart';

class Fpassword extends StatelessWidget {
  const Fpassword({super.key});

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
              'Youremail@gmail.com',
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
              onPressed: () {},
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

            TextButton(
              onPressed: () {},
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

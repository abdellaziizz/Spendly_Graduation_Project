import 'package:flutter/material.dart';
import 'package:tspendly/features/Profile/container_widget.dart';
import 'package:tspendly/features/Profile/headsection_widget.dart';
import 'package:tspendly/widgets/toggle.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffEEF0F2),
      appBar: AppBar(
        title: Text(
          'profile',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Headsection(),
            ContainerWidget(
              icon: Icons.email,
              title: 'Email',
              subtitle: 'mrRobo999@gmail.com',
            ),
            GestureDetector(
              onTap: () {
                //go to currency screen
              },
              child: ContainerWidget(
                icon: Icons.wallet_outlined,
                title: 'Currency type',
              ),
            ),
            ContainerWidget(
              icon: Icons.person_outline,
              title: 'Name',
              subtitle: 'Ahmed Mohamed',
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
                borderRadius: BorderRadius.circular(12),
                color: Color(0xffFFFFFF),
              ),
              height: 55,
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded),
                  Text(
                    'Legal Information',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
                borderRadius: BorderRadius.circular(12),
                color: Color(0xffFFFFFF),
              ),
              height: 55,
              child: Row(
                children: [
                  Text(
                    'Mode',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Spacer(),
                  Toggle(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

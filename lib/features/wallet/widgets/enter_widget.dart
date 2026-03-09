import 'package:flutter/material.dart';

class EnterWidget extends StatelessWidget {
  const EnterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: const Icon(
                Icons.wallet,
                color: Color(0xff0466C8),
                size: 48,
              ),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Monthly Budget',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'Track What\'s left\nSet Spending Limit',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xff757575), fontSize: 14.0),
            ),
          ],
        ),
      ),
    );
  }
}

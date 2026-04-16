import 'package:flutter/material.dart';

class WalletLogoCard extends StatelessWidget {
  const WalletLogoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 271,
        width: 269,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              spreadRadius: 5,
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xff397BBD),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                size: 60,
                color: Color(0xff051923),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Monthly Budget",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xff2D6CDF),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Track what's left\nSet spending limit",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

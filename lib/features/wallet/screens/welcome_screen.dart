import 'package:flutter/material.dart';
import 'package:tspendly/features/wallet/screens/wallet_screen.dart';
import 'package:tspendly/features/wallet/widgets/welcome_widget.dart';

class WalletWelcomeScreen extends StatelessWidget {
  const WalletWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Image.asset('assets/logo/logo.png', width: 42, height: 42),
          const SizedBox(width: 8),
        ],
      ),
      body: const WalletLogoCard(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to Plan screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const WalletScreen()),
          );
        },
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: const BorderSide(color: Colors.grey, width: 0.5),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

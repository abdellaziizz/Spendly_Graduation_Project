import 'package:flutter/material.dart';
import '../widgets/wallet_header.dart';
import 'track_tab.dart';
import 'plan_tab.dart';
import 'goals_tab.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  int _selectedIndex = 0;

  final List<Widget> _tabs = const [TrackTab(), PlanTab(), GoalsTab()];

  @override
  Widget build(BuildContext context) {
    // We use a Scaffold since this is the body content.
    // The bottom navigation bar is handled elsewhere (as per request).
    return Scaffold(
      appBar: AppBar(

        actions: [
          Image.asset('assets/logo/logo.png', width: 42, height: 42),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          WalletHeader(
            selectedIndex: _selectedIndex,
            onTabChanged: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
          Expanded(child: _tabs[_selectedIndex]),
        ],
      ),
    );
  }
}

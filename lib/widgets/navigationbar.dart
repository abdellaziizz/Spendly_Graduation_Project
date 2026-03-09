import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:tspendly/features/Profile/profile_screen.dart';
import 'package:tspendly/features/Report/report_screen.dart';
import 'package:tspendly/features/main/screens/home_screen.dart';
import 'package:tspendly/features/wallet/screens/wallet_screen.dart';

final navigationIndexProvider = StateProvider<int>((ref) => 0);

class Navbar extends ConsumerWidget {
  const Navbar({super.key});
  static final List<Widget> _widgetOptions = <Widget>[
    MainScreen(),
    WalletScreen(),
    ProfileScreen(),
    ReportScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedindex = ref.watch(navigationIndexProvider);

    return Scaffold(
      body: _widgetOptions.elementAt(selectedindex),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withValues(alpha: 0.1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsetsGeometry.symmetric(
            horizontal: 15,
            vertical: 8,
          ),
          child: GNav(
            gap: 8,
            backgroundColor: Colors.white,
            tabBackgroundColor: Color(0xff397BBD),
            color: Colors.grey.shade500,
            activeColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            duration: Duration(milliseconds: 100),
            curve: Curves.linear,
            tabs: const [
              GButton(icon: Icons.home, text: 'Home'),
              GButton(
                icon: Icons.account_balance_wallet_outlined,
                text: 'Wallet',
              ),
              GButton(icon: Icons.pie_chart_outline, text: 'report'),
              GButton(icon: Icons.person_outline, text: 'profile'),
            ],
            selectedIndex: selectedindex,
            onTabChange: (index) {
              switch (index) {
                case 0:
                  context.go('/home');
                  break;
                case 1:
                  context.go('/wallet');
                  break;
                case 2:
                  context.go('/report');
                  break;
                case 3:
                  context.go('/profile');
                  break;
              }
            },
          ),
        ),
      ),
    );
  }
}

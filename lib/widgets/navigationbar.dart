import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

/// Scaffold wrapper that provides a persistent bottom navigation bar
/// using GoRouter's StatefulNavigationShell for tab-based navigation.
class ScaffoldWithNavbar extends StatelessWidget {
  const ScaffoldWithNavbar({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
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
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 8,
          ),
          child: GNav(
            gap: 8,
            backgroundColor: Colors.white,
            tabBackgroundColor: const Color(0xff397BBD),
            color: Colors.grey.shade500,
            activeColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            duration: const Duration(milliseconds: 100),
            curve: Curves.linear,
            tabs: const [
              GButton(icon: Icons.home, text: 'Home'),
              GButton(
                icon: Icons.account_balance_wallet_outlined,
                text: 'Wallet',
              ),
              GButton(icon: Icons.pie_chart_outline, text: 'Insight'),
              GButton(icon: Icons.person_outline, text: 'Profile'),
            ],
            selectedIndex: navigationShell.currentIndex,
            onTabChange: (index) {
              // Use goBranch to switch between navigation branches
              // while preserving the state of each branch
              navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              );
            },
          ),
        ),
      ),
    );
  }
}

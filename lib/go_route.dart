import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tspendly/widgets/navigationbar.dart';
import 'package:tspendly/features/main/screens/home_screen.dart';
import 'package:tspendly/features/wallet/screens/wallet_screen.dart';
import 'package:tspendly/features/Report/report_screen.dart';
import 'package:tspendly/features/Profile/Screens/profile_screen.dart';
import 'package:tspendly/features/chatbot/Screens/chat_screen.dart';

// Navigation keys for each branch
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _walletNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'wallet');
final _reportNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'report');
final _profileNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'profile');

final GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavbar(navigationShell: navigationShell);
      },
      branches: [
        // Home tab - index 0
        StatefulShellBranch(
          navigatorKey: _homeNavigatorKey,
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const MainScreen(),
            ),
          ],
        ),
        // Wallet tab - index 1
        StatefulShellBranch(
          navigatorKey: _walletNavigatorKey,
          routes: [
            GoRoute(
              path: '/wallet',
              builder: (context, state) => const WalletScreen(),
            ),
          ],
        ),
        // Report / Insight tab - index 2
        StatefulShellBranch(
          navigatorKey: _reportNavigatorKey,
          routes: [
            GoRoute(
              path: '/report',
              builder: (context, state) => const ReportScreen(),
            ),
          ],
        ),
        // Profile tab - index 3
        StatefulShellBranch(
          navigatorKey: _profileNavigatorKey,
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
    // Chatbot route (fullscreen, no bottom nav)
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/chatbot',
      builder: (context, state) => const ChatScreen(),
    ),
  ],
);

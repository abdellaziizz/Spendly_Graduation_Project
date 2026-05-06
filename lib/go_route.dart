import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tspendly/features/Profile/Screens/legal_information_screen.dart';
import 'package:tspendly/features/authentication/Screens/currency_screen.dart';
import 'package:tspendly/widgets/navigationbar.dart';
import 'package:tspendly/features/main/screens/home_screen.dart';
import 'package:tspendly/features/wallet/screens/wallet_screen.dart';
import 'package:tspendly/features/predictions/screens/future_insights_screen.dart';
import 'package:tspendly/features/Profile/Screens/profile_screen.dart';
import 'package:tspendly/features/chatbot/Screens/chat_screen.dart';
import 'package:tspendly/features/authentication/Screens/login_screen.dart';
import 'package:tspendly/features/authentication/Screens/Registeration_Screen.dart';
import 'package:tspendly/features/authentication/Screens/enter_email_Screen.dart';
import 'package:tspendly/features/authentication/Screens/ResetPassword_Screen.dart';

// Navigation keys for each branch
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _walletNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'wallet');
final _reportNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'report');
final _profileNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'profile');

final GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  routes: [
    // ───────── AUTH ROUTES (no bottom nav) ─────────
    GoRoute(
      //Forces the route to open above everything
      parentNavigatorKey: _rootNavigatorKey,
      path: '/login',
      builder: (context, state) => LoginScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/register',
      builder: (context, state) => RegisterationScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/forgot-password',
      builder: (context, state) => const Enteremail(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/reset-password',
      builder: (context, state) => const ResetPasswordScreen(),
    ),

    // ───────── Bottom Navigation System ─────────
    //           Each tab keeps its state
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
        // Insights / Predictions tab - index 2
        StatefulShellBranch(
          navigatorKey: _reportNavigatorKey,
          routes: [
            GoRoute(
              path: '/insights',
              builder: (context, state) => const FutureInsightsScreen(),
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
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,

      path: '/legal',
      builder: (context, state) => LegalInformationScreen(),
    ),
    // Chatbot route (fullscreen, no bottom nav)
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/chatbot',
      builder: (context, state) => const ChatScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/currency',
      builder: (context, state) {
        final isEdit = state.extra as bool? ?? false;
        return CurrencyScreen(isEdit: isEdit);
      },
    ),
  ],
);

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:spendly/features/authentication/Screens/Login_Screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spendly/features/Profile/Screens/legal_information_screen.dart';
import 'package:spendly/features/authentication/Screens/currency_screen.dart';
import 'package:spendly/features/authentication/Service/go_router_refresh_stream.dart';
import 'package:spendly/widgets/navigationbar.dart';
import 'package:spendly/features/main/screens/home_screen.dart';
import 'package:spendly/features/main/screens/all_transactions_screen.dart';
import 'package:spendly/features/wallet/screens/wallet_screen.dart';
import 'package:spendly/features/Report/Screens/report_screen.dart';
import 'package:spendly/features/Profile/Screens/profile_screen.dart';
import 'package:spendly/features/chatbot/Screens/chat_screen.dart';
import 'package:spendly/features/authentication/Screens/Registeration_Screen.dart';
import 'package:spendly/features/authentication/Screens/enter_email_Screen.dart';
import 'package:spendly/features/authentication/Screens/ResetPassword_Screen.dart';
import 'package:spendly/features/Scan/Screen/scan_receipt_screen.dart';
import 'package:spendly/features/Scan/Screen/scan_result_screen.dart';
import 'package:spendly/features/Scan/Service/receipt_parser.dart';

// Navigation keys for each branch
final rootNavigatorKey = GlobalKey<NavigatorState>();
final _homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _walletNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'wallet');
final _reportNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'report');
final _profileNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'profile');

/// Routes that do NOT require authentication.
const _publicRoutes = <String>[
  '/login',
  '/register',
  '/forgot-password',
  '/reset-password',
];

final GoRouter router = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/home',

  // ───────── REFRESH LISTENABLE ─────────
  // Re-evaluate redirect logic whenever the auth state changes
  // (sign-in, sign-out, token refresh, password recovery, etc.).
  refreshListenable: GoRouterRefreshStream(
    Supabase.instance.client.auth.onAuthStateChange,
  ),

  // ───────── REDIRECT GUARD ─────────
  redirect: (BuildContext context, GoRouterState state) {
    final session = Supabase.instance.client.auth.currentSession;
    final currentPath = state.matchedLocation;

    final isPublicRoute = _publicRoutes.contains(currentPath);

    // ───────── NOT LOGGED IN ─────────
    if (session == null) {
      if (isPublicRoute) return null;
      return '/login';
    }

    // ───────── LOGGED IN ─────────
    final createdAt = DateTime.parse(session.user.createdAt);
    final now = DateTime.now();
    final isNewUser = now.difference(createdAt).inSeconds < 30;

    // 🚀 FIRST LOGIN AFTER REGISTER → currency
    if (isNewUser && currentPath != '/currency') {
      return '/currency';
    }

    // Prevent going back to login/register
    if (isPublicRoute && currentPath != '/reset-password') {
      return '/home';
    }

    return null;
  },

  routes: [
    // ───────── AUTH ROUTES (no bottom nav) ─────────
    GoRoute(
      //Forces the route to open above everything
      parentNavigatorKey: rootNavigatorKey,
      path: '/login',
      builder: (context, state) => LoginScreen(),
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: '/register',
      builder: (context, state) => RegisterationScreen(),
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: '/forgot-password',
      builder: (context, state) => const Enteremail(),
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: '/reset-password',
      builder: (context, state) => const ResetPasswordScreen(),
    ),

    // ───────── Bottom Navigation System ─────────
    //         These keep state when switching tabs.
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
              path: '/insights',
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
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: '/report',
      redirect: (context, state) => '/insights',
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: '/legal',
      builder: (context, state) => LegalInformationScreen(),
    ),
    // Chatbot route (fullscreen, no bottom nav)
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: '/chatbot',
      builder: (context, state) => const ChatScreen(),
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: '/currency',
      builder: (context, state) {
        final isEdit = state.extra as bool? ?? false;
        return CurrencyScreen(isEdit: isEdit);
      },
    ),
    // ── Receipt Scan routes ─────────────────────────────────────────────────
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: '/scan-receipt',
      builder: (context, state) => const ScanReceiptScreen(),
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: '/scan-result',
      builder: (context, state) {
        final data = state.extra as ParsedReceiptData;
        return ScanResultScreen(initialData: data);
      },
    ),
    GoRoute(
      parentNavigatorKey: rootNavigatorKey,
      path: '/all-transactions',
      builder: (context, state) => const AllTransactionsScreen(),
    ),
  ],
);

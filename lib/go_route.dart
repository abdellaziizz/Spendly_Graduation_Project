import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spendly/features/Profile/Screens/legal_information_screen.dart';
import 'package:spendly/features/authentication/Screens/currency_screen.dart';
import 'package:spendly/features/authentication/Service/go_router_refresh_stream.dart';
import 'package:spendly/widgets/navigationbar.dart';
import 'package:spendly/features/main/screens/home_screen.dart';
import 'package:spendly/features/wallet/screens/wallet_screen.dart';
import 'package:spendly/features/Report/report_screen.dart';
import 'package:spendly/features/Profile/Screens/profile_screen.dart';
import 'package:spendly/features/chatbot/Screens/chat_screen.dart';
import 'package:spendly/features/authentication/Screens/login_screen.dart';
import 'package:spendly/features/authentication/Screens/Registeration_Screen.dart';
import 'package:spendly/features/authentication/Screens/enter_email_Screen.dart';
import 'package:spendly/features/authentication/Screens/ResetPassword_Screen.dart';
import 'package:spendly/features/Scan/scan_receipt_screen.dart';
import 'package:spendly/features/Scan/scan_result_screen.dart';
import 'package:spendly/features/Scan/receipt_parser.dart';

// Navigation keys for each branch
final _rootNavigatorKey = GlobalKey<NavigatorState>();
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
  navigatorKey: _rootNavigatorKey,
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
    final isLoggedIn = session != null;
    final currentPath = state.matchedLocation;

    final isPublicRoute = _publicRoutes.contains(currentPath);

    // ── Not authenticated ──
    if (!isLoggedIn) {
      // Allow access to public (auth) routes.
      if (isPublicRoute) return null;
      // Everything else → redirect to login.
      return '/login';
    }

    // ── Authenticated ──
    // If the user is on a login/register page, send them to home.
    // Exception: /reset-password is allowed even when authenticated
    // (the user arrives here via the password recovery deep link
    // which sets a temporary session).
    if (isPublicRoute && currentPath != '/reset-password') {
      return '/home';
    }

    // Allow navigation to proceed.
    return null;
  },

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
    // ── Receipt Scan routes ─────────────────────────────────────────────────
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/scan-receipt',
      builder: (context, state) => const ScanReceiptScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/scan-result',
      builder: (context, state) {
        final data = state.extra as ParsedReceiptData;
        return ScanResultScreen(initialData: data);
      },
    ),
  ],
);

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:tspendly/services/supabase_client.dart';
import 'package:tspendly/go_route.dart';
import 'package:tspendly/theme/theme.dart';
import 'package:tspendly/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load env FIRST so the variables are available for Supabase init
  await dotenv.load(fileName: ".env");

  // Initialize Supabase on all platforms
  try {
    await sb.Supabase.initialize(
      url: 'https://bajjqhcqfmvsniszytsf.supabase.co',
      anonKey: 'sb_publishable_i6MceD8i9QPiYviUu37dCg__O5B9Mzd',
    );
  } catch (e) {
    print('Supabase initialization failed: $e');
  }

  // Initialize shim that exposes `supabaseClient` (will be set on successful init).
  await initializeSupabaseClient();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    return MaterialApp.router(
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      title: 'spendly',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}

// final supabase = Supabase.instance.client;

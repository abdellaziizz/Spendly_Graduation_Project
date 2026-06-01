import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spendly/core/config/env.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spendly/go_route.dart';
import 'package:spendly/theme/theme.dart';
import 'package:spendly/theme/theme_provider.dart';
import 'package:spendly/features/authentication/providers/deep_link_providers.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:spendly/features/onboarding/Providers/onboarding_state_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load environment variables from the .env file
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(url: Env.supabaseUrl, anonKey: Env.supabaseAnonKey);
  
  // Initialize SharedPreferences before the app runs
  final sharedPrefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPrefs),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    // Initialize DeepLinkService once the app starts
    ref.read(deepLinkServiceProvider).initialize();
  }

  @override
  Widget build(BuildContext context) {
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

final supabase = Supabase.instance.client;

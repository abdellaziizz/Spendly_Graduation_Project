import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tspendly/go_route.dart';
import 'package:tspendly/theme/theme.dart';
import 'package:tspendly/theme/theme_provider.dart';
import 'package:tspendly/features/authentication/providers/deep_link_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load env FIRST so the variables are available for Supabase init
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: 'https://bajjqhcqfmvsniszytsf.supabase.co',
    anonKey: 'sb_publishable_i6MceD8i9QPiYviUu37dCg__O5B9Mzd',
  );

  runApp(const ProviderScope(child: MyApp()));
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

  // This widget is the root of your application.
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

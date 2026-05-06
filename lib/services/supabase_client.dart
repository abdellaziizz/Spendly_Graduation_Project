import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

/// A dynamic shim for the Supabase client to allow safe failure on web/dev.
///
/// Initialize with `initializeSupabaseClient()` after calling
/// `Supabase.initialize(...)` (on platforms where you want Supabase).

dynamic supabaseClient;

Future<void> initializeSupabaseClient() async {
  try {
    // Try to get the Supabase instance on all platforms.
    // On web, this works after Supabase.initialize() is called.
    supabaseClient = sb.Supabase.instance.client;
  } catch (e) {
    // If Supabase wasn't initialized or an error occurred, leave null.
    supabaseClient = null;
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';

Future<String> resolveOrCreateCategory(
  SupabaseClient supabase,
  String userId,
  String categoryName,
) async {
  // SQL: SELECT id FROM public.categories
  //      WHERE users_id = $userId AND name = $categoryName
  final existing = await supabase
      .from('categories')
      .select('id')
      .eq('users_id', userId)
      .eq('name', categoryName)
      .maybeSingle();

  if (existing != null) return existing['id'] as String;

  // SQL: INSERT INTO public.categories (users_id, name, icon)
  //      VALUES ($userId, $name, $icon) RETURNING id;
  final inserted = await supabase
      .from('categories')
      .insert({
        'users_id': userId,
        'name': categoryName,
        'icon': 'category_rounded',
      })
      .select('id')
      .single();

  return inserted['id'] as String;
}

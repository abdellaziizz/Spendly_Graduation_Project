import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spendly/core/categories/category_helpers.dart';

/// Looks up an existing category row for [userId] + [categoryName].
/// Creates one with the correct icon key if it does not yet exist.
///
/// The icon key is always derived from [CategoryHelpers.findByName] so it
/// is guaranteed to be a value present in [categoryIconMap].
Future<String> resolveOrCreateCategory(
  SupabaseClient supabase,
  String userId,
  String categoryName,
) async {
  // Always work with the canonical name to avoid duplicates from legacy strings
  final canonical = CategoryHelpers.canonicalise(categoryName);
  final category = CategoryHelpers.findByName(canonical);

  // Try to find an existing row
  final existing = await supabase
      .from('categories')
      .select('id')
      .eq('users_id', userId)
      .eq('name', category.name)
      .maybeSingle();

  if (existing != null) return existing['id'] as String;

  // Create a new row with the correct icon key
  final inserted = await supabase
      .from('categories')
      .insert({
        'users_id': userId,
        'name': category.name,
        'icon': category.iconKey,
      })
      .select('id')
      .single();

  return inserted['id'] as String;
}

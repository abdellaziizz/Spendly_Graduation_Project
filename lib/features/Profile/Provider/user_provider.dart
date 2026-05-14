import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileInfo {
  final String fullName;
  final String gender;
  final String email;

  ProfileInfo({
    required this.fullName,
    required this.gender,
    required this.email,
  });
}

final profileNameProvider = FutureProvider<ProfileInfo>((ref) async {
  final supabase = Supabase.instance.client;
  // RLS: auth.uid() = id — no extra filter needed
  final data = await supabase
      .from('users')
      .select('full_name, gender, email')
      .single();

  final fullName = (data['full_name'] as String? ?? '').trim();
  final gender = (data['gender'] as String? ?? 'male').trim();
  final email = (data['email'] as String? ?? '').trim();

  // Return first word only
  return ProfileInfo(fullName: fullName, gender: gender, email: email);
});

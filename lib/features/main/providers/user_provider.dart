import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserInfo {
  final String firstName;
  final String gender;
  final String email;

  UserInfo({
    required this.firstName,
    required this.gender,
    required this.email,
  });
}

final userInfoProvider = FutureProvider<UserInfo>((ref) async {
  final supabase = Supabase.instance.client;
  // RLS: auth.uid() = id — no extra filter needed
  final data = await supabase.from('users').select('full_name').single();
  final fullName = (data['full_name'] as String? ?? '').trim();
  final gender = (data['gender'] as String? ?? 'male').trim();
  final email = (data['email'] as String? ?? '').trim();
  final firstName = fullName.split(' ').first.isEmpty
      ? 'User'
      : fullName.split(' ').first;
  // Return first word only
  return UserInfo(firstName: firstName, gender: gender, email: email);
  ;
});

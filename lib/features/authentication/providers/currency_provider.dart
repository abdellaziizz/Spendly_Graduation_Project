import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserCurrency {
  final String code;
  const UserCurrency(this.code);
}

final currencyProvider = AsyncNotifierProvider<CurrencyNotifier, UserCurrency>(
  CurrencyNotifier.new,
);
final supabase = Supabase.instance.client;
final userId = supabase.auth.currentUser!.id;

class CurrencyNotifier extends AsyncNotifier<UserCurrency> {
  @override
  // Display the currency "ONLY THE THREE CHARACTERS EX: EGP"
  Future<UserCurrency> build() async {
    final response = await supabase
        .from('users')
        .select('currency')
        .eq('id', userId)
        .single();

    return UserCurrency(response['currency']);
  }

  // Insert if not exist and update if exist ya sheifo
  Future<void> setCurrency(String newCurrency) async {
    await supabase.from('users').upsert({
      'id': userId,
      'email': supabase.auth.currentUser!.email,
      'currency': newCurrency,
    });

    state = AsyncData(UserCurrency(newCurrency));
  }
}

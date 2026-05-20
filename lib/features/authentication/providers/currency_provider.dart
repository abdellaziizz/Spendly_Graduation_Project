import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spendly/features/authentication/Model/currency_data.dart';

class UserCurrency {
  final String code;
  final String symbol;
  const UserCurrency(this.code, this.symbol);
}

final currencyProvider = AsyncNotifierProvider<CurrencyNotifier, UserCurrency>(
  CurrencyNotifier.new,
);

final currencySymbolProvider = Provider<String>((ref) {
  final asyncVal = ref.watch(currencyProvider);
  return asyncVal.valueOrNull?.symbol ?? '\$';
});

class CurrencyNotifier extends AsyncNotifier<UserCurrency> {
  SupabaseClient get supabase => Supabase.instance.client;

  @override
  Future<UserCurrency> build() async {
    final user = supabase.auth.currentUser;
    if (user == null) return UserCurrency('USD', '\$');
    
    final response = await supabase
        .from('users')
        .select('currency')
        .eq('id', user.id)
        .single();

    final code = response['currency'] as String? ?? 'USD';
    final symbol = _getSymbol(code);

    return UserCurrency(code, symbol);
  }

  Future<void> setCurrency(String newCurrency) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;
    
    await supabase.from('users').upsert({
      'id': user.id,
      'email': user.email,
      'currency': newCurrency,
    });

    state = AsyncData(UserCurrency(newCurrency, _getSymbol(newCurrency)));
  }

  String _getSymbol(String code) {
    return allCurrencies.firstWhere(
      (c) => c.code == code,
      orElse: () => allCurrencies.firstWhere((c) => c.code == 'USD')
    ).symbol;
  }
}

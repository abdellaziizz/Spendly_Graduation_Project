import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

final selectedCurrencyProvider = StateProvider<int>((ref) => -1);

class CurrencyScreen extends ConsumerWidget {
  final bool isEdit;

  const CurrencyScreen({super.key, this.isEdit = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedCurrencyProvider);

    final currencies = [
      {
        'name': 'Egyptian Pound',
        'code': 'EGP',
        'flag': 'assets/icons/currency/Egypt.svg',
      },
      {
        'name': 'British Pound',
        'code': 'GBP',
        'flag': 'assets/icons/currency/UnitedKingdom.svg',
      },
      {
        'name': 'US Dollar',
        'code': 'USD',
        'flag': 'assets/icons/currency/USA.svg',
      },
      {
        'name': 'Saudi Riyal',
        'code': 'SAR',
        'flag': 'assets/icons/currency/SaudiArabia.svg',
      },
      {'name': 'Euro', 'code': 'EUR', 'flag': 'assets/icons/currency/EUR.svg'},
    ];

    // Future<void> saveCurrency() async {
    //   if (selectedIndex == -1) return;

    //   // await supabase.from('profiles').upsert({
    //   //   'id': userId,
    //   //   'currency': selectedCurrency,
    //   // });

    //   if (!isEdit) {
    //     context.go('/home');
    //   } else {
    //     Navigator.pop(context);
    //   }
    // }
    Future<void> saveCurrency(BuildContext context, WidgetRef ref) async {
      final selectedIndex = ref.read(selectedCurrencyProvider);

      if (selectedIndex == -1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select a currency first")),
        );
        return;
      }

      context.go('/home');
    }

    return Scaffold(
      appBar: isEdit ? AppBar(title: const Text("Change Currency")) : null,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 50),
            const Text(
              "Choose your Currency",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xff00365A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Select your preferred currency to track your expense",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Color(0xff757575)),
            ),
            const SizedBox(height: 20),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: currencies.length,
                itemBuilder: (context, index) {
                  final currency = currencies[index];
                  final isSelected = selectedIndex == index;

                  return GestureDetector(
                    onTap: () {
                      ref.read(selectedCurrencyProvider.notifier).state = index;
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Color(0xff00365A)
                              : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(currency['flag']!, width: 40),
                          const SizedBox(width: 12),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currency['name']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(currency['code']!),
                            ],
                          ),

                          const Spacer(),

                          Icon(
                            isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: isSelected ? Colors.blue : Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedIndex == -1
                    ? null
                    : () => saveCurrency(context, ref),
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedIndex == -1
                      ? Colors.grey
                      : Color(0xff00365A),
                ),
                child: const Text(
                  "Continue",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

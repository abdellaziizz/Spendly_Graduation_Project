import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tspendly/features/Currency/currency_model.dart';
import 'package:tspendly/features/main/screens/home_screen.dart';

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  final List<CurrencyModel> currencyList = [
    CurrencyModel(
      CountryLogo: 'assets/icons/currency/Group1.svg',
      CurrencyName: 'Euro',
      SubName: 'EUR',
    ),
    CurrencyModel(
      CountryLogo: 'assets/icons/currency/Egypt.svg',
      CurrencyName: 'Egypt Pound',
      SubName: 'EGP',
    ),
    CurrencyModel(
      CountryLogo: 'assets/icons/currency/SaudiArabia.svg',
      CurrencyName: 'Saudi Riyal',
      SubName: 'SAR',
    ),
    CurrencyModel(
      CountryLogo: 'assets/icons/currency/UnitedKingdom.svg',
      CurrencyName: 'British Pound',
      SubName: 'GBP',
    ),
    CurrencyModel(
      CountryLogo: 'assets/icons/currency/USA.svg',
      CurrencyName: 'US Dollar',
      SubName: 'USD',
    ),
  ];

  late List<bool> isSelected = List.generate(
    currencyList.length,
    (index) => false,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 24),
                const Text(
                  'Choose your Currency',
                  style: TextStyle(
                    color: Color(0xff00365A),
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                const Text(
                  'Select your preferred currency to track your expense',
                  style: TextStyle(color: Color(0xff757575)),
                ),

                const SizedBox(height: 30),

                for (var i = 0; i < currencyList.length; i++)
                  Container(
                    width: 360,
                    height: 85,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected[i]
                          ? Border.all(color: const Color(0xff0000FF))
                          : Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          currencyList[i].CountryLogo,
                          width: 42,
                          height: 42,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currencyList[i].CurrencyName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              currencyList[i].SubName,
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Checkbox(
                          value: isSelected[i],
                          activeColor: const Color(0xff0000FF),
                          onChanged: (value) {
                            setState(() {
                              isSelected[i] = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 42),

                // Continue button → MainScreen
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const MainScreen()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff274C77),
                    fixedSize: const Size(335, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Continue  ->',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

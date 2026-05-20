import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spendly/features/authentication/Model/currency_data.dart';
import 'package:spendly/features/authentication/providers/currency_provider.dart';
import 'package:spendly/theme/colors.dart';

final selectedCurrencyProvider = StateProvider<int>((ref) => -1);

class CurrencyScreen extends ConsumerStatefulWidget {
  final bool isEdit;

  const CurrencyScreen({super.key, this.isEdit = false});

  @override
  ConsumerState<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends ConsumerState<CurrencyScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  static const _popularCodes = [
    'EGP',
    'USD',
    'EUR',
    'GBP',
    'SAR',
    'AED',
    'KWD',
    'JPY',
    'CNY',
    'INR',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CurrencyInfo> get _filteredCurrencies {
    if (_searchQuery.isEmpty) return allCurrencies;
    final q = _searchQuery.toLowerCase();
    return allCurrencies
        .where((currency) =>
            currency.name.toLowerCase().contains(q) ||
            currency.code.toLowerCase().contains(q) ||
            currency.symbol.contains(q))
        .toList();
  }

  List<CurrencyInfo> get _popularCurrencies {
    return _popularCodes
        .map((code) => allCurrencies.firstWhere((currency) => currency.code == code))
        .toList();
  }

  Future<void> _saveCurrency(BuildContext context, WidgetRef ref) async {
    final selectedIndex = ref.read(selectedCurrencyProvider);
    final currentCode = ref.read(currencyProvider).valueOrNull?.code;
    final currentIndex = currentCode == null
        ? -1
        : allCurrencies.indexWhere((currency) => currency.code == currentCode);
    final finalIndex = selectedIndex != -1 ? selectedIndex : currentIndex;

    if (finalIndex == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a currency first')),
      );
      return;
    }

    final selectedCode = allCurrencies[finalIndex].code;
    final user = Supabase.instance.client.auth.currentUser;

    if (user != null) {
      await Supabase.instance.client
          .from('users')
          .update({'currency': selectedCode})
          .eq('id', user.id);
    }

    await ref.read(currencyProvider.notifier).setCurrency(selectedCode);

    if (!context.mounted) return;
    if (widget.isEdit && context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(selectedCurrencyProvider);
    final savedCurrencyCode = ref.watch(currencyProvider).valueOrNull?.code;
    final savedIndex = savedCurrencyCode == null
        ? -1
        : allCurrencies.indexWhere((currency) => currency.code == savedCurrencyCode);
    final effectiveIndex = selectedIndex != -1 ? selectedIndex : savedIndex;

    final filtered = _filteredCurrencies;
    final showPopular = _searchQuery.isEmpty;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ??
        (isDark ? Colors.white : Colors.black87);
    final subtitleColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final primaryColor = isDark ? AppColors.buttonDark : const Color(0xff00365A);
    final searchBgColor = isDark ? AppColors.darkSurface : const Color(0xFFF5F5F7);
    final tileBgColor = isDark ? AppColors.darkSurface : Colors.white;
    final borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: widget.isEdit
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.chevron_left, size: 28),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/profile');
                  }
                },
              ),
              title: const Text('Change Currency'),
            )
          : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!widget.isEdit) const SizedBox(height: 50),
              Center(
                child: Text(
                  'Choose your Currency',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Select your preferred currency to track your expenses',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: subtitleColor),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: searchBgColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: 'Search currency or country...',
                    hintStyle: TextStyle(color: subtitleColor, fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: subtitleColor),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, size: 18, color: subtitleColor),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    if (showPopular) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Popular',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: subtitleColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      ..._popularCurrencies.map(
                        (currency) => _buildCurrencyTile(
                          currency,
                          effectiveIndex,
                          primaryColor,
                          tileBgColor,
                          borderColor,
                          textColor,
                          subtitleColor,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Divider(color: borderColor),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'All Currencies',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: subtitleColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                    if (filtered.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: Center(
                          child: Text(
                            'No currencies found',
                            style: TextStyle(color: subtitleColor),
                          ),
                        ),
                      )
                    else
                      ...filtered.map(
                        (currency) => _buildCurrencyTile(
                          currency,
                          effectiveIndex,
                          primaryColor,
                          tileBgColor,
                          borderColor,
                          textColor,
                          subtitleColor,
                        ),
                      ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _saveCurrency(context, ref),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Save Currency'),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencyTile(
    CurrencyInfo currency,
    int selectedIndex,
    Color primaryColor,
    Color tileBgColor,
    Color borderColor,
    Color textColor,
    Color subtitleColor,
  ) {
    final index = allCurrencies.indexOf(currency);
    final isSelected = index == selectedIndex;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          ref.read(selectedCurrencyProvider.notifier).state = index;
          setState(() {});
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor.withValues(alpha: 0.08) : tileBgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? primaryColor : borderColor,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: isSelected
                    ? primaryColor.withValues(alpha: 0.16)
                    : borderColor.withValues(alpha: 0.25),
                child: Text(
                  currency.flag,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currency.name,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${currency.code} • ${currency.symbol}',
                      style: TextStyle(color: subtitleColor, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Radio<int>(
                value: index,
                groupValue: selectedIndex,
                activeColor: primaryColor,
                onChanged: (_) {
                  ref.read(selectedCurrencyProvider.notifier).state = index;
                  setState(() {});
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

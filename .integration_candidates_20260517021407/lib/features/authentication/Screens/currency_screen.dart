import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spendly/features/authentication/Model/currency_data.dart';
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

  // Popular currencies shown at the top
  static const _popularCodes = ['EGP', 'USD', 'EUR', 'GBP', 'SAR', 'AED', 'KWD', 'JPY', 'CNY', 'INR'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CurrencyInfo> get _filteredCurrencies {
    if (_searchQuery.isEmpty) return allCurrencies;
    final q = _searchQuery.toLowerCase();
    return allCurrencies
        .where((c) =>
            c.name.toLowerCase().contains(q) ||
            c.code.toLowerCase().contains(q) ||
            c.symbol.contains(q))
        .toList();
  }

  List<CurrencyInfo> get _popularCurrencies {
    return _popularCodes
        .map((code) => allCurrencies.firstWhere((c) => c.code == code))
        .toList();
  }

  Future<void> _saveCurrency(BuildContext context, WidgetRef ref) async {
    final selectedIndex = ref.read(selectedCurrencyProvider);
    if (selectedIndex == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a currency first")),
      );
      return;
    }
    
    // The original code unconditionally did context.go('/home');
    // For editing, you might want context.pop() depending on your router setup.
    if (widget.isEdit && context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(selectedCurrencyProvider);
    final filtered = _filteredCurrencies;
    final showPopular = _searchQuery.isEmpty;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Colors.black87);
    final subtitleColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    
    // Use the original primary color or the dark theme's primary color
    final primaryColor = isDark ? AppColors.buttonDark : const Color(0xff00365A);
    final searchBgColor = isDark ? AppColors.darkSurface : const Color(0xFFF5F5F7);
    final tileBgColor = isDark ? AppColors.darkSurface : Colors.white;
    final borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: widget.isEdit ? AppBar(title: const Text("Change Currency")) : null,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!widget.isEdit) const SizedBox(height: 50),
            Center(
              child: Text(
                "Choose your Currency",
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
                "Select your preferred currency to track your expenses",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: subtitleColor),
              ),
            ),
            const SizedBox(height: 20),

            // Search bar
            Container(
              decoration: BoxDecoration(
                color: searchBgColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
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

            // Currency list
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  // Popular section
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
                    ..._popularCurrencies.map((c) => _buildCurrencyTile(
                          c, 
                          selectedIndex, 
                          primaryColor, 
                          tileBgColor, 
                          borderColor, 
                          textColor, 
                          subtitleColor
                        )),
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
                      padding: const EdgeInsets.only(top: 40),
                      child: Center(
                        child: Text(
                          'No currencies found',
                          style: TextStyle(color: subtitleColor, fontSize: 14),
                        ),
                      ),
                    ),

                  ...filtered.map((c) => _buildCurrencyTile(
                        c, 
                        selectedIndex, 
                        primaryColor, 
                        tileBgColor, 
                        borderColor, 
                        textColor, 
                        subtitleColor
                      )),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Continue button
            Padding(
              padding: const EdgeInsets.only(bottom: 24, top: 8),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: selectedIndex == -1
                      ? null
                      : () => _saveCurrency(context, ref),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedIndex == -1
                        ? (isDark ? Colors.grey.shade800 : Colors.grey.shade300)
                        : primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    widget.isEdit ? "Save" : "Continue",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: selectedIndex == -1 && isDark ? Colors.grey.shade500 : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
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
    // We compute globalIndex because the search list and popular list only have subsets.
    // The provider tracks the index in the massive `allCurrencies` list.
    final globalIndex = allCurrencies.indexOf(currency);
    final isSelected = selectedIndex == globalIndex;

    return GestureDetector(
      onTap: () {
        // Safe robust way to update state
        ref.read(selectedCurrencyProvider.notifier).state = globalIndex;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withValues(alpha: 0.1) : tileBgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? primaryColor : borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Flag emoji
            Text(
              currency.flag,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(width: 14),

            // Name + code
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currency.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isSelected ? primaryColor : textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${currency.code}  •  ${currency.symbol}',
                    style: TextStyle(
                      fontSize: 12,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ),
            ),

            // Radio indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? primaryColor : subtitleColor,
                  width: 2,
                ),
                color: isSelected ? primaryColor : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

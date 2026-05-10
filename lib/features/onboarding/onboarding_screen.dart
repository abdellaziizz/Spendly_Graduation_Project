import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tspendly/features/onboarding/Providers/onboard_provider.dart';
import 'package:tspendly/features/authentication/Screens/login_screen.dart';
import 'package:tspendly/widgets/onboarding_page_widget.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext(int currentIndex) {
    if (currentIndex < 2) {
      _pageController.animateToPage(
        currentIndex + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to Login screen
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen()));
    }
  }

  void _onSkip() {
    _pageController.animateToPage(
      2,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(onboardingPageIndexProvider);

    return Scaffold(
      backgroundColor: Color(0xffEEF0F2),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/logo/logo.png',
                    height: 32,
                    fit: BoxFit.contain,
                  ),
                  if (currentIndex < 2)
                    TextButton(
                      onPressed: _onSkip,
                      style: TextButton.styleFrom(
                        foregroundColor: Color(0xff757575),
                      ),
                      child: const Text('Skip', style: TextStyle(fontSize: 16)),
                    )
                  else
                    const SizedBox(height: 48),
                ],
              ),
            ),

            // Page View
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) {
                  ref
                      .read(onboardingPageIndexProvider.notifier)
                      .setIndex(index);
                },
                children: const [
                  OnboardingPageWidget(
                    imagePath: 'assets/images/onboarding1.jpg',
                    title: 'Track Expenses ',
                    isTitleRich: true,
                    titlePart1: 'Track Expenses',
                    titlePart2: 'easily',
                    subtitle:
                        'Spendly automates your expense tracking so you can focus on what matter most',
                  ),
                  OnboardingPageWidget(
                    imagePath: 'assets/images/onboarding2.jpg',
                    title: 'Voice Input',
                    subtitle:
                        'Just say it to track it. Log your expenses instantly using voice commands for seamless, hands-free experience.',
                  ),
                  OnboardingPageWidget(
                    imagePath: 'assets/images/onboarding3.jpg',
                    title: 'Smart Budgeting\nInsights',
                    isTitleRich: true,
                    titlePart1: 'Smart Budgeting',
                    titlePart2: 'Insights',
                    subtitle:
                        'Visualize your progress with intuitive charts and custom budgets designed to keep you on track toward your goals.',
                  ),
                ],
              ),
            ),

            // Bottom Section (Indicators and Button)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 24.0,
              ),
              child: Column(
                children: [
                  // Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        height: 8,
                        width: currentIndex == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: currentIndex == index
                              ? Color(0xff6096BA)
                              : Color(0xffD9D9D9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => _onNext(currentIndex),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff00365A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        currentIndex == 2 ? 'Get started' : 'Next →',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

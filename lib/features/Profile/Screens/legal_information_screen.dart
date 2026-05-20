import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:spendly/features/Profile/Model/InfoCardModel%20.dart';
import 'package:spendly/features/Profile/Widget/legal_widget.dart';
import 'package:spendly/theme/theme_extensions.dart';

class LegalInformationScreen extends StatelessWidget {
  LegalInformationScreen({super.key});

  final List<InfoCardModel> cards = [
    InfoCardModel(
      title: 'Privacy Policy',
      icon: Icons.shield_outlined,
      subtitle1:
          'Spendly is designed with privacy at its core. We do not sell your personal data to third parties. Your financial information is used solely to provide personalised insights and automated categorisation.',
      subtitle2:
          'We collect minimal identification data required to maintain your account and sync across devices. For detailed information on data retention and your right to be forgotten, please review the full document.',
      iconColor: const Color(0xFF3525CD),
      iconBgColor: const Color(0xFF3525CD),
    ),
    InfoCardModel(
      title: 'Terms of Service',
      icon: Icons.gavel_outlined,
      subtitle1:
          "By using Spendly's voice input features, you acknowledge that voice data is processed using encrypted cloud computing. This data is anonymised immediately after transcription.",
      subtitle2:
          'Automated categorisation is an assistive tool; users are responsible for verifying the accuracy of their financial records for tax and legal purposes.',
      iconColor: const Color(0xFF006F66),
      iconBgColor: const Color(0xFF86F2E4),
    ),
    InfoCardModel(
      title: 'Data Security',
      icon: Icons.lock,
      subtitle1:
          'We use AES-256 encryption at rest and TLS 1.3 for all data transfers. Your credentials are never stored on our servers.',
      iconColor: const Color(0xFF3525CD),
      iconBgColor: const Color(0xFF3525CD),
    ),
    InfoCardModel(
      title: 'Third-Party Licenses',
      icon: Icons.connect_without_contact,
      subtitle1:
          'Spendly is built upon the shoulders of the open-source community. View credits for the libraries that make our platform possible.',
      iconColor: const Color(0xFF006F66),
      iconBgColor: const Color(0xFF86F2E4),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: Colors.black,
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/profile');
              }
            },
          ),
          title: const Text(
            'Legal Information',
            style: TextStyle(
              color: Color(0xFF1A1C1E),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: false,
          titleSpacing: 0,
        ),
        backgroundColor: const Color(0xffFCF8FF),
        body: ListView.builder(
          itemCount: cards.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final item = cards[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: LegalWidget(
                title: item.title,
                icon: item.icon,
                subtitle1: item.subtitle1,
                subtitle2: item.subtitle2 ?? '',
                iconColor: item.iconColor,
                iconBackgroundColor: item.iconBgColor.withValues(alpha: 0.2),
              ),
            );
          },
        ),
      ),
    );
  }
}

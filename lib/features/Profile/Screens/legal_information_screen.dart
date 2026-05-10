import 'package:flutter/material.dart';
import 'package:tspendly/features/Profile/Model/InfoCardModel%20.dart';
import 'package:tspendly/features/Profile/Widget/legal_widget.dart';

class LegalInformationScreen extends StatelessWidget {
  LegalInformationScreen({super.key});

  final List<InfoCardModel> cards = [
    InfoCardModel(
      title: 'Privacy Policy',
      icon: Icons.shield_outlined,
      subtitle1:
          'Spendly is designed with privacy at its core. We do not sell your personal data to third parties. Your financial information is used solely to provide personalized insights and automated categorization.',
      subtitle2:
          'We collect minimal identification data required to maintain your account and sync acrossdevices. For detailed information on data retention and your right to be forgotten, please review the full document.',
      iconColor: Color(0xff3525CD),
      iconBgColor: Color(0xff3525CD).withOpacity(0.2),
    ),
    InfoCardModel(
      title: 'Terms of Service',
      icon: Icons.gavel_outlined,
      subtitle1:
          "By using Spendly's voice input features, you acknowledge that voice data is processed using encrypted cloud computing to ensure high accuracy. This data is anonymized immediately after transcription.",
      subtitle2:
          "Automated categorization is an assistive tool; users are responsible for verifying the accuracy of their financial records for tax and legal purposes.",
      iconColor: Color(0xff006F66),
      iconBgColor: Color(0xff86F2E4),
    ),
    InfoCardModel(
      title: 'Data Security',
      icon: Icons.lock,
      subtitle1:
          "We use AES-256 encryption at rest and TLS 1.3 for all data transfers. Your credentials are never stored on our servers..",
      iconColor: Color(0xff3525CD),
      iconBgColor: Color(0xff3525CD).withOpacity(0.2),
    ),
    InfoCardModel(
      title: 'Third-Party Licenses',
      icon: Icons.connect_without_contact,
      subtitle1:
          "Spendly is built upon the shoulders of the open-source community. View credits for the libraries that make our platform possible.",
      iconColor: Color(0xff006F66),
      iconBgColor: Color(0xff86F2E4),
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0, // Set to 0 to remove the shadow for a flat look
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: Colors.black, // Deep purple color from your image
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text(
            'Legal Information',
            style: TextStyle(
              color: Color(0xFF1A1C1E), // Dark near-black for the text
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: false, // Ensures the title stays left-aligned
          titleSpacing: 0, // Reduces space between the back arrow and the title
        ),
        backgroundColor: Color(0xffFCF8FF),
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
                iconBackgroundColor: item.iconBgColor,
              ),
            );
          },
        ),
      ),
    );
  }
}

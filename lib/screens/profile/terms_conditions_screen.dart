import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  static const Color _dark = Color(0xFF1A1A2E);
  static const Color _gray = Color(0xFF8E8E93);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: _dark),
        title: Text('Terms & Conditions',
            style:
                GoogleFonts.poppins(color: _dark, fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Terms & Conditions',
                  style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _dark)),
              const SizedBox(height: 4),
              Text('Last updated: August 2026',
                  style: GoogleFonts.poppins(fontSize: 12, color: _gray)),
              const SizedBox(height: 20),
              _section('1. Acceptance of Terms',
                  'By accessing and using the Mashvira Law House mobile application ("App"), you agree to be bound by these Terms & Conditions. If you do not agree, please do not use the App.'),
              _section('2. Services',
                  'Mashvira Law House provides a platform connecting clients with qualified legal professionals in Pakistan. The App facilitates case submission, lawyer assignment, document management, and communication between clients and lawyers.'),
              _section('3. User Accounts',
                  'You must provide accurate and complete information when creating an account. You are responsible for maintaining the confidentiality of your account credentials. You must notify us immediately of any unauthorized use of your account.'),
              _section('4. User Responsibilities',
                  'Users agree to: (a) provide truthful and accurate information in case submissions; (b) upload only legitimate documents; (c) not use the App for any illegal or unauthorized purpose; (d) respect the privacy and confidentiality of all parties involved.'),
              _section('5. Legal Services Disclaimer',
                  'Mashvira Law House acts as an intermediary platform. We do not provide legal advice directly. All legal services are provided by independent lawyers registered on our platform. We do not guarantee the outcome of any legal matter.'),
              _section('6. Payments',
                  'Lawyer fees are determined between the lawyer and client through the platform. Mashvira may charge a service fee. All payments are processed securely. Refund policies are subject to the specific terms agreed upon with your assigned lawyer.'),
              _section('7. Privacy',
                  'Your privacy is important to us. Please refer to our Privacy Policy for information on how we collect, use, and protect your personal data.'),
              _section('8. Intellectual Property',
                  'All content, trademarks, and intellectual property in the App are owned by Mashvira Law House. You may not copy, modify, or distribute any content without prior written consent.'),
              _section('9. Limitation of Liability',
                  'Mashvira Law House shall not be liable for any indirect, incidental, special, or consequential damages arising from your use of the App or services provided through the platform.'),
              _section('10. Changes to Terms',
                  'We reserve the right to modify these Terms & Conditions at any time. Continued use of the App after changes constitutes acceptance of the revised terms.'),
              _section('11. Contact',
                  'For questions about these Terms & Conditions, contact us at:\nsupport@mashvira.com\n+92 312 3456789'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _dark)),
          const SizedBox(height: 6),
          Text(body,
              style: GoogleFonts.poppins(
                  fontSize: 13, color: _gray, height: 1.6)),
        ],
      ),
    );
  }
}

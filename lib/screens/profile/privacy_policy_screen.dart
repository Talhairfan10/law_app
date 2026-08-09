import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
        title: Text('Privacy Policy',
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
              Text('Privacy Policy',
                  style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _dark)),
              const SizedBox(height: 4),
              Text('Last updated: August 2026',
                  style: GoogleFonts.poppins(fontSize: 12, color: _gray)),
              const SizedBox(height: 20),
              _section('1. Information We Collect',
                  'We collect information you provide directly: full name, email address, phone number, profile photo, and case-related details (descriptions, documents). We also collect usage data such as app interactions and device information.'),
              _section('2. How We Use Your Information',
                  'Your information is used to: (a) provide and improve our services; (b) match you with qualified lawyers; (c) process payments; (d) send notifications about your cases; (e) provide customer support; (f) comply with legal obligations.'),
              _section('3. Data Storage & Security',
                  'Your data is stored securely using Google Firebase infrastructure with industry-standard encryption. Access to your case information is restricted to you, your assigned lawyer, and authorized Mashvira staff.'),
              _section('4. Information Sharing',
                  'We share your case information only with: (a) your assigned lawyer; (b) our internal legal team for case review; (c) payment processors for transaction processing. We do not sell your personal data to third parties.'),
              _section('5. Your Rights',
                  'You have the right to: (a) access your personal data; (b) correct inaccurate information; (c) request deletion of your account and data; (d) withdraw consent for data processing; (e) export your data.'),
              _section('6. Document Security',
                  'All legal documents uploaded to the platform are encrypted in transit and at rest. Documents are stored in Firebase Storage with strict access controls. Only authorized parties can view your documents.'),
              _section('7. Cookies & Analytics',
                  'The App may use analytics tools to understand usage patterns and improve the user experience. No personally identifiable information is shared with analytics providers.'),
              _section('8. Data Retention',
                  'We retain your data for as long as your account is active or as needed to provide services. Case data is retained for a minimum of 5 years after case completion for legal compliance purposes.'),
              _section('9. Children\'s Privacy',
                  'The App is not intended for use by individuals under 18 years of age. We do not knowingly collect personal information from minors.'),
              _section('10. Changes to This Policy',
                  'We may update this Privacy Policy from time to time. We will notify you of significant changes via the App or email. Continued use after changes constitutes acceptance.'),
              _section('11. Contact Us',
                  'For privacy-related inquiries or to exercise your rights, contact us at:\nsupport@mashvira.com\n+92 312 3456789\n\nData Protection Officer\nMashvira Law House\nLahore, Punjab, Pakistan'),
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

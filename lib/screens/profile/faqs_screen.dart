import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FaqsScreen extends StatelessWidget {
  const FaqsScreen({super.key});

  static const Color _primary = Color(0xFF6C5CE7);
  static const Color _dark = Color(0xFF1A1A2E);
  static const Color _gray = Color(0xFF8E8E93);

  // Structured as a list of maps — can be migrated to a Firestore `faqs`
  // collection later without changing the UI code.
  static const List<Map<String, String>> _faqs = [
    {
      'question': 'How do I submit a new case?',
      'answer':
          'Tap "New Case" on the home screen, then follow the 5-step process: select category, enter details, upload documents, choose a lawyer preference, and review & submit. You will receive a notification once your case is submitted.',
    },
    {
      'question': 'How long does it take to get a lawyer assigned?',
      'answer':
          'Typically within 24 hours of submission. Our legal team reviews your case and assigns the most suitable lawyer based on their expertise and availability. You will be notified once a lawyer is assigned.',
    },
    {
      'question': 'What are the fees?',
      'answer':
          'Fees vary based on the case complexity and the lawyer\'s seniority. Once a lawyer is assigned, they will review your case and propose a fee. You can review the fee before making any payment.',
    },
    {
      'question': 'How do I track my case progress?',
      'answer':
          'Go to "My Cases" from the home screen or bottom navigation. Tap any case to see its detailed progress through 9 stages — from submission to completion.',
    },
    {
      'question': 'What documents do I need to upload?',
      'answer':
          'Required documents vary by case type. Generally, you should upload any relevant legal documents, contracts, court orders, or evidence that supports your case. Your lawyer may request additional documents later.',
    },
    {
      'question': 'How do I make a payment?',
      'answer':
          'Once a lawyer fee is approved, you will receive a payment notification. Go to the Payments section to complete the payment using your saved payment method or add a new one.',
    },
    {
      'question': 'Can I change my assigned lawyer?',
      'answer':
          'In certain circumstances, you can request a lawyer change by contacting our support team. We will evaluate your request and assign an alternative lawyer if appropriate.',
    },
    {
      'question': 'Is my information secure?',
      'answer':
          'Yes. We use industry-standard encryption and security measures. All your personal data and case information is stored securely on Firebase with strict access controls. Only you and your assigned lawyer can access your case details.',
    },
    {
      'question': 'How do I contact my lawyer?',
      'answer':
          'Once a lawyer is assigned, you will be able to contact them through the in-app messaging feature (coming soon). In the meantime, you can reach out to support for any urgent communications.',
    },
    {
      'question': 'How do I delete my account?',
      'answer':
          'To request account deletion, please contact our support team at support@mashvira.com. We will process your request within 7 business days in accordance with our privacy policy.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: _dark),
        title: Text('FAQs',
            style:
                GoogleFonts.poppins(color: _dark, fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Find answers to common questions',
                style: GoogleFonts.poppins(fontSize: 13, color: _gray)),
            const SizedBox(height: 20),
            Container(
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ExpansionPanelList.radio(
                  elevation: 0,
                  expandedHeaderPadding: EdgeInsets.zero,
                  dividerColor: Colors.grey.shade100,
                  children: _faqs.asMap().entries.map((entry) {
                    final faq = entry.value;
                    return ExpansionPanelRadio(
                      value: entry.key,
                      canTapOnHeader: true,
                      headerBuilder: (_, isExpanded) => Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: _primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                  Icons.help_outline_rounded,
                                  color: _primary,
                                  size: 16),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                faq['question']!,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _dark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      body: Padding(
                        padding: const EdgeInsets.fromLTRB(60, 0, 16, 16),
                        child: Text(
                          faq['answer']!,
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: _gray,
                              height: 1.6),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

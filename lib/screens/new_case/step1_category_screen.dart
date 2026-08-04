import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/new_case_data.dart';
import 'step2_details_screen.dart';
import '../placeholders.dart';

class Step1CategoryScreen extends StatelessWidget {
  const Step1CategoryScreen({super.key});

  static const Color _primary = Color(0xFF5C3FD3);

  static const List<Map<String, dynamic>> _categories = [
    {
      'name': 'Property / Land',
      'description': 'Land, house and\nproperty disputes',
      'icon': Icons.home_outlined,
      'iconColor': Color(0xFF5C3FD3),
      'iconBg': Color(0xFFEEE9FB),
    },
    {
      'name': 'Family',
      'description': 'Family and domestic\nmatters',
      'icon': Icons.people_outline_rounded,
      'iconColor': Color(0xFFE6A817),
      'iconBg': Color(0xFFFFF5E0),
    },
    {
      'name': 'Criminal',
      'description': 'FIR, bail and criminal\ncases',
      'icon': Icons.balance_outlined,
      'iconColor': Color(0xFFE05252),
      'iconBg': Color(0xFFFFECEC),
    },
    {
      'name': 'Employment',
      'description': 'Job and workplace\nrelated issues',
      'icon': Icons.work_outline_rounded,
      'iconColor': Color(0xFF2EAD6E),
      'iconBg': Color(0xFFE5F7EF),
    },
    {
      'name': 'Consumer Rights',
      'description': 'Products and service\nrelated complaints',
      'icon': Icons.shopping_cart_outlined,
      'iconColor': Color(0xFF3A82C4),
      'iconBg': Color(0xFFE3F0FB),
    },
    {
      'name': 'Civil',
      'description': 'General civil disputes',
      'icon': Icons.description_outlined,
      'iconColor': Color(0xFF7C5FD3),
      'iconBg': Color(0xFFEFEBFB),
    },
    {
      'name': 'Constitutional',
      'description': 'Fundamental rights',
      'icon': Icons.gavel_rounded,
      'iconColor': Color(0xFF2EAD6E),
      'iconBg': Color(0xFFE5F7EF),
    },
    {
      'name': 'Other',
      'description': 'Not listed above',
      'icon': Icons.more_horiz_rounded,
      'iconColor': Color(0xFFE6A817),
      'iconBg': Color(0xFFFFF5E0),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1A1A2E)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'New Case',
          style: GoogleFonts.poppins(
            color: const Color(0xFF1A1A2E),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded, color: Color(0xFF1A1A2E)),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Text(
              'Select Case Category',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Choose the area related to your legal problem',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF8E8E93),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.10,
                  ),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    return _CategoryCard(
                      name: cat['name'] as String,
                      description: cat['description'] as String,
                      icon: cat['icon'] as IconData,
                      iconColor: cat['iconColor'] as Color,
                      iconBg: cat['iconBg'] as Color,
                      onTap: () {
                        final data = NewCaseData(
                          category: cat['name'] as String,
                          categoryIcon: (cat['name'] as String).toLowerCase().replaceAll(' ', '_').replaceAll('/', '_'),
                          categoryDescription: cat['description'] as String,
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => Step2DetailsScreen(caseData: data),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            // AI Assist nudge
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0ECFD),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: _primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.lightbulb_outline_rounded,
                          color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Not sure which category to choose?',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1A1A2E),
                            ),
                          ),
                          Text(
                            'You can use our AI Assistant for guidance.',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: const Color(0xFF8E8E93),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PlaceholderScreen(title: 'AI Assistant'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.smart_toy_outlined, size: 14),
                      label: Text(
                        'Ask AI',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _primary,
                        side: const BorderSide(color: _primary),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String name;
  final String description;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.name,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const Spacer(),
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    color: const Color(0xFF8E8E93),
                    height: 1.4,
                  ),
                ),
              ],
            ),
            const Positioned(
              top: 0,
              right: 0,
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Color(0xFFAAAAAA),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

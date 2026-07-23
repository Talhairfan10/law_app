import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingPage3 extends StatelessWidget {
  final ValueNotifier<int> currentPageNotifier;

  const OnboardingPage3({super.key, required this.currentPageNotifier});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top Section (Logo, Phone Image, Text) ──
                  Expanded(
                    flex: 48,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Phone Mockup Image on the right
                        Positioned(
                          right: -screenWidth * 0.05,
                          top: 0,
                          bottom: -20,
                          child: SizedBox(
                            width: screenWidth * 0.65,
                            child: Image.asset(
                              'assets/images/phone_mockup.png',
                              fit: BoxFit.contain,
                              alignment: Alignment.topRight,
                              // Using errorBuilder in case they haven't added it yet
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Add\nphone_mockup.png\nto assets/images',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                            ),
                          ),
                        ),

                        // Left side content
                        Positioned(
                          left: 24,
                          top: 10,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Logo
                              SizedBox(
                                width: 100,
                                height: 100,
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Title
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Your Case.\nOur ',
                                      style: GoogleFonts.playfairDisplay(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF101018),
                                        height: 1.25,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Responsibility.',
                                      style: GoogleFonts.playfairDisplay(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFFD4A843),
                                        height: 1.25,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Description
                              Text(
                                'From case intake to resolution,\nwe manage everything with\ncare, transparency and\nexpertise.',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF4A4A5A),
                                  height: 1.6,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Purple Line
                              Container(
                                width: 40,
                                height: 3,
                                color: const Color(0xFF2E1C60),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  Spacer(flex: 2),

                  // ── Why Choose Banner ──
                  _buildWhyChooseBanner(),

                  Spacer(flex: 2),
                ],
              ),
            ),

            // ── Bottom Section ──
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  // ── Why Choose Banner ──
  Widget _buildWhyChooseBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1140),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              'Why Choose Mashvira Law House?',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Container(width: 30, height: 2, color: const Color(0xFFD4A843)),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWhyChooseItem(
                  icon: Icons.shield_outlined,
                  innerIcon: Icons.check,
                  title: 'Trusted Network',
                  desc: 'Pre-vetted lawyers\nand legal experts',
                ),
                _buildDivider(),
                _buildWhyChooseItem(
                  icon: Icons.shield_outlined,
                  innerIcon: Icons.lock_outline,
                  title: 'Secure & Private',
                  desc: 'Your information\nis always protected',
                ),
                _buildDivider(),
                _buildWhyChooseItem(
                  icon: Icons.access_time,
                  title: 'Transparent Process',
                  desc: 'Real-time updates\nat every step',
                ),
                _buildDivider(),
                _buildWhyChooseItem(
                  icon: Icons.workspace_premium_outlined,
                  innerIcon: Icons.star,
                  title: 'Better Outcomes',
                  desc: 'We work for the\njustice you deserve',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 45,
      margin: const EdgeInsets.only(top: 10),
      color: Colors.white.withValues(alpha: 0.15),
    );
  }

  Widget _buildWhyChooseItem({
    required IconData icon,
    IconData? innerIcon,
    required String title,
    required String desc,
  }) {
    return Expanded(
      child: Column(
        children: [
          SizedBox(
            width: 38,
            height: 38,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(icon, color: const Color(0xFFD4A843), size: 34),
                if (innerIcon != null)
                  Icon(innerIcon, color: const Color(0xFF907BEB), size: 14),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 8,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.7),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom Section (Buttons + Dots + Footer) ──
  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Get Started Button
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF2E1C60),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {},
                child: Row(
                  children: [
                    const SizedBox(width: 56), // balance
                    Expanded(
                      child: Text(
                        'Get Started',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Color(0xFF2E1C60),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Login Button
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2E1C60), width: 1),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 24),
                    Text(
                      'Login',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2E1C60),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Color(0xFF2E1C60),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Dot Indicator
          ValueListenableBuilder<int>(
            valueListenable: currentPageNotifier,
            builder: (context, currentPage, _) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  final isActive = index == currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive
                          ? const Color(0xFF2E1C60)
                          : const Color(0xFF2E1C60).withValues(alpha: 0.2),
                    ),
                  );
                }),
              );
            },
          ),

          const SizedBox(height: 16),

          // Footer Security Banner
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 28,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B2A70),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.lock, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 12),
              RichText(
                text: TextSpan(
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF6A6A7A),
                    height: 1.4,
                  ),
                  children: [
                    const TextSpan(text: 'Secure. Reliable. Confidential.\n'),
                    TextSpan(
                      text: 'Your legal journey is in safe hands.',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFF4A4A5A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/mashvira_logo.dart';
import 'create_account_screen.dart';

class OnboardingPage2 extends StatelessWidget {
  final ValueNotifier<int> currentPageNotifier;

  const OnboardingPage2({super.key, required this.currentPageNotifier});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(
        0xFFF5F4F8,
      ), // Slightly darker so white cards pop
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top Section (Title + Description + Hero Image via Stack) ──
                  Expanded(
                    flex: 42,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Background Image / Hero Image with seamless blend
                        Positioned(
                          right: -screenWidth * 0.15,
                          top: 0,
                          bottom: 0,
                          child: SizedBox(
                            width: screenWidth * 0.75,
                            child: ShaderMask(
                              shaderCallback: (rect) {
                                return const LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.center,
                                  colors: [Colors.transparent, Colors.white],
                                  stops: [0.0, 0.5],
                                ).createShader(rect);
                              },
                              blendMode: BlendMode.dstIn,
                              child: Image.asset(
                                'assets/images/page2_hero.png',
                                fit: BoxFit.cover,
                                alignment: Alignment.centerLeft,
                              ),
                            ),
                          ),
                        ),

                        // Text Content
                        Positioned(
                          left: 24,
                          top: screenHeight * 0.04,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Legal Support\nMade ',
                                      style: GoogleFonts.playfairDisplay(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF101018),
                                        height: 1.25,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Simple,\n',
                                      style: GoogleFonts.playfairDisplay(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFFD4A843),
                                        height: 1.25,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Justice Made Easy.',
                                      style: GoogleFonts.playfairDisplay(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF101018),
                                        height: 1.25,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Gold Line
                              Container(
                                width: 35,
                                height: 2.5,
                                color: const Color(0xFFD4A843),
                              ),
                              const SizedBox(height: 24),
                              // Description
                              Text(
                                'Describe your legal issue,\nwe handle the rest.\n\nQualified lawyers.\nTransparent process.\nBetter outcomes.',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF4A4A5A),
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 1),

                  // ── Feature Cards ──
                  _buildFeatureCards(),

                  const Spacer(flex: 2),

                  // ── Purple Mashvira Banner ──
                  _buildMashviraBanner(),

                  const Spacer(flex: 2),
                ],
              ),
            ),

            // ── Bottom Section ──
            _buildBottomSection(context),
          ],
        ),
      ),
    );
  }

  // ── Feature Cards Row ──
  Widget _buildFeatureCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCard(
            mainIcon: Icons.chat_bubble,
            subIcon: Icons.chat_bubble,
            title: 'Smart Intake',
            desc: 'Answer simple\nquestions about\nyour issue',
          ),
          _buildCard(
            mainIcon: Icons.shield,
            subIcon: Icons.check_circle,
            title: 'Expert Review',
            desc: 'Our QA team\nreviews and\nverifies your case',
          ),
          _buildCard(
            mainIcon: Icons.person,
            subIcon: Icons.star,
            title: 'Best Match',
            desc: 'We assign the most\nsuitable lawyer for\nyour case',
          ),
          _buildCard(
            mainIcon: Icons.library_books,
            subIcon: Icons.lock,
            title: 'Secure & Private',
            desc: 'Your information\nand case details\nare protected',
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required IconData mainIcon,
    required IconData subIcon,
    required String title,
    required String desc,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            SizedBox(
              width: 36,
              height: 36,
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Icon(
                      mainIcon,
                      color: const Color(0xFF3B2A70),
                      size: 28,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(1),
                      child: Icon(
                        subIcon,
                        color: const Color(0xFFD4A843),
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF3B2A70),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              desc,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 8.5,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF6A6A7A),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Purple Mashvira Banner ──
  Widget _buildMashviraBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF2E1C60),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Mashvira logo
            const SizedBox(
              width: 90,
              height: 90,
              child: MashviraLogo(size: 80, showText: false),
            ),
            const SizedBox(width: 16),
            // Vertical Divider
            Container(
              width: 1.5,
              height: 60,
              color: Colors.white.withValues(alpha: 0.15),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'We are here to help\nyou get the ',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        height: 1.4,
                      ),
                    ),
                    TextSpan(
                      text: 'justice',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFD4A843),
                        height: 1.4,
                      ),
                    ),
                    TextSpan(
                      text: '\nyou deserve.',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        height: 1.4,
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

  // ── Bottom Section (Dots + Buttons + Footer) ──
  Widget _buildBottomSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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

          const SizedBox(height: 20),

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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateAccountScreen(),
                    ),
                  );
                },
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
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Login coming soon.')),
                  );
                },
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

          // Footer
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xFF6A6A7A),
              ),
              children: [
                const TextSpan(text: 'By continuing, you agree to our '),
                TextSpan(
                  text: 'Terms & Conditions',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2E1C60),
                  ),
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2E1C60),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

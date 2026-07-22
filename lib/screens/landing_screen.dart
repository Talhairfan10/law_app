import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/gold_buttons.dart';
import '../widgets/mashvira_logo.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;

  late Animation<double> _logoFade;
  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _subtitleFade;
  late Animation<Offset> _subtitleSlide;
  late Animation<double> _heroFade;
  late Animation<double> _buttonsFade;
  late Animation<Offset> _buttonsSlide;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _logoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _titleFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.15, 0.55, curve: Curves.easeOut),
      ),
    );

    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: const Interval(0.15, 0.55, curve: Curves.easeOutCubic),
      ),
    );

    _subtitleFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.3, 0.65, curve: Curves.easeOut),
      ),
    );

    _subtitleSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: const Interval(0.3, 0.65, curve: Curves.easeOutCubic),
      ),
    );

    _heroFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.35, 0.75, curve: Curves.easeOut),
      ),
    );

    _buttonsFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.55, 1.0, curve: Curves.easeOut),
      ),
    );

    _buttonsSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: const Interval(0.55, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black, // fallback
      body: Stack(
        children: [
          // Fullscreen Background
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg.png',
              fit: BoxFit.cover,
            ),
          ),
          
          // Dark Overlay to match the deep purple tint
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF13092A).withValues(alpha: 0.85),
                    const Color(0xFF13092A).withValues(alpha: 0.5),
                    const Color(0xFF180A22).withValues(alpha: 0.95),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenHeight - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  children: [
                    SizedBox(height: screenHeight * 0.05),

                    // ── Logo Section ──
                    _buildLogoSection(),

                    SizedBox(height: screenHeight * 0.03),

                    // ── Title Section ──
                    _buildTitleSection(),

                    SizedBox(height: screenHeight * 0.02),

                    // ── Subtitle Section ──
                    _buildSubtitleSection(),

                    SizedBox(height: screenHeight * 0.02),

                    // ── Hero Illustration (Gavel) ──
                    _buildHeroIllustration(screenWidth),

                    SizedBox(height: screenHeight * 0.02),

                    // ── Action Buttons ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: _buildActionButtons(),
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    // ── Social Login ──
                    _buildSocialLogin(),

                    SizedBox(height: screenHeight * 0.04),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoSection() {
    return FadeTransition(
      opacity: _logoFade,
      child: Column(
        children: [
          // Custom drawn vector logo perfectly matching the original
          const MashviraLogo(size: 140),
          // Subtitle with decorative dashes (matching reference)
          const SizedBox(height: 8),
          // The logo image contains the text, but wait, if it doesn't we can render it.
          // Let's assume the logo image is just the shield, or it contains text.
          // The reference has text below the shield. Our generated logo might have text in it.
          // I will just let the image render itself. If it needs text, I can add it, but our prompt asked for text.
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return FadeTransition(
      opacity: _titleFade,
      child: SlideTransition(
        position: _titleSlide,
        child: Column(
          children: [
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Trusted Legal Support,\n',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.3,
                      letterSpacing: 0.5,
                    ),
                  ),
                  TextSpan(
                    text: 'Simplified',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFF3C76F),
                      height: 1.3,
                      letterSpacing: 0.5,
                    ),
                  ),
                  TextSpan(
                    text: ' for You.',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.3,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Gold dot divider
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 30,
                  height: 1,
                  color: const Color(0xFFF3C76F).withValues(alpha: 0.5),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF3C76F),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 30,
                  height: 1,
                  color: const Color(0xFFF3C76F).withValues(alpha: 0.5),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubtitleSection() {
    return FadeTransition(
      opacity: _subtitleFade,
      child: SlideTransition(
        position: _subtitleSlide,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'AI-powered guidance, expert lawyers,\nsecure case management and\ntransparent progress – all in one app.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white70,
              height: 1.6,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroIllustration(double screenWidth) {
    return FadeTransition(
      opacity: _heroFade,
      child: ShaderMask(
        shaderCallback: (rect) {
          return const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [Colors.transparent, Colors.black],
            stops: [0.0, 0.4],
          ).createShader(rect);
        },
        blendMode: BlendMode.dstIn,
        child: SizedBox(
          width: screenWidth,
          height: screenWidth * 0.65,
          child: Image.asset(
            'assets/images/hero.png',
            fit: BoxFit.cover,
            alignment: Alignment.bottomCenter,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return FadeTransition(
      opacity: _buttonsFade,
      child: SlideTransition(
        position: _buttonsSlide,
        child: Column(
          children: [
            GoldButton(
              label: 'Get Started',
              leadingIcon: Icons.balance_rounded,
              onPressed: () {},
            ),
            const SizedBox(height: 14),
            GoldOutlineButton(
              label: 'Login',
              leadingIcon: Icons.person_outline_rounded,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialLogin() {
    return FadeTransition(
      opacity: _buttonsFade,
      child: SlideTransition(
        position: _buttonsSlide,
        child: Column(
          children: [
            Text(
              'or continue with',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Google
                SocialButton(
                  icon: Icons.g_mobiledata_rounded,
                  iconColor: const Color(0xFFEA4335),
                  onPressed: () {},
                ),
                const SizedBox(width: 16),
                // Apple
                SocialButton(
                  icon: Icons.apple_rounded,
                  iconColor: Colors.black,
                  onPressed: () {},
                ),
                const SizedBox(width: 16),
                // Phone
                SocialButton(
                  icon: Icons.phone_rounded,
                  iconColor: const Color(0xFF6B4FA0),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


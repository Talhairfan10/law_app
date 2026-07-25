import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_colors.dart';
import '../widgets/mashvira_logo.dart';
import '../widgets/sign_up_option_button.dart';
import '../services/auth_service.dart';
import 'signup_form_screen.dart';
import 'complete_profile_screen.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;

  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _cardFade;
  late Animation<Offset> _cardSlide;
  late Animation<double> _featuresFade;
  late Animation<double> _footerFade;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );

    _headerFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
      ),
    );
    _headerSlide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _slideController,
            curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic),
          ),
        );

    _cardFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.2, 0.65, curve: Curves.easeOut),
      ),
    );
    _cardSlide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _slideController,
            curve: const Interval(0.2, 0.65, curve: Curves.easeOutCubic),
          ),
        );

    _featuresFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.55, 0.9, curve: Curves.easeOut),
      ),
    );

    _footerFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
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
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0B1E), // Dark purple base
      body: Stack(
        children: [
          // ── 1. Background image ──
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_gavel.png',
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
            ),
          ),

          // ── 2. Hero image (books + gavel) positioned upper right ──
          Positioned(
            right: 0,
            top: topPadding,
            child: Opacity(
              opacity: 0.85,
              child: ShaderMask(
                shaderCallback: (rect) {
                  return const LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [Colors.white, Colors.white, Colors.transparent],
                    stops: [0.0, 0.6, 1.0],
                  ).createShader(rect);
                },
                blendMode: BlendMode.dstIn,
                child: ShaderMask(
                  shaderCallback: (rect) {
                    return const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white, Colors.white, Colors.transparent],
                      stops: [0.0, 0.5, 1.0],
                    ).createShader(rect);
                  },
                  blendMode: BlendMode.dstIn,
                  child: SizedBox(
                    width: screenWidth * 0.7,
                    height: screenHeight * 0.35,
                    child: Image.asset(
                      'assets/images/bg_gavel.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.centerRight,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── 3. Dark purple overlay gradient (matches reference) ──
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF13092A).withValues(alpha: 0.7),
                    const Color(0xFF110825).withValues(alpha: 0.85),
                    const Color(0xFF0C0717).withValues(alpha: 0.98),
                  ],
                  stops: const [0.0, 0.35, 1.0],
                ),
              ),
            ),
          ),

          // ── 4. Main content ──
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Back button ──
                Padding(
                  padding: EdgeInsets.only(left: 20, top: screenHeight * 0.01),
                  child: _buildBackButton(),
                ),

                SizedBox(height: screenHeight * 0.02),

                // ── Header: Title + Shield logo ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: FadeTransition(
                    opacity: _headerFade,
                    child: SlideTransition(
                      position: _headerSlide,
                      child: _buildHeaderSection(screenWidth, screenHeight),
                    ),
                  ),
                ),

                SizedBox(
                  height: screenHeight * 0.02,
                ), // Reduced spacing to avoid overflow
                // ── Bottom card container ──
                Expanded(
                  child: FadeTransition(
                    opacity: _cardFade,
                    child: SlideTransition(
                      position: _cardSlide,
                      child: _buildBottomCard(screenHeight),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Back Button ──
  Widget _buildBackButton() {
    return IconButton(
      onPressed: () => Navigator.of(context).pop(),
      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 28),
      style: IconButton.styleFrom(
        backgroundColor: AppColors.backgroundLight.withValues(alpha: 0.25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.all(12),
      ),
    );
  }

  // ── Header Section (Title on left + Shield on right) ──
  Widget _buildHeaderSection(double screenWidth, double screenHeight) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: Title + dots + subtitle
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // "Create Your"
              Text(
                'Create Your',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
                  height: 1.2,
                ),
              ),
              // "Account" in gold
              Text(
                'Account',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 44,
                  fontWeight: FontWeight.w800,
                  color: AppColors.goldPrimary,
                  letterSpacing: 0.5,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 16),
              // Original Divider: longer gold line, centered gold dot, second gold line
              Row(
                children: [
                  Container(width: 45, height: 2, color: AppColors.goldPrimary),
                  const SizedBox(width: 8),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.purpleLight,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Welcome subtitle
              Text(
                'Welcome to Mashvira Law House',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.4,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Create an account to access trusted legal\nsupport, manage your cases and more.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.white70,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),

        // Right: Shield logo, moved to upper-right, scaled up
        Expanded(
          flex: 4,
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: MashviraLogo(size: screenHeight * 0.16, showText: false),
            ),
          ),
        ),
      ],
    );
  }

  // ── Bottom Card Container ──
  Widget _buildBottomCard(double screenHeight) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF130E26),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      SizedBox(height: screenHeight * 0.015),

                      // "Create account using" divider
                      _buildDividerLabel('Create account using'),

                      SizedBox(height: screenHeight * 0.01),

                      // Sign-up option buttons
                      _buildSignUpOptions(screenHeight),

                      SizedBox(height: screenHeight * 0.01),

                      // "or" divider with lines
                      _buildOrDivider(),

                      SizedBox(height: screenHeight * 0.01),

                      // Email button
                      SignUpOptionButton(
                        icon: Icons.mail_outline_rounded,
                        iconColor: AppColors.goldPrimary,
                        iconBackgroundColor: Colors.transparent,
                        iconBorderColor: AppColors.goldPrimary.withValues(
                          alpha: 0.5,
                        ),
                        label: 'Create Account with Email',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignupFormScreen(),
                            ),
                          );
                        },
                      ),

                      SizedBox(height: screenHeight * 0.02),

                      // Feature strip
                      FadeTransition(
                        opacity: _featuresFade,
                        child: _buildFeatureStrip(),
                      ),

                      SizedBox(height: screenHeight * 0.01),

                      // Footer: "Already have an account? Login"
                      FadeTransition(
                        opacity: _footerFade,
                        child: _buildFooter(),
                      ),

                      SizedBox(height: screenHeight * 0.015),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Divider with label (used for "Create account using") ──
  Widget _buildDividerLabel(String text) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.textMuted,
              letterSpacing: 0.2,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
      ],
    );
  }

  // ── "or" divider with lines on both sides ──
  Widget _buildOrDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'or',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textMuted,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
      ],
    );
  }

  // ── Sign-up option buttons (Google, Apple, Phone) ──
  Widget _buildSignUpOptions(double screenHeight) {
    return Column(
      children: [
        SignUpOptionButton(
          customIcon: Image.asset(
            'assets/images/google_logo.png',
            width: 24,
            height: 24,
          ),
          iconBackgroundColor: Colors.white,
          label: 'Continue with Google',
          onPressed: () async {
            try {
              final user = await AuthService.signInWithGoogle();
              if (user == null) {
                // User cancelled
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Google sign-in was cancelled.')),
                  );
                }
                return;
              }
              // Success — navigate directly to Complete Profile (skip Step 1 & 2)
              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CompleteProfileScreen(
                      fullName: user.displayName ?? '',
                      email: user.email ?? '',
                      phoneNumber: '',
                      isGoogleSignIn: true,
                    ),
                  ),
                );
              }
            } on FirebaseAuthException catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AuthService.getFirebaseAuthErrorMessage(e))),
                );
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Google sign-in failed: ${e.toString()}')),
                );
              }
            }
          },
        ),
        SizedBox(height: screenHeight * 0.01),
        SignUpOptionButton(
          icon: Icons.apple_rounded,
          iconColor: Colors.white,
          iconBackgroundColor: const Color(0xFF322A45),
          label: 'Continue with Apple',
          iconSize: 26,
          onPressed: () {
            // TODO: Apple sign-in
          },
        ),
        SizedBox(height: screenHeight * 0.01),
        SignUpOptionButton(
          icon: Icons.phone_rounded,
          iconColor: AppColors.purpleLight,
          iconBackgroundColor: const Color(0xFF322A45),
          label: 'Continue with Phone Number',
          iconSize: 24,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SignupFormScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  // ── Feature strip (4 circular icons with separators) ──
  Widget _buildFeatureStrip() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FeatureChip(
          icon: Icons.verified_user_outlined,
          label: 'Secure &\nPrivate',
        ),
        _buildFeatureSeparator(),
        const FeatureChip(
          icon: Icons.upload_file_rounded,
          label: 'Upload Legal\nDocuments',
        ),
        _buildFeatureSeparator(),
        const FeatureChip(
          icon: Icons.forum_outlined,
          label: 'AI Legal\nGuidance',
        ),
        _buildFeatureSeparator(),
        const FeatureChip(
          icon: Icons.people_outline_rounded,
          label: 'Verified\nLawyers',
        ),
      ],
    );
  }

  Widget _buildFeatureSeparator() {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Container(
        width: 1,
        height: 35,
        color: Colors.white.withValues(alpha: 0.1),
      ),
    );
  }

  // ── Footer: "Already have an account? Login >" ──
  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account?  ',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.textMuted,
          ),
        ),
        GestureDetector(
          onTap: () {
            // TODO: Navigate to login
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Login',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.goldPrimary,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.goldPrimary,
                size: 18,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

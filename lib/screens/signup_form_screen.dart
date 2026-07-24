import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../widgets/mashvira_logo.dart';
import 'verify_phone_screen.dart';

class SignupFormScreen extends StatefulWidget {
  const SignupFormScreen({super.key});

  @override
  State<SignupFormScreen> createState() => _SignupFormScreenState();
}

class _SignupFormScreenState extends State<SignupFormScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = true;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0B1E),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_gavel.png',
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
            ),
          ),
          
          // Dark Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF13092A).withValues(alpha: 0.8),
                    const Color(0xFF110825).withValues(alpha: 0.9),
                    const Color(0xFF0C0717).withValues(alpha: 1.0),
                  ],
                  stops: const [0.0, 0.35, 1.0],
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Nav
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        Expanded(child: _buildProgressIndicator()),
                      ],
                    ),
                  ),

                  // Hero Section
                  Padding(
                    padding: const EdgeInsets.only(left: 28, right: 10, top: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),
                              Text(
                                'Create Your',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  height: 1.2,
                                ),
                              ),
                              Text(
                                'Account',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.goldPrimary,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Container(width: 40, height: 2, color: AppColors.goldPrimary),
                                  const SizedBox(width: 6),
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: AppColors.goldPrimary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(width: 40, height: 2, color: AppColors.goldPrimary),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Fill in your details to create your\nMashvira Law House account.',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textMuted,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Align(
                            alignment: Alignment.topRight,
                            child: MashviraLogo(size: screenHeight * 0.18, showText: false),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Form Fields
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        _buildInputField(
                          controller: _nameController,
                          label: 'Full Name',
                          hint: 'Enter your full name',
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 16),
                        _buildInputField(
                          controller: _emailController,
                          label: 'Email Address',
                          hint: 'Enter your email address',
                          icon: Icons.mail_outline,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        _buildPhoneInputField(),
                        const SizedBox(height: 16),
                        _buildInputField(
                          label: 'Password',
                          hint: 'Create a strong password',
                          icon: Icons.lock_outline,
                          isPassword: true,
                          obscureText: _obscurePassword,
                          onToggleObscure: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildInputField(
                          label: 'Confirm Password',
                          hint: 'Confirm your password',
                          icon: Icons.lock_outline,
                          isPassword: true,
                          obscureText: _obscureConfirmPassword,
                          onToggleObscure: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Checkbox
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _agreedToTerms = !_agreedToTerms;
                            });
                          },
                          child: Container(
                            width: 20,
                            height: 20,
                            margin: const EdgeInsets.only(top: 2, right: 12),
                            decoration: BoxDecoration(
                              color: _agreedToTerms ? AppColors.goldPrimary : Colors.transparent,
                              border: Border.all(
                                color: AppColors.goldPrimary,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: _agreedToTerms
                                ? const Icon(Icons.check, size: 16, color: Colors.black)
                                : null,
                          ),
                        ),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.textMuted,
                                height: 1.5,
                              ),
                              children: const [
                                TextSpan(text: 'I agree to the '),
                                TextSpan(
                                  text: 'Terms of Service',
                                  style: TextStyle(color: AppColors.goldPrimary, fontWeight: FontWeight.w600),
                                ),
                                TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: TextStyle(color: AppColors.goldPrimary, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Continue Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: AppColors.goldButtonGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          final phone = _phoneController.text.trim();
                          final name = _nameController.text.trim();
                          final email = _emailController.text.trim();
                          
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VerifyPhoneScreen(
                                phoneNumber: '+92 ${phone.isEmpty ? "312 3456789" : phone}',
                                fullName: name.isEmpty ? "Ali Hassan" : name,
                                email: email.isEmpty ? "alihassan@gmail.com" : email,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Spacer(),
                            Text(
                              'Continue',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.arrow_forward, color: Colors.black, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Divider
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'or continue with',
                            style: GoogleFonts.inter(
                              fontSize: 13,
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
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Social Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Expanded(child: _buildSocialButton('Google', 'assets/images/google_logo.png')),
                        const SizedBox(width: 12),
                        Expanded(child: _buildSocialButton('Apple', Icons.apple)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildSocialButton('Phone', Icons.phone, iconColor: AppColors.purpleLight)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Login Text
                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textMuted,
                        ),
                        children: const [
                          TextSpan(text: 'Already have an account? '),
                          TextSpan(
                            text: 'Login',
                            style: TextStyle(
                              color: AppColors.goldPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStep(1, 'Account Info', true),
        Container(
          width: 30,
          height: 1,
          color: AppColors.goldPrimary,
        ),
        _buildStep(2, 'Verify', false),
        Container(
          width: 30,
          height: 1,
          color: Colors.white.withValues(alpha: 0.2),
        ),
        _buildStep(3, 'Complete', false),
      ],
    );
  }

  Widget _buildStep(int step, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isActive ? AppColors.goldPrimary : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? AppColors.goldPrimary : Colors.white.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            step.toString(),
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.black : Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            color: isActive ? AppColors.goldPrimary : Colors.white.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    TextEditingController? controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool? obscureText,
    VoidCallback? onToggleObscure,
    TextInputType? keyboardType,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1530).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.goldPrimary.withValues(alpha: 0.8), size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: controller,
                  obscureText: obscureText ?? false,
                  keyboardType: keyboardType,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textMuted.withValues(alpha: 0.6),
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                  ),
                ),
              ],
            ),
          ),
          if (isPassword)
            GestureDetector(
              onTap: onToggleObscure,
              child: Icon(
                obscureText == true ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: AppColors.textMuted,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPhoneInputField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1530).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.phone_outlined, color: AppColors.goldPrimary.withValues(alpha: 0.8), size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Phone Number',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    // Fake Country Picker
                    Container(
                      padding: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: const Center(
                              child: Icon(Icons.star, color: Colors.white, size: 8),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '+92',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted, size: 16),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter your phone number',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.textMuted.withValues(alpha: 0.6),
                          ),
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(String label, dynamic iconOrPath, {Color? iconColor}) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (iconOrPath is String)
            Image.asset(iconOrPath, width: 20, height: 20)
          else if (iconOrPath is IconData)
            Icon(iconOrPath, color: iconColor ?? Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

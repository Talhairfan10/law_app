import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import 'complete_profile_screen.dart';

class VerifyPhoneScreen extends StatefulWidget {
  final String phoneNumber;
  final String fullName;
  final String email;

  const VerifyPhoneScreen({
    super.key,
    required this.phoneNumber,
    required this.fullName,
    required this.email,
  });

  @override
  State<VerifyPhoneScreen> createState() => _VerifyPhoneScreenState();
}

class _VerifyPhoneScreenState extends State<VerifyPhoneScreen> {
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  
  Timer? _timer;
  int _secondsRemaining = 180; // 3:00

  @override
  void initState() {
    super.initState();
    _startTimer();
    
    // Auto focus first node
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNodes[0]);
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  String get _formattedTime {
    int minutes = _secondsRemaining ~/ 60;
    int seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onOtpChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    } else if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }
    setState(() {}); // Trigger rebuild to update border highlight
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0B1E),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg.png',
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Text(
                          'Verify Your',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                        Text(
                          'Phone Number',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: AppColors.goldPrimary,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(width: 30, height: 2, color: AppColors.goldPrimary),
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
                            Container(width: 30, height: 2, color: AppColors.goldPrimary),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'We have sent a 6-digit verification code to your phone number',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textMuted,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.phoneNumber,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.goldPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Enter the code below to continue.',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // OTP Input Section
                  Center(
                    child: Text(
                      'Enter 6-digit code',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) => _buildOtpBox(index)),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Countdown timer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.access_time_rounded, color: AppColors.goldPrimary, size: 16),
                      const SizedBox(width: 8),
                      RichText(
                        text: TextSpan(
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.textMuted,
                          ),
                          children: [
                            const TextSpan(text: 'Code expires in '),
                            TextSpan(
                              text: _formattedTime,
                              style: const TextStyle(
                                color: AppColors.goldPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Info Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1530).withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.05),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Resend Row
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF2A1F40),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 20),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Didn\'t receive the code?',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Resend code',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _secondsRemaining == 0 ? () {
                                    setState(() {
                                      _secondsRemaining = 180;
                                      _startTimer();
                                    });
                                  } : null,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: _secondsRemaining == 0 
                                          ? AppColors.goldPrimary.withValues(alpha: 0.2) 
                                          : const Color(0xFF2A1F40),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Resend',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: _secondsRemaining == 0 
                                            ? AppColors.goldPrimary 
                                            : AppColors.textMuted,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 1,
                            color: Colors.white.withValues(alpha: 0.05),
                          ),
                          // Edit Phone Row
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF2A1F40),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.edit_outlined, color: Colors.white, size: 20),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Wrong phone number?',
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Edit phone number',
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: AppColors.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 24),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Verify & Continue Button
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
                          // Validate 6 digits
                          String otp = _otpControllers.map((c) => c.text).join();
                          if (otp.length == 6) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CompleteProfileScreen(
                                  phoneNumber: widget.phoneNumber,
                                  fullName: widget.fullName,
                                  email: widget.email,
                                ),
                              ),
                            );
                          } else {
                            // Show error/shake (omitted complex shake for simplicity, just a snackbar for now)
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter all 6 digits')),
                            );
                          }
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
                              'Verify & Continue',
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
                  
                  const SizedBox(height: 24),
                  
                  // Trust Row Bottom
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.verified_user_outlined, color: AppColors.goldPrimary, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Your information is secure and\nencrypted end-to-end.',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textMuted,
                              height: 1.4,
                            ),
                          ),
                        ),
                        // Watermark mock
                        Opacity(
                          opacity: 0.2,
                          child: Icon(Icons.account_balance, color: Colors.white, size: 40),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
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
        _buildStep(1, 'Account Info', true, isCompleted: true),
        Container(
          width: 30,
          height: 1,
          color: AppColors.goldPrimary,
        ),
        _buildStep(2, 'Verify', true, isCompleted: false),
        Container(
          width: 30,
          height: 1,
          color: Colors.white.withValues(alpha: 0.2),
        ),
        _buildStep(3, 'Complete', false, isCompleted: false),
      ],
    );
  }

  Widget _buildStep(int step, String label, bool isActive, {bool isCompleted = false}) {
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
          child: isCompleted 
              ? const Icon(Icons.check, size: 14, color: Colors.black)
              : Text(
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

  Widget _buildOtpBox(int index) {
    bool hasFocus = _focusNodes[index].hasFocus;
    bool hasText = _otpControllers[index].text.isNotEmpty;
    
    return Container(
      width: 48,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1530).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasFocus ? AppColors.goldPrimary : Colors.white.withValues(alpha: 0.1),
          width: hasFocus ? 1.5 : 1.0,
        ),
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: hasText ? AppColors.goldPrimary : Colors.white,
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
        onChanged: (value) => _onOtpChanged(value, index),
      ),
    );
  }
}

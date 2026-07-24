import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class CompleteProfileScreen extends StatefulWidget {
  final String fullName;
  final String email;
  final String phoneNumber;

  const CompleteProfileScreen({
    super.key,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
  });

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  String? _selectedRole; // 'client' or 'lawyer'
  String _selectedLanguage = 'English';
  String? _selectedSource;
  final TextEditingController _otherSourceController = TextEditingController();

  @override
  void dispose() {
    _otherSourceController.dispose();
    super.dispose();
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
              'assets/images/step3_hero.png',
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
                          'Complete Your',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                        Text(
                          'Profile',
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
                          'Help us personalize your experience\nand serve you better.',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textMuted,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Summary Cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        _buildSummaryCard(
                          label: 'Full Name',
                          value: widget.fullName,
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 12),
                        _buildSummaryCard(
                          label: 'Email Address',
                          value: widget.email,
                          icon: Icons.mail_outline,
                        ),
                        const SizedBox(height: 12),
                        _buildSummaryCard(
                          label: 'Phone Number',
                          value: widget.phoneNumber,
                          icon: Icons.phone_outlined,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // I am a
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'I am a',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildRoleCard(
                                role: 'client',
                                title: 'Client',
                                subtext: 'I need legal support',
                                icon: Icons.person_outline,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildRoleCard(
                                role: 'lawyer',
                                title: 'Lawyer',
                                subtext: 'I am a legal professional',
                                icon: Icons.business_center_outlined,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Preferred Language
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Preferred Language',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildDropdownCard(
                          icon: Icons.language,
                          value: _selectedLanguage,
                          onTap: _showLanguagePicker,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // How did you hear about us?
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'How did you hear about us?',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildDropdownCard(
                          icon: Icons.campaign_outlined,
                          value: _selectedSource ?? 'Select an option (Optional)',
                          isPlaceholder: _selectedSource == null,
                          onTap: _showSourcePicker,
                        ),
                        if (_selectedSource == 'Other') ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1530).withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                                width: 1,
                              ),
                            ),
                            child: TextField(
                              controller: _otherSourceController,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Please specify...',
                                hintStyle: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: AppColors.textMuted,
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Trust row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF1E1530),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.security, color: AppColors.textMuted, size: 16),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Your information is secure and will never be shared\nwith any third party.',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textMuted,
                              height: 1.4,
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
                          if (_selectedRole == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please select if you are a Client or a Lawyer')),
                            );
                            return;
                          }
                          // Proceed to dashboard / complete flow
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Registration Complete!')),
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

                  // Bottom indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildDot(false),
                      const SizedBox(width: 8),
                      _buildDot(false),
                      const SizedBox(width: 8),
                      _buildDot(true),
                    ],
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
        _buildStep(1, 'Account Info', true, isCompleted: true),
        Container(width: 30, height: 1, color: AppColors.goldPrimary),
        _buildStep(2, 'Verify', true, isCompleted: true),
        Container(width: 30, height: 1, color: AppColors.goldPrimary),
        _buildStep(3, 'Complete', true, isCompleted: false),
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

  Widget _buildSummaryCard({required String label, required String value, required IconData icon}) {
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
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard({
    required String role,
    required String title,
    required String subtext,
    required IconData icon,
  }) {
    bool isSelected = _selectedRole == role;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1530).withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.goldPrimary : Colors.white.withValues(alpha: 0.05),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: isSelected ? AppColors.goldPrimary : AppColors.textMuted, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  subtext,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            if (isSelected)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: AppColors.goldPrimary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.black, size: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownCard({
    required IconData icon,
    required String value,
    bool isPlaceholder = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
            Icon(icon, color: AppColors.goldPrimary.withValues(alpha: 0.8), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: isPlaceholder ? FontWeight.w400 : FontWeight.w500,
                  color: isPlaceholder ? AppColors.textMuted : Colors.white,
                ),
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted.withValues(alpha: 0.8), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(bool isActive) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.goldPrimary : const Color(0xFF1E1530),
        shape: BoxShape.circle,
      ),
    );
  }

  void _showLanguagePicker() {
    final options = ['English', 'اردو (Urdu)'];
    _showPickerBottomSheet('Preferred Language', options, _selectedLanguage, (val) {
      setState(() => _selectedLanguage = val);
    });
  }

  void _showSourcePicker() {
    final options = [
      'Social Media',
      'Friend or Family Referral',
      'Google Search',
      'Other'
    ];
    _showPickerBottomSheet('How did you hear about us?', options, _selectedSource, (val) {
      setState(() => _selectedSource = val);
    });
  }

  void _showPickerBottomSheet(String title, List<String> options, String? currentValue, Function(String) onSelect) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: const BoxDecoration(
            color: Color(0xFF13092A),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              ...options.map((option) {
                bool isSelected = option == currentValue;
                return ListTile(
                  title: Text(
                    option,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? AppColors.goldPrimary : Colors.white,
                    ),
                  ),
                  trailing: isSelected 
                      ? const Icon(Icons.check, color: AppColors.goldPrimary)
                      : null,
                  onTap: () {
                    onSelect(option);
                    Navigator.pop(context);
                  },
                );
              }),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

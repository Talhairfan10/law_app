import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/new_case_data.dart';
import 'widgets/step_progress_indicator.dart';
import 'widgets/nav_buttons.dart';
import 'step5_review_screen.dart';
import '../../widgets/app_dropdown.dart';

class Step4LawyerScreen extends StatefulWidget {
  final NewCaseData caseData;

  const Step4LawyerScreen({super.key, required this.caseData});

  @override
  State<Step4LawyerScreen> createState() => _Step4LawyerScreenState();
}

class _Step4LawyerScreenState extends State<Step4LawyerScreen> {
  static const Color _primary = Color(0xFF5C3FD3);

  static const List<String> _budgetOptions = [
    '5,000',
    '10,000',
    '15,000',
    '20,000',
    '25,000+',
  ];

  late String _budgetMin;
  late String _budgetMax;
  late String _selectedLevel;

  @override
  void initState() {
    super.initState();
    _budgetMin = widget.caseData.budgetMin;
    _budgetMax = widget.caseData.budgetMax;
    _selectedLevel = widget.caseData.lawyerLevel;
  }

  void _validate() {
    widget.caseData.budgetMin = _budgetMin;
    widget.caseData.budgetMax = _budgetMax;
    widget.caseData.lawyerLevel = _selectedLevel;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Step5ReviewScreen(caseData: widget.caseData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          const StepProgressIndicator(currentStep: 4),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStepHeader(),
                  const SizedBox(height: 16),
                  _buildHowItWorksCard(),
                  const SizedBox(height: 20),
                  _buildBudgetSection(),
                  const SizedBox(height: 20),
                  _buildLawyerLevelSection(),
                  const SizedBox(height: 16),
                  _buildImportantNote(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          NewCaseNavButtons(
            onBack: () => Navigator.pop(context),
            onContinue: _validate,
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1A1A2E)),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        children: [
          Text(
            'New Case',
            style: GoogleFonts.poppins(
              color: const Color(0xFF1A1A2E),
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          Text(
            'Select your preferred lawyer type',
            style: GoogleFonts.poppins(
              color: const Color(0xFF8E8E93),
              fontSize: 11,
            ),
          ),
        ],
      ),
      centerTitle: true,
    );
  }

  Widget _buildStepHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step 4 of 5',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Choose Lawyer Level',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Our company will assign the most suitable lawyer\nto your case based on availability and expertise.',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: const Color(0xFF8E8E93),
          ),
        ),
      ],
    );
  }

  Widget _buildHowItWorksCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0ECFD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: _primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.info_outline_rounded,
                color: _primary, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How it works?',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'You select your preferred lawyer level and budget range.\nOur team will review and assign the best available lawyer.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF555555),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'What is your budget range?',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              const TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red, fontSize: 15),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildBudgetDropdown('Minimum Price (PKR)', _budgetMin, (val) {
              setState(() => _budgetMin = val!);
            })),
            const SizedBox(width: 12),
            Expanded(child: _buildBudgetDropdown('Maximum Price (PKR)', _budgetMax, (val) {
              setState(() => _budgetMax = val!);
            })),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.shield_outlined, size: 14, color: Color(0xFF8E8E93)),
            const SizedBox(width: 6),
            Text(
              'This helps us assign a lawyer within your budget.',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: const Color(0xFF8E8E93),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBudgetDropdown(
      String label, String value, void Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: const Color(0xFF8E8E93),
            ),
          ),
          AppDropdown(
            value: value,
            hint: 'Select',
            items: _budgetOptions,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildLawyerLevelSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Lawyer Level',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Compare lawyer levels and their service charges',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: const Color(0xFF8E8E93),
          ),
        ),
        const SizedBox(height: 12),
        _LawyerCard(
          level: 'recommended',
          selected: _selectedLevel == 'recommended',
          icon: Icons.workspace_premium_rounded,
          iconColor: const Color(0xFF5C3FD3),
          iconBg: const Color(0xFFEEE9FB),
          title: 'Recommended',
          badge: 'Most Popular',
          priceRange: 'PKR 7,500 – 12,000',
          description: 'Experienced and reliable lawyers\nbest for most cases.',
          tags: const ['Good Experience', 'High Success Rate', 'Timely Updates'],
          tagIcons: const [Icons.shield_outlined, Icons.trending_up_rounded, Icons.schedule_rounded],
          onTap: () => setState(() => _selectedLevel = 'recommended'),
        ),
        const SizedBox(height: 12),
        _LawyerCard(
          level: 'senior',
          selected: _selectedLevel == 'senior',
          icon: Icons.military_tech_rounded,
          iconColor: const Color(0xFFE6A817),
          iconBg: const Color(0xFFFFF5E0),
          title: 'Senior',
          badge: null,
          priceRange: 'PKR 12,000 – 20,000',
          description: 'Highly experienced lawyers\nwith proven record.',
          tags: const ['5+ Years Experience', 'High Success Rate', 'Case Strategy'],
          tagIcons: const [Icons.star_border_rounded, Icons.trending_up_rounded, Icons.psychology_outlined],
          onTap: () => setState(() => _selectedLevel = 'senior'),
        ),
        const SizedBox(height: 12),
        _LawyerCard(
          level: 'most_senior',
          selected: _selectedLevel == 'most_senior',
          icon: Icons.emoji_events_rounded,
          iconColor: const Color(0xFFE05252),
          iconBg: const Color(0xFFFFECEC),
          title: 'Most Senior',
          badge: null,
          priceRange: 'PKR 20,000 – 35,000+',
          description: 'Top level lawyers with 10+ years\nof exceptional experience.',
          tags: const ['10+ Years Experience', 'Highest Success Rate', 'Priority Handling'],
          tagIcons: const [Icons.star_rounded, Icons.verified_rounded, Icons.bolt_rounded],
          onTap: () => setState(() => _selectedLevel = 'most_senior'),
        ),
      ],
    );
  }

  Widget _buildImportantNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5E0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFFE6A817).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.info_outline_rounded,
                color: Color(0xFFE6A817), size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Important',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Our team will carefully review your case and assign the most suitable lawyer from the selected level.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF555555),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Lawyer Card Widget ───────────────────────────────────────────────────────

class _LawyerCard extends StatelessWidget {
  final String level;
  final bool selected;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String? badge;
  final String priceRange;
  final String description;
  final List<String> tags;
  final List<IconData> tagIcons;
  final VoidCallback onTap;

  const _LawyerCard({
    required this.level,
    required this.selected,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.badge,
    required this.priceRange,
    required this.description,
    required this.tags,
    required this.tagIcons,
    required this.onTap,
  });

  static const Color _primary = Color(0xFF5C3FD3);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? _primary : const Color(0xFFEEEEEE),
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selection circle
            GestureDetector(
              onTap: onTap,
              child: Container(
                width: 22,
                height: 22,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? _primary : const Color(0xFFCCCCCC),
                    width: 2,
                  ),
                  color: selected ? _primary : Colors.transparent,
                ),
                child: selected
                    ? const Icon(Icons.circle, color: Colors.white, size: 10)
                    : null,
              ),
            ),
            const SizedBox(width: 10),
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1A1A2E),
                            ),
                          ),
                          if (badge != null) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                badge!,
                                style: GoogleFonts.poppins(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            priceRange,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1A1A2E),
                            ),
                          ),
                          Text(
                            'Service Charges',
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              color: const Color(0xFF8E8E93),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: const Color(0xFF8E8E93),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: List.generate(tags.length, (i) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(tagIcons[i],
                              size: 12, color: const Color(0xFF8E8E93)),
                          const SizedBox(width: 3),
                          Text(
                            tags[i],
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: const Color(0xFF555555),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

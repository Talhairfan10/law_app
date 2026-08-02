import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../models/new_case_data.dart';
import 'widgets/step_progress_indicator.dart';
import 'widgets/nav_buttons.dart';
import '../home_dashboard_screen.dart';
import 'step1_category_screen.dart' as step1;

class Step5ReviewScreen extends StatefulWidget {
  final NewCaseData caseData;

  const Step5ReviewScreen({super.key, required this.caseData});

  @override
  State<Step5ReviewScreen> createState() => _Step5ReviewScreenState();
}

class _Step5ReviewScreenState extends State<Step5ReviewScreen> {
  static const Color _primary = Color(0xFF5C3FD3);

  bool _confirmed = false;
  bool _isSubmitting = false;

  String _lawyerLevelLabel(String level) {
    switch (level) {
      case 'senior':
        return 'Senior';
      case 'most_senior':
        return 'Most Senior';
      default:
        return 'Recommended';
    }
  }

  Future<void> _submitCase() async {
    if (!_confirmed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please confirm that the information is correct.',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('Not authenticated');

      final data = widget.caseData;

      await FirebaseFirestore.instance.collection('cases').add({
        'userId': uid,
        'category': data.category,
        'subCategory': data.subCategory,
        'shortDescription': data.shortDescription,
        'issueDate': data.issueDate?.toIso8601String(),
        'location': data.location,
        'additionalInfo': data.additionalInfo,
        'documentUrls': data.uploadedFiles
            .map((f) => {
                  'name': f.name,
                  'url': f.downloadUrl,
                  'size': f.sizeLabel,
                })
            .toList(),
        'budgetMin': data.budgetMin,
        'budgetMax': data.budgetMax,
        'lawyerLevel': data.lawyerLevel,
        'status': 'pending_assignment',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        setState(() => _isSubmitting = false);
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to submit case. Please try again.',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Color(0xFFEEE9FB),
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.check_circle_rounded, color: _primary, size: 44),
              ),
              const SizedBox(height: 20),
              Text(
                'Case Submitted!',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Our team will review your case and assign the most suitable lawyer soon. You will be notified once your case is assigned.',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFF8E8E93),
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (_) => const HomeDashboardScreen()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: Text(
                    'Back to Home',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.caseData;
    final uploadedCount = data.uploadedFiles.length;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          const StepProgressIndicator(currentStep: 5),
          Expanded(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStepHeader(),
                  const SizedBox(height: 16),

                  // Case Category card
                  _buildSummaryCard(
                    icon: Icons.grid_view_rounded,
                    topLabel: 'Case Category',
                    mainText: data.subCategory.isNotEmpty
                        ? data.subCategory
                        : data.category,
                    subText: data.category,
                    onEdit: () => _editStep1(context),
                  ),
                  const SizedBox(height: 10),

                  // Case Details card
                  _buildSummaryCard(
                    icon: Icons.description_outlined,
                    topLabel: 'Case Details',
                    mainText: 'Short Description',
                    subText: data.shortDescription.length > 80
                        ? '${data.shortDescription.substring(0, 80)}...'
                        : data.shortDescription,
                    onEdit: () => _editStep2(context),
                  ),
                  const SizedBox(height: 10),

                  if (data.additionalInfo.isNotEmpty) ...[
                    _buildSummaryCard(
                      icon: Icons.info_outline_rounded,
                      topLabel: 'Additional Information',
                      mainText: data.additionalInfo.length > 80
                          ? '${data.additionalInfo.substring(0, 80)}...'
                          : data.additionalInfo,
                      subText: null,
                      onEdit: () => _editStep2(context),
                    ),
                    const SizedBox(height: 10),
                  ],

                  // Issue date card
                  _buildSummaryCard(
                    icon: Icons.calendar_today_outlined,
                    topLabel: 'Issue Occurred On',
                    mainText: data.issueDate != null
                        ? DateFormat('d MMM yyyy').format(data.issueDate!)
                        : '—',
                    subText: null,
                    onEdit: () => _editStep2(context),
                  ),
                  const SizedBox(height: 10),

                  // Location card
                  _buildSummaryCard(
                    icon: Icons.location_on_outlined,
                    topLabel: 'Location',
                    mainText: data.location.isNotEmpty ? data.location : '—',
                    subText: null,
                    onEdit: () => _editStep2(context),
                  ),
                  const SizedBox(height: 16),

                  // Uploaded Documents
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Uploaded Documents ($uploadedCount)',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
                      if (uploadedCount > 0)
                        Text(
                          'View All →',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _primary,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (uploadedCount > 0)
                    ...data.uploadedFiles.take(3).map((f) => _DocRow(file: f))
                  else
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Text(
                        'No documents uploaded',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: const Color(0xFF8E8E93),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Lawyer Level card
                  _buildSummaryCard(
                    icon: Icons.people_outline_rounded,
                    topLabel: 'Selected Lawyer Level',
                    mainText: _lawyerLevelLabel(data.lawyerLevel),
                    subText:
                        'Budget Range: PKR ${data.budgetMin} – ${data.budgetMax}',
                    onEdit: () => _editStep4(context),
                    badge: data.lawyerLevel == 'recommended'
                        ? 'Most Popular'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // What happens next card
                  _buildWhatHappensNext(),
                  const SizedBox(height: 16),

                  // Confirmation checkbox
                  GestureDetector(
                    onTap: () => setState(() => _confirmed = !_confirmed),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: _confirmed,
                          onChanged: (val) =>
                              setState(() => _confirmed = val ?? false),
                          activeColor: _primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
                        ),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      'I confirm that the above information is correct.',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: const Color(0xFF1A1A2E),
                                  ),
                                ),
                                const TextSpan(
                                  text: ' *',
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          NewCaseNavButtons(
            onBack: () => Navigator.pop(context),
            onContinue: _submitCase,
            continueLabel: 'Submit Case',
            isLoading: _isSubmitting,
          ),
        ],
      ),
    );
  }

  void _editStep2(BuildContext context) {
    Navigator.pop(context); // back to step 4
    Navigator.pop(context); // back to step 3
    Navigator.pop(context); // back to step 2
  }

  void _editStep1(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const step1.Step1CategoryScreen()), // requires import
    );
  }

  void _editStep4(BuildContext context) {
    Navigator.pop(context); // back to step 4
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
            'Review your case details before submission',
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
          'Step 5 of 5',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Review & Submit',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Please review your case details. You can go back and edit if needed.',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: const Color(0xFF8E8E93),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String topLabel,
    required String mainText,
    required String? subText,
    required VoidCallback onEdit,
    String? badge,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF0ECFD),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topLabel,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: const Color(0xFF8E8E93),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      mainText,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
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
                          badge,
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
                if (subText != null && subText.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subText,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF8E8E93),
                    ),
                  ),
                ],
              ],
            ),
          ),
          TextButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 13),
            label: Text(
              'Edit',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: TextButton.styleFrom(
              foregroundColor: _primary,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatHappensNext() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5C3FD3), Color(0xFF7B61E3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.security, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What happens next?',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Our team will review your case and assign the most suitable lawyer. You will be notified once your case is assigned.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.85),
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

// ─── Document row in review ───────────────────────────────────────────────────

class _DocRow extends StatelessWidget {
  final UploadedFileData file;
  const _DocRow({required this.file});

  Color _fileColor(String ext) {
    switch (ext) {
      case 'pdf':
        return Colors.red;
      case 'jpg':
      case 'jpeg':
        return Colors.green;
      case 'png':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _fileColor(file.extension);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                file.extension.toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A2E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  file.sizeLabel,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: const Color(0xFF8E8E93),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // Preview: open URL if available
              if (file.downloadUrl.isNotEmpty) {
                // Could use url_launcher; for now just a placeholder
              }
            },
            icon: const Icon(Icons.remove_red_eye_outlined,
                color: Color(0xFF8E8E93), size: 20),
          ),
        ],
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import '../../services/cloudinary_service.dart';
import '../../models/new_case_data.dart';
import 'widgets/step_progress_indicator.dart';
import 'widgets/nav_buttons.dart';
import 'step4_lawyer_screen.dart';
import '../placeholders.dart';
import 'step1_category_screen.dart';

class Step3DocumentsScreen extends StatefulWidget {
  final NewCaseData caseData;

  const Step3DocumentsScreen({super.key, required this.caseData});

  @override
  State<Step3DocumentsScreen> createState() => _Step3DocumentsScreenState();
}

class _Step3DocumentsScreenState extends State<Step3DocumentsScreen> {
  static const Color _primary = Color(0xFF5C3FD3);
  bool _isUploading = false;

  List<Map<String, String>> get _recommendedDocs =>
      kCategoryDocuments[widget.caseData.category] ?? kCategoryDocuments['Other']!;

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result == null) return;

    // Limit to 10 total
    final remaining = 10 - widget.caseData.uploadedFiles.length;
    final filesToAdd = result.files.take(remaining).toList();

    if (filesToAdd.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Maximum 10 documents allowed.',
                style: GoogleFonts.poppins()),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
      return;
    }

    setState(() => _isUploading = true);

    bool hasUploadFailed = false;

    for (final file in filesToAdd) {
      if (file.path == null) continue;
      final sizeLabel = _formatFileSize(file.size);
      final ext = (file.extension ?? 'file').toLowerCase();

      String downloadUrl = '';
      bool success = false;
      try {
        final uid = FirebaseAuth.instance.currentUser?.uid ?? 'anon';
        
        /* --- FIREBASE STORAGE UPLOAD (Commented out due to Spark plan limits) ---
        final ts = DateTime.now().millisecondsSinceEpoch;
        final ref = FirebaseStorage.instance
            .ref('case_documents/$uid/${ts}_${file.name}');
        await ref.putFile(File(file.path!));
        downloadUrl = await ref.getDownloadURL();
        */

        // --- CLOUDINARY UPLOAD ---
        final response = await CloudinaryService.uploadFile(
          File(file.path!),
          folder: 'case_documents/$uid',
        );

        if (response != null && response.containsKey('secure_url')) {
          downloadUrl = response['secure_url'] as String;
          success = true;
        } else {
          success = false;
        }
      } catch (e, stackTrace) {
        debugPrint('DEBUG UPLOAD ERROR (Client side): $e');
        debugPrint('StackTrace: $stackTrace');
        // Storage not configured or failed due to quota
        hasUploadFailed = true;
        success = false;
      }

      if (success && mounted) {
        setState(() {
          widget.caseData.uploadedFiles.add(UploadedFileData(
            name: file.name,
            sizeLabel: sizeLabel,
            extension: ext,
            localPath: file.path!,
            downloadUrl: downloadUrl,
          ));
        });
      }
    }

    if (mounted) {
      setState(() => _isUploading = false);
      if (hasUploadFailed) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Document upload isn\'t available yet — you can still submit your case, and we\'ll follow up separately for documents.',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _removeFile(int index) {
    setState(() => widget.caseData.uploadedFiles.removeAt(index));
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final uploadedCount = widget.caseData.uploadedFiles.length;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          const StepProgressIndicator(currentStep: 3),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStepHeader(),
                  const SizedBox(height: 16),
                  _buildCaseTypeSummaryCard(context),
                  const SizedBox(height: 16),
                  _buildRecommendedDocuments(),
                  const SizedBox(height: 16),
                  _buildDropZone(),
                  const SizedBox(height: 16),
                  _buildUploadedList(uploadedCount),
                  const SizedBox(height: 16),
                  _buildNeedHelpCard(context),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          NewCaseNavButtons(
            onBack: () => Navigator.pop(context),
            onContinue: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Step4LawyerScreen(caseData: widget.caseData),
                ),
              );
            },
            isLoading: _isUploading,
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
            'Upload documents related to your case',
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
          'Step 3 of 5',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Upload Documents',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Upload any documents related to your case.\nMore documents help us assign the right lawyer faster.',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: const Color(0xFF8E8E93),
          ),
        ),
      ],
    );
  }

  Widget _buildCaseTypeSummaryCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0ECFD),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: _primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.home_outlined,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected Case Type',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: const Color(0xFF8E8E93),
                  ),
                ),
                Text(
                  widget.caseData.subCategory.isNotEmpty
                      ? widget.caseData.subCategory
                      : widget.caseData.category,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                Text(
                  widget.caseData.categoryDescription.replaceAll('\n', ', '),
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: const Color(0xFF8E8E93),
                  ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () {
              // Pop back to the home/root and start fresh at Step 1
              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const Step1CategoryScreen(),
                ),
              );
            },
            icon: const Icon(Icons.edit_outlined, size: 14),
            label: Text(
              'Change',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: TextButton.styleFrom(foregroundColor: _primary),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedDocuments() {
    final subTitle = widget.caseData.subCategory.isNotEmpty
        ? widget.caseData.subCategory
        : widget.caseData.category;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Recommended Documents for $subTitle',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
              ),
              const Icon(Icons.info_outline_rounded,
                  size: 16, color: Color(0xFF8E8E93)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Upload any of the following documents (at least one)',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: const Color(0xFF8E8E93),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 16,
            alignment: WrapAlignment.start,
            children: _recommendedDocs.map((doc) {
              return SizedBox(
                width: 70,
                child: _DocChip(
                  iconKey: doc['icon'] ?? 'document',
                  label: doc['label'] ?? '',
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  size: 14, color: Color(0xFF8E8E93)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Don\'t worry if you don\'t have all documents. You can upload later.',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: const Color(0xFF8E8E93),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropZone() {
    return GestureDetector(
      onTap: _isUploading ? null : _pickFiles,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF5C3FD3).withValues(alpha: 0.4),
            width: 1.5,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            if (_isUploading)
              const CircularProgressIndicator(color: _primary)
            else
              const Icon(Icons.cloud_upload_outlined,
                  size: 48, color: _primary),
            const SizedBox(height: 12),
            Text(
              _isUploading ? 'Uploading...' : 'Tap to upload or drag and drop',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'PDF, JPG, PNG up to 10MB each',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFF8E8E93),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadedList(int uploadedCount) {
    if (uploadedCount == 0) return const SizedBox.shrink();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Uploaded Documents ($uploadedCount/10)',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A2E),
              ),
            ),
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
        ...widget.caseData.uploadedFiles.asMap().entries.map((entry) {
          final index = entry.key;
          final file = entry.value;
          return _UploadedFileRow(
            file: file,
            onDelete: () => _removeFile(index),
          );
        }),
      ],
    );
  }

  Widget _buildNeedHelpCard(BuildContext context) {
    return Container(
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
            child: const Icon(Icons.security, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need Help?',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                Text(
                  'Not sure which documents to upload? Our AI Assistant can guide you.',
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
                    builder: (_) =>
                        const PlaceholderScreen(title: 'AI Assistant')),
              );
            },
            icon: const Icon(Icons.smart_toy_outlined, size: 14),
            label: Text(
              'Ask AI Assistant',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: _primary,
              side: const BorderSide(color: _primary),
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

class _DocChip extends StatelessWidget {
  final String iconKey;
  final String label;

  const _DocChip({required this.iconKey, required this.label});

  static const Color _primary = Color(0xFF5C3FD3);

  IconData _iconForKey(String key) {
    switch (key) {
      case 'id_card':
        return Icons.credit_card_outlined;
      case 'document':
      case 'fir':
      case 'bail':
        return Icons.description_outlined;
      case 'map':
        return Icons.map_outlined;
      case 'receipt':
        return Icons.receipt_long_outlined;
      case 'bill':
        return Icons.receipt_outlined;
      case 'plan':
        return Icons.architecture_outlined;
      case 'photo':
        return Icons.photo_camera_outlined;
      case 'certificate':
        return Icons.workspace_premium_outlined;
      case 'child':
        return Icons.child_care_outlined;
      case 'family':
        return Icons.family_restroom_outlined;
      case 'court':
        return Icons.gavel_rounded;
      case 'bank':
        return Icons.account_balance_outlined;
      case 'contract':
        return Icons.handshake_outlined;
      case 'salary':
        return Icons.payments_outlined;
      case 'letter':
        return Icons.mail_outline_rounded;
      case 'email':
        return Icons.email_outlined;
      case 'medical':
        return Icons.local_hospital_outlined;
      case 'evidence':
        return Icons.search_outlined;
      case 'police':
        return Icons.local_police_outlined;
      case 'product':
        return Icons.inventory_2_outlined;
      case 'complaint':
        return Icons.report_problem_outlined;
      case 'witness':
        return Icons.people_outline_rounded;
      case 'news':
        return Icons.newspaper_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFF0ECFD),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFDDD6F8)),
          ),
          child: Icon(_iconForKey(iconKey), color: _primary, size: 22),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 9.5,
            color: const Color(0xFF555555),
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

class _UploadedFileRow extends StatelessWidget {
  final UploadedFileData file;
  final VoidCallback onDelete;

  const _UploadedFileRow({required this.file, required this.onDelete});

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
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded,
                color: Color(0xFF8E8E93), size: 20),
          ),
        ],
      ),
    );
  }
}

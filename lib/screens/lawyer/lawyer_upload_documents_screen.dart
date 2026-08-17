import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/case_service.dart';
import '../../models/case_model.dart';
import '../../widgets/app_dropdown.dart';

/// Lawyer document management screen — view uploaded documents,
/// upload new ones via file picker, and push to Firebase Storage.
class LawyerUploadDocumentsScreen extends StatefulWidget {
  final String caseDocId;

  const LawyerUploadDocumentsScreen({super.key, required this.caseDocId});

  @override
  State<LawyerUploadDocumentsScreen> createState() =>
      _LawyerUploadDocumentsScreenState();
}

class _LawyerUploadDocumentsScreenState
    extends State<LawyerUploadDocumentsScreen> {
  static const Color _navyDark = Color(0xFF0A1628);
  static const Color _gold = Color(0xFFD4A843);
  static const Color _white = Colors.white;
  static const Color _textMuted = Color(0xFF8E99A4);
  static const Color _greenAccent = Color(0xFF2EAD6E);
  static const Color _blueAccent = Color(0xFF3A82C4);
  static const Color _redAccent = Color(0xFFE05252);

  bool _isUploading = false;
  String _selectedDocType = 'General';

  final List<String> _documentTypes = [
    'General',
    'Court Order',
    'Evidence',
    'Affidavit',
    'Legal Brief',
    'Witness Statement',
    'Contract',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: StreamBuilder<CaseModel?>(
                stream: CaseService.getCaseStream(widget.caseDocId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(strokeWidth: 2));
                  }
                  final caseData = snapshot.data;
                  if (caseData == null) {
                    return const Center(child: Text('Case not found'));
                  }

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCaseHeader(caseData),
                        const SizedBox(height: 20),
                        _buildUploadSection(),
                        const SizedBox(height: 24),
                        _buildDocumentsList(caseData),
                        const SizedBox(height: 30),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── App Bar ──
  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back, color: _navyDark, size: 20),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Case Documents',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _navyDark,
                ),
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  // ── Case Header ──
  Widget _buildCaseHeader(CaseModel c) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_navyDark, Color(0xFF0F1D32)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: c.categoryIconBg.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(c.categoryIcon,
                  color: c.categoryIconColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.categoryDisplayName,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _white,
                    ),
                  ),
                  Text(
                    'Case ID: ${c.caseId}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: _white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _gold.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${c.documentCount} docs',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _gold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Upload Section ──
  Widget _buildUploadSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
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
                const Icon(Icons.cloud_upload_outlined,
                    size: 20, color: _navyDark),
                const SizedBox(width: 8),
                Text(
                  'Upload New Document',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _navyDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Document type dropdown
            AppDropdown(
              value: _selectedDocType,
              hint: 'Select Document Type',
              items: _documentTypes,
              onChanged: (val) {
                if (val != null) setState(() => _selectedDocType = val);
              },
            ),
            const SizedBox(height: 14),

            // Upload area
            GestureDetector(
              onTap: _isUploading ? null : _pickAndUploadFiles,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28),
                decoration: BoxDecoration(
                  color: _blueAccent.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _blueAccent.withValues(alpha: 0.3),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: [
                    if (_isUploading) ...[
                      const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: _blueAccent,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Uploading...',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: _blueAccent,
                        ),
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _blueAccent.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add_rounded,
                            color: _blueAccent, size: 24),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Tap to select files',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _blueAccent,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'PDF, JPG, PNG • Max 10 MB each',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: _textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Pick and upload files ──
  Future<void> _pickAndUploadFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
    );
    if (result == null || result.files.isEmpty) return;

    setState(() => _isUploading = true);

    final user = FirebaseAuth.instance.currentUser;
    final uploaderName = user?.displayName ?? 'Lawyer';
    int successCount = 0;
    int failCount = 0;

    for (final file in result.files) {
      if (file.path == null) continue;

      final ext = (file.extension ?? 'file').toLowerCase();
      final sizeLabel = _formatFileSize(file.size);

      final url = await CaseService.uploadCaseDocument(
        widget.caseDocId,
        file: File(file.path!),
        fileName: file.name,
        fileExtension: ext,
        fileSize: sizeLabel,
        uploadedBy: uploaderName,
        documentType: _selectedDocType,
      );

      if (url != null) {
        successCount++;
      } else {
        failCount++;
      }
    }

    if (mounted) {
      setState(() => _isUploading = false);

      if (successCount > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$successCount document${successCount > 1 ? 's' : ''} uploaded successfully',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: _greenAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      }

      if (failCount > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$failCount document${failCount > 1 ? 's' : ''} failed to upload',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: _redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  // ── Documents List (Full Combined List: Client + Lawyer) ──
  Widget _buildDocumentsList(CaseModel caseData) {
    final docs = caseData.documentUrls;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.folder_outlined, size: 18, color: _navyDark),
              const SizedBox(width: 8),
              Text(
                'All Case Documents',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _navyDark,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _blueAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${docs.length} ${docs.length == 1 ? 'file' : 'files'}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _blueAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (docs.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Icon(Icons.description_outlined,
                      size: 40,
                      color: Colors.grey.shade300),
                  const SizedBox(height: 10),
                  Text(
                    'No documents uploaded yet',
                    style:
                        GoogleFonts.poppins(fontSize: 13, color: _textMuted),
                  ),
                ],
              ),
            )
          else
            ...docs.asMap().entries.map((entry) {
              return _buildDocumentCard(entry.value, entry.key, caseData);
            }),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(
      Map<String, dynamic> doc, int index, CaseModel caseData) {
    final name = (doc['name'] ?? doc['title'] ?? doc['fileName'] ?? 'Document')
        .toString();
    final url = (doc['url'] ??
            doc['secure_url'] ??
            doc['downloadUrl'] ??
            doc['path'] ??
            '')
        .toString();
    final rawSize = doc['sizeLabel'] ?? doc['size'] ?? doc['fileSize'];
    String sizeStr = '';
    if (rawSize is num) {
      sizeStr = _formatFileSize(rawSize.toInt());
    } else if (rawSize != null) {
      sizeStr = rawSize.toString();
    }

    final docType =
        (doc['documentType'] ?? doc['type'] ?? 'General').toString();
    final uploadedBy = (doc['uploadedBy'] ?? 'Client').toString();
    final uploadedAt = (doc['uploadedAt'] ?? doc['date'] ?? doc['createdAt'] ?? '').toString();

    String ext = (doc['extension'] ?? '').toString().toLowerCase();
    if (ext.isEmpty && name.contains('.')) {
      ext = name.split('.').last.toLowerCase();
    }

    // Icon based on extension
    IconData fileIcon;
    Color fileColor;
    switch (ext) {
      case 'pdf':
        fileIcon = Icons.picture_as_pdf_rounded;
        fileColor = _redAccent;
        break;
      case 'jpg':
      case 'jpeg':
      case 'png':
        fileIcon = Icons.image_outlined;
        fileColor = _greenAccent;
        break;
      case 'doc':
      case 'docx':
        fileIcon = Icons.description_outlined;
        fileColor = _blueAccent;
        break;
      default:
        fileIcon = Icons.insert_drive_file_outlined;
        fileColor = _gold;
    }

    // Format date
    String dateLabel = '';
    if (uploadedAt.isNotEmpty) {
      final dt = DateTime.tryParse(uploadedAt);
      if (dt != null) {
        final months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        dateLabel = '${dt.day} ${months[dt.month - 1]} ${dt.year}';
      }
    }
    if (dateLabel.isEmpty) {
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      dateLabel = '${caseData.createdAt.day} ${months[caseData.createdAt.month - 1]} ${caseData.createdAt.year}';
    }

    return GestureDetector(
      onTap: () => _openDocument(url),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // File icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: fileColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(fileIcon, color: fileColor, size: 22),
            ),
            const SizedBox(width: 12),

            // File info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _navyDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        '${ext.isNotEmpty ? ext.toUpperCase() : 'FILE'}${sizeStr.isNotEmpty ? ' • $sizeStr' : ''}',
                        style: GoogleFonts.poppins(
                            fontSize: 11, color: _textMuted),
                      ),
                      if (docType != 'General' && docType.isNotEmpty) ...[
                        Text(' • ',
                            style: GoogleFonts.poppins(
                                fontSize: 11, color: _textMuted)),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: _blueAccent.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            docType,
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: _blueAccent,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    'Uploaded by $uploadedBy • $dateLabel',
                    style: GoogleFonts.poppins(
                        fontSize: 10, color: _textMuted),
                  ),
                ],
              ),
            ),

            // Action buttons
            if (url.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _blueAccent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.open_in_new_rounded,
                    size: 18, color: _blueAccent),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _openDocument(String url) async {
    final cleanUrl = url.trim();
    if (cleanUrl.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Document URL is empty or unavailable.',
                style: GoogleFonts.poppins()),
            backgroundColor: _redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }
    final uri = Uri.tryParse(cleanUrl);
    if (uri != null) {
      try {
        final launched =
            await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!launched && mounted) {
          await launchUrl(uri, mode: LaunchMode.platformDefault);
        }
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open document link.',
                  style: GoogleFonts.poppins()),
              backgroundColor: _redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid document URL format.',
                style: GoogleFonts.poppins()),
            backgroundColor: _redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/case_service.dart';
import '../../services/hearing_service.dart';
import '../../models/case_model.dart';
import 'lawyer_case_timeline_screen.dart';
import 'lawyer_upload_documents_screen.dart';

class LawyerCaseDetailsScreen extends StatefulWidget {
  final String caseDocId;

  const LawyerCaseDetailsScreen({super.key, required this.caseDocId});

  @override
  State<LawyerCaseDetailsScreen> createState() =>
      _LawyerCaseDetailsScreenState();
}

class _LawyerCaseDetailsScreenState extends State<LawyerCaseDetailsScreen> {
  static const Color _navyDark = Color(0xFF0A1628);
  static const Color _gold = Color(0xFFD4A843);
  static const Color _white = Colors.white;
  static const Color _textMuted = Color(0xFF8E99A4);
  static const Color _greenAccent = Color(0xFF2EAD6E);
  static const Color _blueAccent = Color(0xFF3A82C4);

  String? _clientName;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _fetchClientName(String userId) async {
    if (_clientName != null) return;
    if (userId.isEmpty) {
      if (mounted) setState(() => _clientName = 'Client');
      return;
    }

    try {
      debugPrint('[LawyerCaseDetailsScreen] Fetching client name for userId: $userId');
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (mounted) {
        if (doc.exists) {
          final data = doc.data() ?? {};
          final name = (data['fullName'] ?? data['name'] ?? data['displayName'] ?? data['email'] ?? 'Client').toString();
          debugPrint('[LawyerCaseDetailsScreen] Client name fetched: $name');
          setState(() {
            _clientName = name.isNotEmpty ? name : 'Client';
          });
        } else {
          debugPrint('[LawyerCaseDetailsScreen] User doc does not exist for userId: $userId');
          setState(() {
            _clientName = 'Client (${userId.length > 6 ? userId.substring(0, 6) : userId})';
          });
        }
      }
    } catch (e, stack) {
      debugPrint('[LawyerCaseDetailsScreen] Error fetching client name: $e');
      debugPrint('StackTrace: $stack');
      if (mounted) {
        setState(() {
          _clientName = 'Client';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: StreamBuilder<CaseModel?>(
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

          // Fetch client name once
          _fetchClientName(caseData.userId);

          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAppBar(context),
                  _buildInfoCard(caseData),
                  const SizedBox(height: 20),
                  _buildCaseInformation(caseData),
                  const SizedBox(height: 20),
                  _buildCaseDescription(caseData),
                  const SizedBox(height: 20),
                  _buildCaseDocumentsPreview(caseData),
                  const SizedBox(height: 16),
                  _buildNotes(caseData),
                  const SizedBox(height: 20),
                  _buildActivityPreview(caseData),
                  const SizedBox(height: 20),
                  _buildQuickActions(caseData),
                  const SizedBox(height: 20),
                  _buildBottomButtons(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
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
                'Case Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _navyDark,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              // More options menu placeholder
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.more_horiz, color: _navyDark, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  // ── Info Card Header ──
  Widget _buildInfoCard(CaseModel c) {
    final visuals = kCategoryVisuals[c.category];
    final iconData = (visuals?['icon'] as IconData?) ?? Icons.gavel_rounded;
    final iconColor = (visuals?['iconColor'] as Color?) ?? _gold;
    final iconBg = (visuals?['iconBg'] as Color?) ?? const Color(0xFFFFF5E0);

    // Status badge
    Color statusColor;
    Color statusBg;
    String statusText;
    switch (c.status) {
      case 'active':
      case 'in_progress':
      case 'lawyer_assigned':
        statusColor = _blueAccent;
        statusBg = _blueAccent.withValues(alpha: 0.2);
        statusText = 'In Progress';
        break;
      case 'completed':
        statusColor = _greenAccent;
        statusBg = _greenAccent.withValues(alpha: 0.2);
        statusText = 'Completed';
        break;
      default:
        statusColor = _gold;
        statusBg = _gold.withValues(alpha: 0.2);
        statusText = 'Pending';
    }

    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final assignedDate = '${c.createdAt.day.toString().padLeft(2, '0')} '
        '${months[c.createdAt.month - 1]} ${c.createdAt.year}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_navyDark, Color(0xFF0F1D32)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBg.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(iconData, color: iconColor, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.categoryDisplayName,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Case ID: ${c.caseId}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _white.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      statusText,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Assigned Date',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: _textMuted,
                  ),
                ),
                Text(
                  assignedDate,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _gold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Current Stage',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: _textMuted,
                  ),
                ),
                Text(
                  c.stageLabel,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _gold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Case Information Grid ──
  Widget _buildCaseInformation(CaseModel c) {
    final clientId = c.userId.length > 8
        ? 'CLT-${c.userId.substring(0, 4).toUpperCase()}'
        : c.userId;

    final formattedIssueDate = c.issueDate != null
        ? DateFormat('dd MMM yyyy').format(c.issueDate!)
        : 'Not specified';

    String levelLabel = 'Recommended';
    if (c.lawyerLevel.toLowerCase() == 'senior') {
      levelLabel = 'Senior Lawyer';
    } else if (c.lawyerLevel.toLowerCase() == 'most_senior') {
      levelLabel = 'Most Senior';
    } else if (c.lawyerLevel.isNotEmpty) {
      levelLabel = c.lawyerLevel[0].toUpperCase() + c.lawyerLevel.substring(1);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
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
                Container(width: 3, height: 20, color: _navyDark),
                const SizedBox(width: 10),
                Text(
                  'Case Information',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _navyDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Grid row 1: Client Name & Client ID
            Row(
              children: [
                Expanded(
                    child: _infoItem(Icons.person_outline, 'Client Name',
                        _clientName ?? 'Loading...')),
                Expanded(
                    child: _infoItem(
                        Icons.fingerprint_outlined, 'Client ID', clientId)),
              ],
            ),
            const SizedBox(height: 14),
            // Grid row 2: Category & Sub-Category
            Row(
              children: [
                Expanded(
                    child: _infoItem(Icons.folder_outlined, 'Category',
                        c.category.isNotEmpty ? c.category : 'General')),
                Expanded(
                    child: _infoItem(Icons.subdirectory_arrow_right_rounded,
                        'Sub-Category',
                        c.subCategory.isNotEmpty ? c.subCategory : 'None')),
              ],
            ),
            const SizedBox(height: 14),
            // Grid row 3: Issue Date & Location/Court
            Row(
              children: [
                Expanded(
                    child: _infoItem(Icons.event_outlined, 'Issue Date',
                        formattedIssueDate)),
                Expanded(
                    child: _infoItem(
                        Icons.location_on_outlined, 'Location / Court',
                        c.location.isNotEmpty ? c.location : 'Not specified')),
              ],
            ),
            const SizedBox(height: 14),
            // Grid row 4: Fee Budget & Lawyer Level
            Row(
              children: [
                Expanded(
                    child: _infoItem(Icons.attach_money_rounded, 'Fee Budget',
                        'PKR ${c.budgetMin} - ${c.budgetMax}')),
                Expanded(
                    child: _infoItem(Icons.workspace_premium_outlined,
                        'Req. Lawyer Level', levelLabel,
                        valueColor: _gold)),
              ],
            ),
            const SizedBox(height: 14),
            // Grid row 5: Next Hearing & Priority
            Row(
              children: [
                Expanded(
                  child: StreamBuilder<Map<String, dynamic>?>(
                    stream: HearingService.getNextHearingForCase(
                        widget.caseDocId),
                    builder: (context, snap) {
                      String hearingText = 'Not scheduled';
                      if (snap.data != null) {
                        final date = _parseDateTime(snap.data!['date']);
                        final time = snap.data!['time'] as String? ?? '';
                        if (date != null) {
                          hearingText =
                              '${DateFormat('dd MMM yyyy').format(date)}, $time';
                        }
                      }
                      return _infoItem(Icons.calendar_today_outlined,
                          'Next Hearing', hearingText);
                    },
                  ),
                ),
                Expanded(
                    child: _infoItem(Icons.flag_outlined, 'Priority', 'Medium',
                        valueColor: _gold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoItem(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: _textMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: _textMuted,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? _navyDark,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Case Description & Original Client Submission ──
  Widget _buildCaseDescription(CaseModel c) {
    final formattedIssueDate = c.issueDate != null
        ? DateFormat('dd MMM yyyy').format(c.issueDate!)
        : 'Not specified';

    final categoryStr = c.category.isNotEmpty ? c.category : 'General';
    final subCategoryStr = c.subCategory.isNotEmpty ? c.subCategory : 'None';
    final locationStr = c.location.isNotEmpty ? c.location : 'Not specified';
    final shortDescStr = c.shortDescription.isNotEmpty
        ? c.shortDescription
        : 'No short description provided.';
    final additionalInfoStr = c.additionalInfo.isNotEmpty
        ? c.additionalInfo
        : 'No additional information provided by client.';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
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
                const Icon(Icons.assignment_outlined,
                    size: 20, color: _navyDark),
                const SizedBox(width: 8),
                Text(
                  'Original Client Submission',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _navyDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Badges row for Category & Sub-Category
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _navyDark.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.folder_outlined,
                          size: 14, color: _navyDark),
                      const SizedBox(width: 4),
                      Text(
                        categoryStr,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _navyDark,
                        ),
                      ),
                    ],
                  ),
                ),
                if (subCategoryStr != 'None') ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _blueAccent.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.subdirectory_arrow_right_rounded,
                            size: 14, color: _blueAccent),
                        const SizedBox(width: 4),
                        Text(
                          subCategoryStr,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _blueAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 14),

            // Short Description / Case Title
            Text(
              'Case Title / Summary',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _textMuted,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              shortDescStr,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _navyDark,
              ),
            ),
            const SizedBox(height: 14),

            // Row for Issue Date & Location
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.event_outlined,
                          size: 16, color: _textMuted),
                      const SizedBox(width: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Issue Date',
                            style: GoogleFonts.poppins(
                                fontSize: 10, color: _textMuted),
                          ),
                          Text(
                            formattedIssueDate,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _navyDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 16, color: _textMuted),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Location / City',
                              style: GoogleFonts.poppins(
                                  fontSize: 10, color: _textMuted),
                            ),
                            Text(
                              locationStr,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _navyDark,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
            const Divider(height: 1, color: Color(0xFFF0F0F0)),
            const SizedBox(height: 12),

            // Additional Information / Client Details
            Text(
              'Additional Information / Case Details',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _textMuted,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFEFEFEF)),
              ),
              child: Text(
                additionalInfoStr,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFF4A5568),
                  height: 1.6,
                  fontStyle: c.additionalInfo.isEmpty
                      ? FontStyle.italic
                      : FontStyle.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Case Documents Preview ──
  Widget _buildCaseDocumentsPreview(CaseModel c) {
    final docs = c.documentUrls;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
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
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.folder_outlined,
                          size: 18, color: _navyDark),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Case Documents (${docs.length})',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: _navyDark,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LawyerUploadDocumentsScreen(
                            caseDocId: widget.caseDocId),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _blueAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Manage Docs',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _blueAccent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (docs.isEmpty)
              Text(
                'No documents attached to this case yet.',
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: _textMuted,
                    fontStyle: FontStyle.italic),
              )
            else
              ...docs.take(3).map((doc) {
                final name =
                    (doc['name'] ?? doc['title'] ?? 'Document').toString();
                final url = (doc['url'] ??
                        doc['secure_url'] ??
                        doc['downloadUrl'] ??
                        '')
                    .toString();
                final size = (doc['sizeLabel'] ?? doc['size'] ?? '').toString();
                final uploadedBy = (doc['uploadedBy'] ?? 'Client').toString();

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFEFEFEF)),
                  ),
                  child: ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 2),
                    onTap: () => _openLawyerDocumentUrl(url),
                    leading: const Icon(Icons.insert_drive_file_outlined,
                        color: _blueAccent, size: 20),
                    title: Text(
                      name,
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _navyDark),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${size.isNotEmpty ? '$size • ' : ''}Uploaded by $uploadedBy',
                      style: GoogleFonts.poppins(
                          fontSize: 10, color: _textMuted),
                    ),
                    trailing: const Icon(Icons.open_in_new_rounded,
                        size: 16, color: _blueAccent),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Future<void> _openLawyerDocumentUrl(String url) async {
    final cleanUrl = url.trim();
    if (cleanUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Document URL is empty or unavailable.',
              style: GoogleFonts.poppins()),
          backgroundColor: const Color(0xFFE05252),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final uri = Uri.tryParse(cleanUrl);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // ── Notes (editable) ──
  Widget _buildNotes(CaseModel c) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.edit_note_rounded,
                        size: 18, color: _navyDark),
                    const SizedBox(width: 8),
                    Text(
                      'Notes',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _navyDark,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => _showEditNotesDialog(c),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _blueAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Edit',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _blueAccent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              c.lawyerNotes.isNotEmpty
                  ? c.lawyerNotes
                  : 'No notes yet. Tap Edit to add notes.',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: c.lawyerNotes.isNotEmpty
                    ? const Color(0xFF4A5568)
                    : _textMuted,
                height: 1.6,
                fontStyle: c.lawyerNotes.isEmpty
                    ? FontStyle.italic
                    : FontStyle.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditNotesDialog(CaseModel c) {
    final controller = TextEditingController(text: c.lawyerNotes);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit Notes',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: TextField(
          controller: controller,
          maxLines: 6,
          decoration: InputDecoration(
            hintText: 'Enter your notes about this case...',
            hintStyle: GoogleFonts.poppins(fontSize: 13, color: _textMuted),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await CaseService.updateCaseNotes(
                  widget.caseDocId, controller.text.trim());
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _navyDark,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Save', style: TextStyle(color: _white)),
          ),
        ],
      ),
    );
  }

  // ── Activity Preview (recent 3 entries) ──
  Widget _buildActivityPreview(CaseModel c) {
    final entries = c.activityLog.take(3).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.timeline_outlined,
                        size: 18, color: _navyDark),
                    const SizedBox(width: 8),
                    Text(
                      'Recent Activity',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _navyDark,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LawyerCaseTimelineScreen(
                            caseDocId: widget.caseDocId),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _blueAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View All',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _blueAccent,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward,
                            size: 14, color: _blueAccent),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            if (entries.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No activity recorded yet.',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: _textMuted,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              ...entries.map((log) {
                final type = log['type'] as String? ?? '';
                final title = log['title'] as String? ?? '';
                final timestamp = DateTime.tryParse(
                    (log['timestamp'] as String?) ?? '');

                IconData icon;
                Color color;
                switch (type) {
                  case 'case_update':
                    icon = Icons.trending_up_rounded;
                    color = _blueAccent;
                    break;
                  case 'document_uploaded':
                    icon = Icons.cloud_upload_outlined;
                    color = _greenAccent;
                    break;
                  case 'note_added':
                    icon = Icons.edit_note_rounded;
                    color = const Color(0xFFD4A843);
                    break;
                  default:
                    icon = Icons.circle_outlined;
                    color = _textMuted;
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(icon, size: 16, color: color),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: _navyDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (timestamp != null)
                        Text(
                          _formatTimeAgo(timestamp),
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: _textMuted,
                          ),
                        ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${dt.day} ${months[dt.month - 1]}';
  }

  // ── Quick Actions ──
  Widget _buildQuickActions(CaseModel c) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _navyDark,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildActionButton(Icons.description_outlined, 'View\nDocuments',
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LawyerUploadDocumentsScreen(
                        caseDocId: widget.caseDocId),
                  ),
                );
              }),
              const SizedBox(width: 12),
              _buildActionButton(
                  Icons.trending_up_rounded, 'Update\nProgress', () {
                _showUpdateProgressDialog(c);
              }),
              const SizedBox(width: 12),
              _buildActionButton(
                  Icons.cloud_upload_outlined, 'Upload\nDocument', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LawyerUploadDocumentsScreen(
                        caseDocId: widget.caseDocId),
                  ),
                );
              }),
              const SizedBox(width: 12),
              _buildActionButton(
                  Icons.timeline_outlined, 'Case\nTimeline', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LawyerCaseTimelineScreen(
                        caseDocId: widget.caseDocId),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              Icon(icon, color: _navyDark, size: 24),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: _navyDark,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUpdateProgressDialog(CaseModel c) {
    int selectedStage = c.currentStage;
    String? stageNote;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Update Progress',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Current: ${c.stageLabel}',
                  style: GoogleFonts.poppins(fontSize: 13, color: _textMuted)),
              const SizedBox(height: 16),
              Theme(
                data: ThemeData.light().copyWith(
                  primaryColor: _navyDark,
                  colorScheme: const ColorScheme.light(primary: _navyDark),
                ),
                child: DropdownButtonFormField<int>(
                  initialValue: selectedStage,
                  decoration: InputDecoration(
                    labelText: 'Stage',
                    labelStyle: GoogleFonts.poppins(color: _navyDark),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  style: GoogleFonts.poppins(color: Colors.black, fontSize: 14),
                  items: [1, 2, 3]
                      .map((s) => DropdownMenuItem(
                            value: s,
                            child: Text('Stage $s of 3'),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => selectedStage = val);
                    }
                  },
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                onChanged: (val) => stageNote = val,
                decoration: InputDecoration(
                  hintText: 'Optional note...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                style: GoogleFonts.poppins(fontSize: 13),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await CaseService.updateCaseStage(
                  widget.caseDocId,
                  currentStage: selectedStage,
                  totalStages: 3,
                  stageNote: stageNote,
                );
                // Also add to activity log
                final user = FirebaseAuth.instance.currentUser;
                await CaseService.addActivityLogEntry(
                  widget.caseDocId,
                  type: 'case_update',
                  title: 'Progress Updated to Stage $selectedStage',
                  description: stageNote ?? 'Case progress updated.',
                  actor: user?.displayName ?? 'Lawyer',
                );
                if (ctx.mounted) Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _navyDark,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Update', style: TextStyle(color: _white)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Bottom Buttons ──
  Widget _buildBottomButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextButton.icon(
                onPressed: () {
                  // Contact Support placeholder
                },
                icon: const Icon(Icons.phone_outlined, size: 18),
                label: Text('Contact Support',
                    style: GoogleFonts.poppins(
                        fontSize: 12, fontWeight: FontWeight.w500)),
              ),
            ),
            Container(
              width: 1,
              height: 30,
              color: Colors.grey.shade200,
            ),
            Expanded(
              child: TextButton.icon(
                onPressed: () {
                  // Chat with Admin placeholder
                },
                icon: const Icon(Icons.chat_bubble_outline, size: 18),
                label: Text('Chat with Admin',
                    style: GoogleFonts.poppins(
                        fontSize: 12, fontWeight: FontWeight.w500)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}

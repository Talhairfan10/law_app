import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (mounted && doc.exists) {
        setState(() {
          _clientName = doc.data()?['fullName'] as String? ?? 'Client';
        });
      }
    } catch (_) {
      _clientName = 'Client';
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
    // Get next hearing
    final clientId = c.userId.length > 8
        ? 'CLT-${c.userId.substring(0, 4).toUpperCase()}'
        : c.userId;

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
            // Grid of info items
            Row(
              children: [
                Expanded(
                    child: _infoItem(
                        Icons.person_outline, 'Client ID', clientId)),
                Expanded(
                    child: _infoItem(
                        Icons.account_balance_outlined, 'Court',
                        c.location.isNotEmpty ? c.location : 'Not assigned')),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                    child: _infoItem(Icons.person_outline, 'Client Name',
                        _clientName ?? 'Loading...')),
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
                          final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
                          hearingText =
                              '${date.day} ${months[date.month - 1]} ${date.year}, $time';
                        }
                      }
                      return _infoItem(Icons.calendar_today_outlined,
                          'Next Hearing', hearingText);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                    child: _infoItem(Icons.folder_outlined, 'Category',
                        c.subCategory.isNotEmpty ? c.subCategory : c.category)),
                Expanded(
                    child: _infoItem(Icons.attach_money_rounded, 'Fee Range',
                        'PKR ${c.budgetMin} - ${c.budgetMax}')),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                    child: _infoItem(
                        Icons.description_outlined, 'Case Type',
                        c.shortDescription.isNotEmpty
                            ? c.shortDescription
                            : c.categoryDisplayName)),
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

  // ── Case Description ──
  Widget _buildCaseDescription(CaseModel c) {
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
                const Icon(Icons.description_outlined,
                    size: 18, color: _navyDark),
                const SizedBox(width: 8),
                Text(
                  'Case Description',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _navyDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              c.additionalInfo.isNotEmpty
                  ? c.additionalInfo
                  : c.shortDescription.isNotEmpty
                      ? c.shortDescription
                      : 'No description provided.',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color(0xFF4A5568),
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
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

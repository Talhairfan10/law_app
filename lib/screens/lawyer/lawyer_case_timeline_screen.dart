import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/case_service.dart';
import '../../models/case_model.dart';

/// Visual vertical timeline built from the case's `activityLog` array.
/// Shows a chronological history of all actions taken on this case.
class LawyerCaseTimelineScreen extends StatelessWidget {
  final String caseDocId;

  const LawyerCaseTimelineScreen({super.key, required this.caseDocId});

  static const Color _navyDark = Color(0xFF0A1628);
  static const Color _gold = Color(0xFFD4A843);
  static const Color _white = Colors.white;
  static const Color _textMuted = Color(0xFF8E99A4);
  static const Color _greenAccent = Color(0xFF2EAD6E);
  static const Color _blueAccent = Color(0xFF3A82C4);
  static const Color _purpleAccent = Color(0xFF6C5CE7);
  static const Color _orangeAccent = Color(0xFFE6A817);

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
                stream: CaseService.getCaseStream(caseDocId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(strokeWidth: 2));
                  }
                  final caseData = snapshot.data;
                  if (caseData == null) {
                    return const Center(child: Text('Case not found'));
                  }

                  // Combine activityLog + statusHistory for a complete timeline
                  final timelineEntries = _buildTimelineEntries(caseData);

                  if (timelineEntries.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    itemCount: timelineEntries.length,
                    itemBuilder: (context, index) {
                      final entry = timelineEntries[index];
                      final isFirst = index == 0;
                      final isLast = index == timelineEntries.length - 1;
                      return _buildTimelineItem(entry, isFirst, isLast);
                    },
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
                'Case Timeline',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _navyDark,
                ),
              ),
            ),
          ),
          const SizedBox(width: 40), // balance
        ],
      ),
    );
  }

  // ── Empty State ──
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.timeline_outlined, size: 56, color: Colors.grey.shade300),
          const SizedBox(height: 14),
          Text(
            'No activity yet',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _textMuted,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Actions on this case will\nappear here as a timeline.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 13, color: _textMuted),
          ),
        ],
      ),
    );
  }

  // ── Build timeline entries from activityLog + statusHistory ──
  List<_TimelineEntry> _buildTimelineEntries(CaseModel caseData) {
    final List<_TimelineEntry> entries = [];

    // Add activity log entries
    for (final log in caseData.activityLog) {
      final type = log['type'] as String? ?? '';
      final title = log['title'] as String? ?? '';
      final description = log['description'] as String? ?? '';
      final actor = log['actor'] as String? ?? '';
      final timestamp = DateTime.tryParse(
          (log['timestamp'] as String?) ?? '');

      entries.add(_TimelineEntry(
        type: type,
        title: title,
        description: description,
        actor: actor,
        timestamp: timestamp ?? DateTime.now(),
      ));
    }

    // Add status history entries
    for (final status in caseData.statusHistory) {
      entries.add(_TimelineEntry(
        type: 'status_change',
        title: 'Status: ${status.status}',
        description: status.message,
        actor: 'System',
        timestamp: status.timestamp,
      ));
    }

    // Sort newest first
    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return entries;
  }

  // ── Timeline Item Widget ──
  Widget _buildTimelineItem(
      _TimelineEntry entry, bool isFirst, bool isLast) {
    final visual = _getTypeVisual(entry.type);
    final formattedDate = _formatDateTime(entry.timestamp);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline spine
          SizedBox(
            width: 48,
            child: Column(
              children: [
                // Top connector line
                if (!isFirst)
                  Container(width: 2, height: 12, color: Colors.grey.shade300)
                else
                  const SizedBox(height: 12),

                // Dot
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: visual.color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: visual.color.withValues(alpha: 0.4), width: 2),
                  ),
                  child: Icon(visual.icon, size: 16, color: visual.color),
                ),

                // Bottom connector line
                if (!isLast)
                  Expanded(
                    child: Container(
                        width: 2, color: Colors.grey.shade300),
                  )
                else
                  const Expanded(child: SizedBox()),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Content card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + Badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.title,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _navyDark,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: visual.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          visual.label,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: visual.color,
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (entry.description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      entry.description,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF4A5568),
                        height: 1.5,
                      ),
                    ),
                  ],

                  const SizedBox(height: 10),

                  // Footer: actor + timestamp
                  Row(
                    children: [
                      Icon(Icons.person_outline,
                          size: 14, color: _textMuted),
                      const SizedBox(width: 4),
                      Text(
                        entry.actor,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: _textMuted,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.access_time, size: 14, color: _textMuted),
                      const SizedBox(width: 4),
                      Text(
                        formattedDate,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: _textMuted,
                        ),
                      ),
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

  // ── Type visual mapping ──
  _TypeVisual _getTypeVisual(String type) {
    switch (type) {
      case 'case_update':
        return _TypeVisual(
          icon: Icons.trending_up_rounded,
          color: _blueAccent,
          label: 'Update',
        );
      case 'document_uploaded':
        return _TypeVisual(
          icon: Icons.cloud_upload_outlined,
          color: _greenAccent,
          label: 'Document',
        );
      case 'status_change':
        return _TypeVisual(
          icon: Icons.flag_outlined,
          color: _purpleAccent,
          label: 'Status',
        );
      case 'hearing_scheduled':
        return _TypeVisual(
          icon: Icons.calendar_today_rounded,
          color: _orangeAccent,
          label: 'Hearing',
        );
      case 'note_added':
        return _TypeVisual(
          icon: Icons.edit_note_rounded,
          color: _gold,
          label: 'Note',
        );
      default:
        return _TypeVisual(
          icon: Icons.circle_outlined,
          color: _textMuted,
          label: 'Activity',
        );
    }
  }

  // ── Format date ──
  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';

    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hour =
        dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}, '
        '${hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} $period';
  }
}

// ── Internal data models ──

class _TimelineEntry {
  final String type;
  final String title;
  final String description;
  final String actor;
  final DateTime timestamp;

  const _TimelineEntry({
    required this.type,
    required this.title,
    required this.description,
    required this.actor,
    required this.timestamp,
  });
}

class _TypeVisual {
  final IconData icon;
  final Color color;
  final String label;

  const _TypeVisual({
    required this.icon,
    required this.color,
    required this.label,
  });
}

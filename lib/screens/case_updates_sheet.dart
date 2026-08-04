import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/case_model.dart';

/// Shows the full status-change log for a case in a bottom sheet.
///
/// Call via:
/// ```dart
/// showCaseUpdatesSheet(context, caseModel.statusHistory, caseModel.caseId);
/// ```
void showCaseUpdatesSheet(
  BuildContext context,
  List<StatusHistoryEntry> history,
  String caseId,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _CaseUpdatesSheet(history: history, caseId: caseId),
  );
}

class _CaseUpdatesSheet extends StatelessWidget {
  final List<StatusHistoryEntry> history;
  final String caseId;

  static const Color _primary = Color(0xFF5C3FD3);
  static const Color _dark = Color(0xFF1A1A2E);
  static const Color _grey = Color(0xFF8E8E93);

  const _CaseUpdatesSheet({
    required this.history,
    required this.caseId,
  });

  @override
  Widget build(BuildContext context) {
    // Sort newest first (history should already be sorted, but just in case)
    final sorted = List<StatusHistoryEntry>.from(history)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF0ECFD),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.history_rounded,
                      color: _primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'All Updates',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _dark,
                        ),
                      ),
                      Text(
                        'Case ID: $caseId',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: _grey,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5F5F5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 16, color: _grey),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),

          // Updates list
          Flexible(
            child: sorted.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.info_outline,
                            color: _grey, size: 40),
                        const SizedBox(height: 12),
                        Text(
                          'No updates yet',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: _grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    itemCount: sorted.length,
                    itemBuilder: (context, index) {
                      final entry = sorted[index];
                      final isFirst = index == 0;
                      final isLast = index == sorted.length - 1;
                      return _buildUpdateItem(entry, isFirst, isLast);
                    },
                  ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildUpdateItem(
      StatusHistoryEntry entry, bool isLatest, bool isLast) {
    final dateStr = DateFormat('dd MMM yyyy').format(entry.timestamp);
    final timeStr = DateFormat('hh:mm a').format(entry.timestamp);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline dot + line
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isLatest ? _primary : const Color(0xFFE0E0E0),
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 50,
                  color: const Color(0xFFE0E0E0),
                ),
            ],
          ),
          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        entry.status,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _dark,
                        ),
                      ),
                    ),
                    if (isLatest)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0ECFD),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Latest',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _primary,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  entry.message,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: _grey,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$dateStr • $timeStr',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: const Color(0xFFBBBBBB),
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

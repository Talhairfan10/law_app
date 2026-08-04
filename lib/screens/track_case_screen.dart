import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/case_model.dart';
import '../services/case_service.dart';
import 'case_updates_sheet.dart';
import 'placeholders.dart';

class TrackCaseScreen extends StatelessWidget {
  final String caseDocId;

  const TrackCaseScreen({super.key, required this.caseDocId});

  static const Color _primary = Color(0xFF5C3FD3);
  static const Color _dark = Color(0xFF1A1A2E);
  static const Color _grey = Color(0xFF8E8E93);
  static const Color _bg = Color(0xFFFAFAFA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: StreamBuilder<CaseModel?>(
        stream: CaseService.getCaseStream(caseDocId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: _primary),
            );
          }

          final caseData = snapshot.data;
          if (caseData == null) {
            return _buildErrorState(context);
          }

          return _TrackCaseBody(caseData: caseData);
        },
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: _grey, size: 48),
            const SizedBox(height: 16),
            Text(
              'Case not found',
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.bold, color: _dark),
            ),
            const SizedBox(height: 8),
            Text(
              'This case may have been removed.',
              style: GoogleFonts.poppins(fontSize: 14, color: _grey),
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, size: 18),
              label: const Text('Go Back'),
              style: TextButton.styleFrom(foregroundColor: _primary),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────
//  Body — separated to hold CaseModel
// ─────────────────────────────────────────────────

class _TrackCaseBody extends StatelessWidget {
  final CaseModel caseData;

  static const Color _primary = Color(0xFF5C3FD3);
  static const Color _dark = Color(0xFF1A1A2E);
  static const Color _grey = Color(0xFF8E8E93);

  const _TrackCaseBody({required this.caseData});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildAppBar(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
              child: Column(
                children: [
                  _buildCaseInfoCard(),
                  _buildProgressSection(context),
                  _buildLatestUpdateSection(context),
                  _buildAssignedLawyerSection(context),
                  _buildNeedHelpButton(context),
                  _buildBackButton(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────
  //  App Bar
  // ─────────────────────────────────────────────────

  Widget _buildAppBar(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: _dark),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Track Case',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _dark,
                  ),
                ),
                Text(
                  'Case ID: ${caseData.caseId}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: _grey,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.help_outline_rounded,
                    color: _primary, size: 20),
                const SizedBox(width: 4),
                Text(
                  'Help',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _primary,
                  ),
                ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const PlaceholderScreen(title: 'Contact Support'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────
  //  Case Info Card (purple gradient)
  // ─────────────────────────────────────────────────

  Widget _buildCaseInfoCard() {
    final submittedDate =
        DateFormat('dd MMM yyyy').format(caseData.createdAt);
    final submittedTime = DateFormat('hh:mm a').format(caseData.createdAt);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF0ECFD), Color(0xFFE8E3FB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _primary.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row with icon
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: caseData.categoryIconBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.8),
                    width: 2,
                  ),
                ),
                child: Icon(
                  caseData.categoryIcon,
                  color: caseData.categoryIconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      caseData.shortDescription,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _dark,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      caseData.subCategory.isNotEmpty
                          ? caseData.subCategory
                          : caseData.categoryDisplayName,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: _primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Info pills row
          Row(
            children: [
              _buildInfoPill(
                icon: Icons.calendar_today_outlined,
                label: 'Submitted On',
                value: '$submittedDate\n$submittedTime',
              ),
              const SizedBox(width: 10),
              _buildInfoPill(
                icon: Icons.circle,
                iconSize: 8,
                iconColor: caseData.statusColor,
                label: 'Current Status',
                value: caseData.statusLabel,
                valueColor: caseData.statusColor,
              ),
              const SizedBox(width: 10),
              _buildInfoPill(
                icon: Icons.access_time_rounded,
                label: 'Estimated Assignment',
                value: caseData.estimatedAssignment,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPill({
    required IconData icon,
    required String label,
    required String value,
    double iconSize = 14,
    Color? iconColor,
    Color? valueColor,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon,
                  size: iconSize, color: iconColor ?? _grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: _grey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: valueColor ?? _dark,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────
  //  Case Progress Timeline
  // ─────────────────────────────────────────────────

  Widget _buildProgressSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Case Progress',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _dark,
                ),
              ),
              GestureDetector(
                onTap: () {
                  showCaseUpdatesSheet(
                      context, caseData.statusHistory, caseData.caseId);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.list_rounded, size: 16, color: _primary),
                      const SizedBox(width: 6),
                      Text(
                        'View All Updates',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Timeline steps
          ...CaseStep.values.asMap().entries.map((entry) {
            final step = entry.value;
            final isLast = entry.key == CaseStep.values.length - 1;
            final progress = caseData.caseProgress[step]!;
            return _buildTimelineStep(step, progress, isLast);
          }),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(
    CaseStep step,
    StepProgressData progress,
    bool isLast,
  ) {
    final label = kStepLabels[step]!;
    final isCompleted = progress.status == CaseStepStatus.completed;
    final isInProgress = progress.status == CaseStepStatus.inProgress;

    // Colors
    final Color dotColor;
    final Color dotBorderColor;
    Widget dotChild;

    if (isCompleted) {
      dotColor = const Color(0xFF2EAD6E);
      dotBorderColor = const Color(0xFF2EAD6E);
      dotChild = const Icon(Icons.check, color: Colors.white, size: 14);
    } else if (isInProgress) {
      dotColor = const Color(0xFFE6A817);
      dotBorderColor = const Color(0xFFE6A817);
      dotChild = const SizedBox.shrink();
    } else {
      dotColor = Colors.white;
      dotBorderColor = const Color(0xFFD0D0D0);
      dotChild = const SizedBox.shrink();
    }

    // Status label
    final String statusText;
    final Color statusTextColor;
    if (isCompleted) {
      statusText = 'Completed';
      statusTextColor = const Color(0xFF2EAD6E);
    } else if (isInProgress) {
      statusText = 'In Progress';
      statusTextColor = const Color(0xFFE6A817);
    } else {
      statusText = 'Pending';
      statusTextColor = _grey;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline dot + connecting line
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: dotBorderColor, width: 2),
                  ),
                  child: Center(child: dotChild),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      color: isCompleted
                          ? const Color(0xFF2EAD6E).withValues(alpha: 0.3)
                          : const Color(0xFFE0E0E0),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color:
                                isCompleted || isInProgress ? _dark : _grey,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          progress.note.isNotEmpty ? progress.note : statusText,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: _grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    statusText,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────
  //  Latest Update Section
  // ─────────────────────────────────────────────────

  Widget _buildLatestUpdateSection(BuildContext context) {
    final latest = caseData.latestUpdate;
    if (latest == null) return const SizedBox.shrink();

    final now = DateTime.now();
    final isToday = latest.timestamp.year == now.year &&
        latest.timestamp.month == now.month &&
        latest.timestamp.day == now.day;
    final dateStr =
        isToday ? 'Today' : DateFormat('dd MMM yyyy').format(latest.timestamp);
    final timeStr = DateFormat('hh:mm a').format(latest.timestamp);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFF0ECFD),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.update_rounded,
                    color: _primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Latest Update',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _dark,
                          ),
                        ),
                        Text(
                          '$dateStr, $timeStr',
                          style: GoogleFonts.poppins(
                              fontSize: 11, color: _grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      latest.message,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: _grey,
                        height: 1.5,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Expected next update:',
                style: GoogleFonts.poppins(fontSize: 12, color: _grey),
              ),
              Row(
                children: [
                  const Icon(Icons.access_time_rounded,
                      size: 14, color: _primary),
                  const SizedBox(width: 4),
                  Text(
                    caseData.estimatedAssignment,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────
  //  Assigned Lawyer Section
  // ─────────────────────────────────────────────────

  Widget _buildAssignedLawyerSection(BuildContext context) {
    final lawyer = caseData.assignedLawyer;
    final isAssigned = lawyer.isAssigned;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0ECFD),
                  shape: BoxShape.circle,
                  image: isAssigned && lawyer.photoUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(lawyer.photoUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: !(isAssigned && lawyer.photoUrl.isNotEmpty)
                    ? const Icon(Icons.person_outline_rounded,
                        color: _primary, size: 26)
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Assigned Lawyer',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _dark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (isAssigned) ...[
                      Text(
                        lawyer.name,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _primary,
                        ),
                      ),
                      Text(
                        lawyer.specialization,
                        style:
                            GoogleFonts.poppins(fontSize: 12, color: _grey),
                      ),
                    ] else ...[
                      Text(
                        'Not Assigned Yet',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFE6A817),
                        ),
                      ),
                      Text(
                        'A suitable lawyer will be assigned to your case soon.',
                        style:
                            GoogleFonts.poppins(fontSize: 12, color: _grey),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          // Lawyer fee + pay button (when assigned but not yet paid)
          if (isAssigned) ...[
            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFF0F0F0)),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lawyer Fee',
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: _grey),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'PKR ${_formatFee(lawyer.fee)}',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _dark,
                      ),
                    ),
                  ],
                ),
                if (lawyer.isPendingPayment)
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const PlaceholderScreen(title: 'Payment'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.payment_rounded, size: 18),
                    label: Text(
                      lawyer.feeStatus == 'pending_review'
                          ? 'Review & Pay'
                          : 'Pay Now',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  )
                else if (lawyer.isPaid)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5F7EF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle,
                            color: Color(0xFF2EAD6E), size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Paid',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2EAD6E),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────
  //  Need Help Button
  // ─────────────────────────────────────────────────

  Widget _buildNeedHelpButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const PlaceholderScreen(title: 'Contact Support'),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
              child: const Icon(Icons.chat_bubble_outline_rounded,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'Need Help?',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _dark,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: _primary, size: 18),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────
  //  Back Button
  // ─────────────────────────────────────────────────

  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          children: [
            const Icon(Icons.arrow_back_rounded, color: _primary, size: 20),
            const SizedBox(width: 12),
            Text(
              'Back to My Cases',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _dark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────
  //  Helpers
  // ─────────────────────────────────────────────────

  String _formatFee(double fee) {
    if (fee >= 1000) {
      final formatted = fee.toStringAsFixed(0);
      final buffer = StringBuffer();
      int count = 0;
      for (int i = formatted.length - 1; i >= 0; i--) {
        buffer.write(formatted[i]);
        count++;
        if (count % 3 == 0 && i > 0) {
          buffer.write(',');
        }
      }
      return buffer.toString().split('').reversed.join();
    }
    return fee.toStringAsFixed(0);
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  static const Color _primary = Color(0xFF6C5CE7);
  static const Color _bgColor = Color(0xFFFAFAFA);

  String _selectedFilter = 'all';

  final List<Map<String, String>> _filters = const [
    {'label': 'All', 'value': 'all'},
    {'label': 'Case Updates', 'value': 'case_update'},
    {'label': 'Payments', 'value': 'payment'},
    {'label': 'System', 'value': 'system'},
    {'label': 'Promotions', 'value': 'promotion'},
  ];

  String? get _currentUserId => FirebaseAuth.instance.currentUser?.uid;

  // ───────────────────────────────────────────────
  //  Timestamp Formatting
  // ───────────────────────────────────────────────

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'Just now';

    final today = DateTime(now.year, now.month, now.day);
    final notifDate = DateTime(dt.year, dt.month, dt.day);

    if (notifDate == today) {
      return DateFormat('h:mm a').format(dt);
    }

    final yesterday = today.subtract(const Duration(days: 1));
    if (notifDate == yesterday) {
      return 'Yesterday';
    }

    return DateFormat('d MMM, hh:mm a').format(dt);
  }

  // ───────────────────────────────────────────────
  //  Actions
  // ───────────────────────────────────────────────

  void _onNotificationTap(NotificationModel notification) {
    final userId = _currentUserId;
    if (userId == null) return;

    // Mark as read
    if (!notification.isRead) {
      NotificationService.markAsRead(userId, notification.id);
    }

    // Show bottom sheet with full details
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _buildNotificationDetailSheet(notification),
    );
  }

  void _onMarkAllAsRead() {
    final userId = _currentUserId;
    if (userId == null) return;
    NotificationService.markAllAsRead(userId);
  }

  // ───────────────────────────────────────────────
  //  Build
  // ───────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final userId = _currentUserId;

    return Scaffold(
      backgroundColor: _bgColor,
      floatingActionButton: kDebugMode
          ? FloatingActionButton.extended(
              onPressed: () {
                if (userId != null) {
                  NotificationService.createSampleNotifications(userId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Sample notifications created!',
                        style: GoogleFonts.poppins(),
                      ),
                      backgroundColor: _primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                }
              },
              backgroundColor: _primary,
              icon: const Icon(Icons.bug_report_rounded, color: Colors.white),
              label: Text(
                'Add Samples',
                style: GoogleFonts.poppins(
                    color: Colors.white, fontWeight: FontWeight.w600),
              ),
            )
          : null,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildHeader(),
            const SizedBox(height: 16),
            _buildFilterTabs(),
            const SizedBox(height: 8),
            Expanded(
              child: userId == null
                  ? _buildEmptyState()
                  : _buildNotificationList(userId),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────
  //  Header
  // ───────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Alerts',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Stay updated with your case and account notifications',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF8E8E93),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────
  //  Filter Tabs
  // ───────────────────────────────────────────────

  Widget _buildFilterTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF2F0FE),
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.all(4),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _filters.map((f) {
              final isActive = _selectedFilter == f['value'];
              return GestureDetector(
                onTap: () => setState(() => _selectedFilter = f['value']!),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    f['label']!,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.w400,
                      color: isActive ? _primary : const Color(0xFF8E8E93),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────
  //  Notification List (StreamBuilder)
  // ───────────────────────────────────────────────

  Widget _buildNotificationList(String userId) {
    return StreamBuilder<List<NotificationModel>>(
      stream: NotificationService.getNotificationsStream(
        userId,
        type: _selectedFilter == 'all' ? null : _selectedFilter,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: _primary),
          );
        }

        final notifications = snapshot.data ?? [];

        if (notifications.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          itemCount: notifications.length + 1, // +1 for "Mark all as read"
          itemBuilder: (context, index) {
            if (index == notifications.length) {
              return _buildMarkAllAsRead();
            }
            return _buildNotificationCard(notifications[index]);
          },
        );
      },
    );
  }

  // ───────────────────────────────────────────────
  //  Notification Card
  // ───────────────────────────────────────────────

  Widget _buildNotificationCard(NotificationModel notification) {
    return GestureDetector(
      onTap: () => _onNotificationTap(notification),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: Icon circle
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: notification.iconBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                notification.icon,
                color: notification.iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),

            // Middle: Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row with "New" badge
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          notification.title,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1A1A2E),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (notification.isNew) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDE7F6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'New',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Description
                  Text(
                    notification.description,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF8E8E93),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Case ID
                  if (notification.caseId != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Case ID: ${notification.caseId}',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: const Color(0xFFAAAAAA),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Right: Timestamp + unread dot + chevron
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTimestamp(notification.createdAt),
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: const Color(0xFF8E8E93),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    if (!notification.isRead) ...[
                      const SizedBox(width: 6),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: _primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFBDBDBD),
                  size: 22,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────
  //  Mark All as Read
  // ───────────────────────────────────────────────

  Widget _buildMarkAllAsRead() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: GestureDetector(
        onTap: _onMarkAllAsRead,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              color: _primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Mark all as read',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────
  //  Empty State
  // ───────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F0FE),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_off_rounded,
              color: _primary,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No notifications yet',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'When you receive notifications,\nthey will appear here.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF8E8E93),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────
  //  Notification Detail Bottom Sheet
  // ───────────────────────────────────────────────

  Widget _buildNotificationDetailSheet(NotificationModel notification) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: notification.iconBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              notification.icon,
              color: notification.iconColor,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            notification.title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A2E),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            notification.description,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF8E8E93),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),

          // Case ID
          if (notification.caseId != null) ...[
            const SizedBox(height: 12),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Case ID: ${notification.caseId}',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFF6C5CE7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],

          const SizedBox(height: 8),

          // Timestamp
          Text(
            _formatTimestamp(notification.createdAt),
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFFBDBDBD),
            ),
          ),
          const SizedBox(height: 24),

          // Close button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Text(
                'Got it',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

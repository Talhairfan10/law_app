import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/notification_service.dart';
import '../../models/notification_model.dart';

/// Lawyer Notifications screen — Phase 4 will add full tab filtering.
/// This is a functional stub that shows real notifications from Firestore.
class LawyerNotificationsScreen extends StatefulWidget {
  const LawyerNotificationsScreen({super.key});

  @override
  State<LawyerNotificationsScreen> createState() => _LawyerNotificationsScreenState();
}

class _LawyerNotificationsScreenState extends State<LawyerNotificationsScreen> {

  static const Color _navyDark = Color(0xFF0A1628);
  static const Color _textMuted = Color(0xFF8E99A4);
  static const Color _blueAccent = Color(0xFF3A82C4);

  String get _currentUid => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                const SizedBox(width: 40),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: _navyDark,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    if (_currentUid.isNotEmpty) {
                      await NotificationService.markAllAsRead(_currentUid);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.done_all, color: _navyDark, size: 20),
                  ),
                ),
              ],
            ),
          ),

          // Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _buildTab('All', 0),
                const SizedBox(width: 12),
                _buildTab('Unread', 1),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Notification List
          Expanded(
            child: StreamBuilder<List<NotificationModel>>(
              stream: _currentUid.isNotEmpty
                  ? NotificationService.getNotificationsStream(_currentUid)
                  : const Stream.empty(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(strokeWidth: 2));
                }
                var notifications = snapshot.data ?? [];
                
                if (_selectedTabIndex == 1) {
                  notifications = notifications.where((n) => !n.isRead).toList();
                }

                if (notifications.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_none,
                            size: 48, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text(
                          'No notifications yet',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: _textMuted,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notif = notifications[index];
                    return _buildNotificationTile(context, notif);
                  },
                );
              },
            ),
          ),

          // Mark all as read bar
          Container(
            padding: const EdgeInsets.all(16),
            child: GestureDetector(
              onTap: () async {
                if (_currentUid.isNotEmpty) {
                  await NotificationService.markAllAsRead(_currentUid);
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.mark_email_read_outlined,
                      size: 18, color: _blueAccent),
                  const SizedBox(width: 8),
                  Text(
                    'Mark all as read',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _blueAccent,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward,
                      size: 16, color: _blueAccent),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _selectedTabIndex = 0;

  Widget _buildTab(String title, int index) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _navyDark : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _navyDark : Colors.grey.shade300,
          ),
        ),
        child: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : _textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationTile(
      BuildContext context, NotificationModel notif) {
    return GestureDetector(
      onTap: () async {
        if (!notif.isRead && _currentUid.isNotEmpty) {
          await NotificationService.markAsRead(_currentUid, notif.id);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
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
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: notif.iconBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(notif.icon, color: notif.iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notif.title,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight:
                          notif.isRead ? FontWeight.w500 : FontWeight.w600,
                      color: _navyDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notif.description,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: _textMuted,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatTime(notif.createdAt),
                  style: GoogleFonts.poppins(fontSize: 11, color: _textMuted),
                ),
                if (!notif.isRead) ...[
                  const SizedBox(height: 4),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: _blueAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) {
      final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      return '${hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} $period';
    }
    if (diff.inDays == 1) return 'Yesterday';
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${dt.day} ${months[dt.month - 1]}';
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';

/// Centralised Firestore operations for the
/// `users/{userId}/notifications` subcollection.
///
/// All methods are static, matching the pattern used by [AuthService] and
/// [CaseService].
class NotificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Helper to get the notifications subcollection reference for a user.
  static CollectionReference _notificationsRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('notifications');
  }

  // ─────────────────────────────────────────────────
  //  Create
  // ─────────────────────────────────────────────────

  /// Writes a new notification document to
  /// `users/{userId}/notifications`.
  ///
  /// This is the **reusable entry point** that any part of the app can call
  /// whenever an in-app alert should be generated.
  static Future<void> createNotification({
    required String userId,
    required String type,
    required String title,
    required String description,
    String? caseId,
  }) async {
    await _notificationsRef(userId).add({
      'type': type,
      'title': title,
      'description': description,
      'caseId': caseId,
      'isRead': false,
      'isNew': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ─────────────────────────────────────────────────
  //  Read (real-time streams)
  // ─────────────────────────────────────────────────

  /// Returns a real-time stream of notifications for [userId],
  /// sorted by `createdAt` descending (newest first).
  ///
  /// If [type] is provided and is not `'all'`, the stream is filtered
  /// to only that notification type.
  ///
  /// NOTE: We sort client-side to avoid the server-timestamp null race
  /// condition (same approach as [CaseService.getUserCases]).
  static Stream<List<NotificationModel>> getNotificationsStream(
    String userId, {
    String? type,
  }) {
    Query query = _notificationsRef(userId);

    if (type != null && type != 'all') {
      query = query.where('type', isEqualTo: type);
    }

    return query.snapshots().map((snapshot) {
      final list = snapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// Returns a real-time stream of the count of **unread** notifications
  /// for [userId].
  static Stream<int> getUnreadCount(String userId) {
    return _notificationsRef(userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // ─────────────────────────────────────────────────
  //  Update
  // ─────────────────────────────────────────────────

  /// Marks a single notification as read.
  static Future<void> markAsRead(String userId, String notificationId) async {
    await _notificationsRef(userId).doc(notificationId).update({
      'isRead': true,
      'isNew': false,
    });
  }

  /// Batch-marks **all** unread notifications for [userId] as read.
  static Future<void> markAllAsRead(String userId) async {
    final snapshot = await _notificationsRef(userId)
        .where('isRead', isEqualTo: false)
        .get();

    if (snapshot.docs.isEmpty) return;

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true, 'isNew': false});
    }
    await batch.commit();
  }

  // ─────────────────────────────────────────────────
  //  Debug / Demo Helpers
  // ─────────────────────────────────────────────────

  /// Inserts a set of realistic sample notifications for testing.
  /// Only call this from debug builds.
  static Future<void> createSampleNotifications(String userId) async {
    assert(() {
      debugPrint('NotificationService: Creating sample notifications for $userId');
      return true;
    }());

    final now = DateTime.now();
    final batch = _firestore.batch();

    final samples = [
      {
        'type': 'case_update',
        'title': 'Lawyer Accepted Your Case',
        'description':
            'Your assigned lawyer has accepted the case and will start working on it.',
        'caseId': 'LD-2505-00024',
        'isRead': false,
        'isNew': true,
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(seconds: 30))),
      },
      {
        'type': 'case_update',
        'title': 'Consultation Scheduled',
        'description':
            'Your first consultation has been scheduled with your lawyer.',
        'caseId': 'LD-2505-00024',
        'isRead': false,
        'isNew': false,
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(hours: 2))),
      },
      {
        'type': 'case_update',
        'title': 'Additional Documents Requested',
        'description':
            'Your lawyer has requested some additional documents for your case.',
        'caseId': 'LD-2505-00024',
        'isRead': false,
        'isNew': false,
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 1, hours: 3))),
      },
      {
        'type': 'payment',
        'title': 'Payment Due',
        'description':
            'Milestone payment of PKR 10,000 is due for your case.',
        'caseId': 'LD-2505-00024',
        'isRead': false,
        'isNew': false,
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 1, hours: 5))),
      },
      {
        'type': 'payment',
        'title': 'Payment Successful',
        'description':
            'Your payment of PKR 7,000 has been received successfully.',
        'caseId': 'LD-2505-00024',
        'isRead': true,
        'isNew': false,
        'createdAt': Timestamp.fromDate(
            DateTime(now.year, now.month, now.day - 70, 11, 48)),
      },
      {
        'type': 'system',
        'title': 'Welcome to Mashvira!',
        'description':
            'Thank you for choosing Mashvira Law House. We are here to help you.',
        'caseId': null,
        'isRead': true,
        'isNew': false,
        'createdAt': Timestamp.fromDate(
            DateTime(now.year, now.month, now.day - 71, 9, 0)),
      },
    ];

    for (final sample in samples) {
      final docRef = _notificationsRef(userId).doc();
      batch.set(docRef, sample);
    }

    await batch.commit();
  }
}

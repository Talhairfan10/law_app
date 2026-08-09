import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Represents a single in-app notification stored in
/// `users/{userId}/notifications/{docId}`.
class NotificationModel {
  final String id;
  final String type; // "case_update", "payment", "system", "promotion"
  final String title;
  final String description;
  final String? caseId;
  final bool isRead;
  final bool isNew;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    this.caseId,
    required this.isRead,
    required this.isNew,
    required this.createdAt,
  });

  // ───────────────────────────────────────────────
  //  Firestore Serialisation
  // ───────────────────────────────────────────────

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      type: data['type'] as String? ?? 'system',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      caseId: data['caseId'] as String?,
      isRead: data['isRead'] as bool? ?? false,
      isNew: data['isNew'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'title': title,
      'description': description,
      'caseId': caseId,
      'isRead': isRead,
      'isNew': isNew,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  // ───────────────────────────────────────────────
  //  Visual helpers (icon, colour)
  // ───────────────────────────────────────────────

  /// Returns the circular background colour for the notification icon.
  Color get iconBackgroundColor {
    final lowerTitle = title.toLowerCase();

    // Case-update subtypes
    if (lowerTitle.contains('accepted')) return const Color(0xFFE8F5E9);
    if (lowerTitle.contains('scheduled') || lowerTitle.contains('consultation')) {
      return const Color(0xFFF2F0FE);
    }
    if (lowerTitle.contains('document')) return const Color(0xFFFFF3E0);

    // Payment subtypes
    if (type == 'payment') {
      if (lowerTitle.contains('due')) return const Color(0xFFFFEBEE);
      return const Color(0xFFE3F2FD); // payment successful / receipt
    }

    // System
    if (type == 'system') return const Color(0xFFE8F5E9);

    // Promotion
    if (type == 'promotion') return const Color(0xFFFFF3E0);

    // Fallback by type
    switch (type) {
      case 'case_update':
        return const Color(0xFFF2F0FE);
      default:
        return const Color(0xFFF2F0FE);
    }
  }

  /// Returns the icon colour inside the circle.
  Color get iconColor {
    final lowerTitle = title.toLowerCase();

    if (lowerTitle.contains('accepted')) return const Color(0xFF4CAF50);
    if (lowerTitle.contains('scheduled') || lowerTitle.contains('consultation')) {
      return const Color(0xFF6C5CE7);
    }
    if (lowerTitle.contains('document')) return const Color(0xFFF57C00);

    if (type == 'payment') {
      if (lowerTitle.contains('due')) return const Color(0xFFE53935);
      return const Color(0xFF1E88E5);
    }

    if (type == 'system') return const Color(0xFF4CAF50);
    if (type == 'promotion') return const Color(0xFFF57C00);

    switch (type) {
      case 'case_update':
        return const Color(0xFF6C5CE7);
      default:
        return const Color(0xFF6C5CE7);
    }
  }

  /// Returns the appropriate icon for this notification.
  IconData get icon {
    final lowerTitle = title.toLowerCase();

    if (lowerTitle.contains('accepted')) return Icons.verified_user_rounded;
    if (lowerTitle.contains('scheduled') || lowerTitle.contains('consultation')) {
      return Icons.calendar_today_rounded;
    }
    if (lowerTitle.contains('document')) return Icons.description_rounded;

    if (type == 'payment') {
      if (lowerTitle.contains('due')) return Icons.account_balance_wallet_rounded;
      return Icons.receipt_long_rounded;
    }

    if (type == 'system') return Icons.campaign_rounded;
    if (type == 'promotion') return Icons.local_offer_rounded;

    switch (type) {
      case 'case_update':
        return Icons.gavel_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }
}

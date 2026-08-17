import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'case_service.dart';
import 'notification_service.dart';

/// Centralised Firestore operations for the
/// `cases/{caseId}/hearings` subcollection.
///
/// All methods are static, matching the pattern used by [AuthService],
/// [CaseService], and [NotificationService].
class HearingService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Helper to get the hearings subcollection reference for a case.
  static CollectionReference _hearingsRef(String caseId) {
    return _firestore.collection('cases').doc(caseId).collection('hearings');
  }

  // ─────────────────────────────────────────────────
  //  Read Operations
  // ─────────────────────────────────────────────────

  /// Returns a real-time stream of hearings for a single case,
  /// sorted by date ascending (earliest first).
  static Stream<List<Map<String, dynamic>>> getHearingsForCase(String caseId) {
    return _hearingsRef(caseId).snapshots().map((snapshot) {
      final list = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        data['caseDocId'] = caseId;
        return data;
      }).toList();
      list.sort((a, b) {
        final aDate = _parseDateTime(a['date']);
        final bDate = _parseDateTime(b['date']);
        if (aDate == null || bDate == null) return 0;
        return aDate.compareTo(bDate);
      });
      return list;
    });
  }

  /// Returns a real-time stream of ALL hearings across all cases
  /// assigned to [lawyerId].
  static Stream<List<Map<String, dynamic>>> getAllLawyerHearings(
      String lawyerId) {
    if (lawyerId.isEmpty) return Stream.value([]);

    return CaseService.getLawyerCases(lawyerId).asyncMap((cases) async {
      final List<Map<String, dynamic>> allHearings = [];

      for (final caseModel in cases) {
        final hearingsSnapshot = await _hearingsRef(caseModel.docId).get();

        for (final hearingDoc in hearingsSnapshot.docs) {
          final data = hearingDoc.data() as Map<String, dynamic>;
          data['id'] = hearingDoc.id;
          data['caseDocId'] = caseModel.docId;
          data['caseId'] = caseModel.caseId;
          data['caseCategory'] = caseModel.category;
          data['caseStatus'] = caseModel.status;
          allHearings.add(data);
        }
      }

      allHearings.sort((a, b) {
        final aDate = _parseDateTime(a['date']);
        final bDate = _parseDateTime(b['date']);
        if (aDate == null || bDate == null) return 0;
        return aDate.compareTo(bDate);
      });

      return allHearings;
    });
  }

  /// Returns a real-time stream of today's hearings for the lawyer.
  static Stream<List<Map<String, dynamic>>> getTodaysHearings(
      String lawyerId) {
    return getAllLawyerHearings(lawyerId).map((hearings) {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      return hearings.where((h) {
        final date = _parseDateTime(h['date']);
        if (date == null) return false;
        return date.isAfter(todayStart) && date.isBefore(todayEnd) ||
            date.isAtSameMomentAs(todayStart);
      }).toList();
    });
  }

  /// Returns the count of today's hearings for the lawyer (stream).
  static Stream<int> getTodaysHearingsCount(String lawyerId) {
    return getTodaysHearings(lawyerId).map((list) => list.length);
  }

  /// Gets the next upcoming hearing for a specific case.
  static Stream<Map<String, dynamic>?> getNextHearingForCase(String caseId) {
    return getHearingsForCase(caseId).map((hearings) {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      for (final h in hearings) {
        final status = (h['status'] ?? 'upcoming').toString();
        if (status == 'completed') continue;
        final date = _parseDateTime(h['date']);
        if (date != null &&
            (date.isAfter(todayStart) || date.isAtSameMomentAs(todayStart))) {
          return h;
        }
      }
      return null;
    });
  }

  // ─────────────────────────────────────────────────
  //  Write Operations
  // ─────────────────────────────────────────────────

  /// Adds a new hearing to a case.
  /// [createdBy] should be the lawyer's uid.
  static Future<String> addHearing(
    String caseId, {
    required DateTime date,
    required String time,
    required String courtName,
    required String courtRoom,
    required String hearingType,
    required String purpose,
    required String createdBy,
    String status = 'upcoming',
    String notes = '',
  }) async {
    final docRef = await _hearingsRef(caseId).add({
      'date': Timestamp.fromDate(date),
      'time': time,
      'courtName': courtName,
      'courtRoom': courtRoom,
      'hearingType': hearingType,
      'purpose': purpose,
      'status': status,
      'notes': notes,
      'outcomeNotes': '',
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
    });
    debugPrint('HearingService: Added hearing ${docRef.id} to case $caseId');

    // Trigger in-app notification to client
    try {
      final caseDoc = await _firestore.collection('cases').doc(caseId).get();
      if (caseDoc.exists) {
        final caseData = caseDoc.data();
        final clientUserId = caseData?['userId'] as String?;
        final caseTitle = (caseData?['shortDescription'] ??
                caseData?['title'] ??
                caseData?['caseId'] ??
                'Your Case')
            .toString();
        final formattedCaseId = (caseData?['caseId'] ?? caseId).toString();

        if (clientUserId != null && clientUserId.isNotEmpty) {
          final dateStr =
              '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
          await NotificationService.createNotification(
            userId: clientUserId,
            type: 'hearing',
            title: 'New Hearing Scheduled',
            description:
                'A new hearing for "$caseTitle" (ID: $formattedCaseId) has been scheduled on $dateStr at $time ($courtName).',
            caseId: formattedCaseId,
          );
        }
      }
    } catch (e) {
      debugPrint(
          'HearingService: Failed to create client notification on addHearing: $e');
    }

    return docRef.id;
  }

  /// Marks a hearing as completed with optional outcome notes.
  /// Also appends an activity log entry to the parent case document
  /// and sends a notification to the client.
  static Future<void> markHearingCompleted(
    String caseId,
    String hearingId, {
    String outcomeNotes = '',
  }) async {
    // 1. Update the hearing document
    await _hearingsRef(caseId).doc(hearingId).update({
      'status': 'completed',
      'outcomeNotes': outcomeNotes,
      'completedAt': FieldValue.serverTimestamp(),
    });

    // 2. Append to case's activityLog array
    try {
      await _firestore.collection('cases').doc(caseId).update({
        'activityLog': FieldValue.arrayUnion([
          {
            'type': 'hearing_completed',
            'hearingId': hearingId,
            'outcomeNotes': outcomeNotes,
            'timestamp': Timestamp.now(),
            'description':
                'Hearing completed${outcomeNotes.isNotEmpty ? ': $outcomeNotes' : ''}',
          }
        ]),
      });
    } catch (e) {
      // If the case document doesn't have an activityLog field yet,
      // set it as a new array
      debugPrint(
          'HearingService: Could not arrayUnion activityLog, trying set: $e');
      try {
        await _firestore.collection('cases').doc(caseId).set({
          'activityLog': [
            {
              'type': 'hearing_completed',
              'hearingId': hearingId,
              'outcomeNotes': outcomeNotes,
              'timestamp': Timestamp.now(),
              'description':
                  'Hearing completed${outcomeNotes.isNotEmpty ? ': $outcomeNotes' : ''}',
            }
          ],
        }, SetOptions(merge: true));
      } catch (e2) {
        debugPrint(
            'HearingService: Failed to write activityLog entirely: $e2');
      }
    }

    // 3. Trigger in-app notification to client
    try {
      final caseDoc = await _firestore.collection('cases').doc(caseId).get();
      if (caseDoc.exists) {
        final caseData = caseDoc.data();
        final clientUserId = caseData?['userId'] as String?;
        final caseTitle = (caseData?['shortDescription'] ??
                caseData?['title'] ??
                caseData?['caseId'] ??
                'Your Case')
            .toString();
        final formattedCaseId = (caseData?['caseId'] ?? caseId).toString();

        if (clientUserId != null && clientUserId.isNotEmpty) {
          await NotificationService.createNotification(
            userId: clientUserId,
            type: 'hearing_completed',
            title: 'Hearing Completed',
            description:
                'Hearing for "$caseTitle" (ID: $formattedCaseId) has been marked completed.${outcomeNotes.isNotEmpty ? ' Outcome: $outcomeNotes' : ''}',
            caseId: formattedCaseId,
          );
        }
      }
    } catch (e) {
      debugPrint(
          'HearingService: Failed to create client notification on markHearingCompleted: $e');
    }

    debugPrint(
        'HearingService: Marked hearing $hearingId in case $caseId as completed.');
  }

  /// Returns a stream of upcoming hearings for a specific case.
  static Stream<List<Map<String, dynamic>>> getUpcomingHearingsForCase(
      String caseId) {
    return getHearingsForCase(caseId).map((hearings) {
      final now = DateTime.now();
      return hearings.where((h) {
        final status = (h['status'] ?? 'upcoming').toString();
        if (status == 'completed') return false;
        final date = _parseDateTime(h['date']);
        if (date == null) return false;
        return date.isAfter(now.subtract(const Duration(hours: 1)));
      }).toList();
    });
  }

  /// Returns a stream of completed hearings for a specific case.
  static Stream<List<Map<String, dynamic>>> getCompletedHearingsForCase(
      String caseId) {
    return getHearingsForCase(caseId).map((hearings) {
      return hearings
          .where((h) => (h['status'] ?? '').toString() == 'completed')
          .toList()
          .reversed
          .toList();
    });
  }

  /// Updates an existing hearing.
  static Future<void> updateHearing(
    String caseId,
    String hearingId, {
    DateTime? date,
    String? time,
    String? courtName,
    String? courtRoom,
    String? hearingType,
    String? purpose,
    String? status,
    String? notes,
  }) async {
    final updates = <String, dynamic>{};
    if (date != null) updates['date'] = Timestamp.fromDate(date);
    if (time != null) updates['time'] = time;
    if (courtName != null) updates['courtName'] = courtName;
    if (courtRoom != null) updates['courtRoom'] = courtRoom;
    if (hearingType != null) updates['hearingType'] = hearingType;
    if (purpose != null) updates['purpose'] = purpose;
    if (status != null) updates['status'] = status;
    if (notes != null) updates['notes'] = notes;

    if (updates.isNotEmpty) {
      await _hearingsRef(caseId).doc(hearingId).update(updates);
    }
  }

  /// Deletes a hearing.
  static Future<void> deleteHearing(String caseId, String hearingId) async {
    await _hearingsRef(caseId).doc(hearingId).delete();
  }

  // ─────────────────────────────────────────────────
  //  Helpers
  // ─────────────────────────────────────────────────

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}

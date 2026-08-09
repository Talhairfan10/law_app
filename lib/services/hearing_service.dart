import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

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
  ///
  /// This works by first querying the cases assigned to the lawyer,
  /// then aggregating hearings from each case's subcollection.
  static Stream<List<Map<String, dynamic>>> getAllLawyerHearings(
      String lawyerId) {
    return _firestore
        .collection('cases')
        .where('lawyerId', isEqualTo: lawyerId)
        .snapshots()
        .asyncMap((casesSnapshot) async {
      final List<Map<String, dynamic>> allHearings = [];

      for (final caseDoc in casesSnapshot.docs) {
        final caseData = caseDoc.data();
        final hearingsSnapshot = await _hearingsRef(caseDoc.id).get();

        for (final hearingDoc in hearingsSnapshot.docs) {
          final data = hearingDoc.data() as Map<String, dynamic>;
          data['id'] = hearingDoc.id;
          data['caseDocId'] = caseDoc.id;
          data['caseId'] = caseData['caseId'] ?? caseDoc.id;
          data['caseCategory'] = caseData['category'] ?? '';
          data['caseStatus'] = caseData['status'] ?? '';
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
      for (final h in hearings) {
        final date = _parseDateTime(h['date']);
        if (date != null && date.isAfter(now)) {
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
  static Future<String> addHearing(
    String caseId, {
    required DateTime date,
    required String time,
    required String courtName,
    required String courtRoom,
    required String hearingType,
    required String purpose,
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
      'createdAt': FieldValue.serverTimestamp(),
    });
    debugPrint('HearingService: Added hearing ${docRef.id} to case $caseId');
    return docRef.id;
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

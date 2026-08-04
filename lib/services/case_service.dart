import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/case_model.dart';
import '../models/new_case_data.dart';

/// Centralized Firestore operations for the `cases` collection.
///
/// All methods are static so they can be called without instantiation,
/// matching the pattern used by [AuthService].
class CaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _casesRef = _firestore.collection('cases');

  // ─────────────────────────────────────────────────
  //  Read Operations
  // ─────────────────────────────────────────────────

  /// Returns a real-time stream of all cases belonging to [userId],
  /// ordered by creation date (newest first).
  ///
  /// NOTE: We intentionally avoid `.orderBy('createdAt')` in the Firestore
  /// query because `createdAt` is written as `FieldValue.serverTimestamp()`.
  /// On the local client cache this field is initially `null` (unresolved),
  /// and Firestore queries with `orderBy` exclude documents where the
  /// ordered field is null — causing newly-created cases to vanish from
  /// results until the server round-trip completes. Sorting client-side
  /// avoids this race condition entirely.
  static Stream<List<CaseModel>> getUserCases(String userId) {
    return _casesRef
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final cases =
          snapshot.docs.map((doc) => CaseModel.fromFirestore(doc)).toList();
      cases.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return cases;
    });
  }

  /// Fetches a single case by its Firestore document ID.
  static Future<CaseModel?> getCaseById(String docId) async {
    final doc = await _casesRef.doc(docId).get();
    if (!doc.exists) return null;
    return CaseModel.fromFirestore(doc);
  }

  /// Returns a real-time stream of a single case document.
  static Stream<CaseModel?> getCaseStream(String docId) {
    return _casesRef.doc(docId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return CaseModel.fromFirestore(doc);
    });
  }

  // ─────────────────────────────────────────────────
  //  Notification Count (read side only)
  // ─────────────────────────────────────────────────

  /// Returns a real-time stream of the count of unread notifications
  /// for the given user. Reads from `users/{userId}/notifications`
  /// where `read == false`.
  static Stream<int> getUnreadNotificationCount(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('read', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // ─────────────────────────────────────────────────
  //  Case Submission
  // ─────────────────────────────────────────────────

  /// Submits a new case to Firestore with the corrected 9-step progress
  /// model, generates a human-readable Case ID, and initialises the
  /// status history log.
  static Future<String> submitCase({
    required NewCaseData data,
    required String userId,
  }) async {
    // 1. Generate human-readable Case ID
    final caseId = await _generateCaseId(data.category);

    // 2. Build initial caseProgress — first two steps completed
    final now = DateTime.now();
    final bool hasDocuments = data.uploadedFiles.isNotEmpty;

    final Map<String, dynamic> caseProgress = {
      'caseSubmitted': {
        'status': 'completed',
        'completedAt': now.toIso8601String(),
        'note': '${_formatDate(now)} • ${_formatTime(now)}',
      },
      'documentsUploaded': {
        'status': hasDocuments ? 'completed' : 'pending',
        'completedAt': hasDocuments ? now.toIso8601String() : null,
        'note': hasDocuments
            ? '${data.uploadedFiles.length} Document${data.uploadedFiles.length > 1 ? 's' : ''}'
            : 'No documents uploaded yet',
      },
      'companyReview': {
        'status': 'in_progress',
        'completedAt': null,
        'note': 'Our legal team is reviewing your case',
      },
      'lawyerAssignment': {
        'status': 'pending',
        'completedAt': null,
        'note': 'Pending',
      },
      'lawyerFeeReview': {
        'status': 'pending',
        'completedAt': null,
        'note': 'Pending',
      },
      'payment': {
        'status': 'pending',
        'completedAt': null,
        'note': 'Pending',
      },
      'lawyerContact': {
        'status': 'pending',
        'completedAt': null,
        'note': 'Pending',
      },
      'caseStarted': {
        'status': 'pending',
        'completedAt': null,
        'note': 'Pending',
      },
      'caseCompleted': {
        'status': 'pending',
        'completedAt': null,
        'note': 'Pending',
      },
    };

    // 3. Build initial status history
    final List<Map<String, dynamic>> statusHistory = [
      {
        'status': 'Case Submitted',
        'message':
            'Your case has been submitted successfully. Our legal team will review it shortly.',
        'timestamp': now.toIso8601String(),
      },
      if (hasDocuments)
        {
          'status': 'Documents Uploaded',
          'message':
              '${data.uploadedFiles.length} document(s) have been uploaded and attached to your case.',
          'timestamp': now.toIso8601String(),
        },
      {
        'status': 'Under Review',
        'message':
            'Your documents have been received successfully. Our legal team is reviewing your case.',
        'timestamp': now.toIso8601String(),
      },
    ];

    // 4. Write to Firestore
    final docRef = await _casesRef.add({
      'userId': userId,
      'caseId': caseId,
      'category': data.category,
      'subCategory': data.subCategory,
      'shortDescription': data.shortDescription,
      'issueDate': data.issueDate?.toIso8601String(),
      'location': data.location,
      'additionalInfo': data.additionalInfo,
      'documentUrls': data.uploadedFiles
          .map((f) => {
                'name': f.name,
                'url': f.downloadUrl,
                'size': f.sizeLabel,
              })
          .toList(),
      'budgetMin': data.budgetMin,
      'budgetMax': data.budgetMax,
      'lawyerLevel': data.lawyerLevel,
      'status': 'under_review',
      'createdAt': FieldValue.serverTimestamp(),
      'caseProgress': caseProgress,
      'assignedLawyer': null,
      'statusHistory': statusHistory,
      'estimatedAssignment': 'Within 24 Hours',
    });

    return docRef.id;
  }

  // ─────────────────────────────────────────────────
  //  Case ID Generation
  // ─────────────────────────────────────────────────

  /// Generates a human-readable case ID in the format:
  /// `{PREFIX}-{YYMM}-{00001}`.
  ///
  /// Example: `LD-2505-00024`
  static Future<String> _generateCaseId(String category) async {
    final prefix = kCategoryPrefixMap[category] ?? 'OT';
    final now = DateTime.now();
    final yearMonth =
        '${now.year.toString().substring(2)}${now.month.toString().padLeft(2, '0')}';

    // Query count of existing cases with the same prefix-month pattern
    final querySnapshot = await _casesRef
        .where('caseId', isGreaterThanOrEqualTo: '$prefix-$yearMonth-')
        .where('caseId', isLessThan: '$prefix-$yearMonth-\uf8ff')
        .get();

    final sequence = (querySnapshot.docs.length + 1).toString().padLeft(5, '0');
    return '$prefix-$yearMonth-$sequence';
  }

  // ─────────────────────────────────────────────────
  //  Helpers
  // ─────────────────────────────────────────────────

  static String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  static String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} $period';
  }
}

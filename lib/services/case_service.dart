import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'cloudinary_service.dart';
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
  //  Case Submission
  // ─────────────────────────────────────────────────

  /// Submits a new case to Firestore with the corrected 9-step progress
  /// model, generates a human-readable Case ID, and initialises the
  /// status history log.
  static Future<String> submitCase({
    required NewCaseData data,
    required String userId,
  }) async {
    try {
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

      debugPrint('CaseService.submitCase SUCCESS: Case created with docId = ${docRef.id}, caseId = $caseId');
      return docRef.id;
    } catch (e, stackTrace) {
      debugPrint('CaseService.submitCase ERROR: $e');
      debugPrint('StackTrace: $stackTrace');
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────
  //  Case ID Generation
  // ─────────────────────────────────────────────────

  /// Generates a human-readable case ID in the format:
  /// `{PREFIX}-{YYMM}-{5_RANDOM_DIGITS}`.
  ///
  /// Example: `LD-2608-48291`
  static Future<String> _generateCaseId(String category) async {
    final prefix = kCategoryPrefixMap[category] ?? 'OT';
    final now = DateTime.now();
    final yearMonth =
        '${now.year.toString().substring(2)}${now.month.toString().padLeft(2, '0')}';
    final randomNum = (10000 + Random().nextInt(90000)).toString();
    return '$prefix-$yearMonth-$randomNum';
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

  // ─────────────────────────────────────────────────
  //  Lawyer-Specific Read Operations
  // ─────────────────────────────────────────────────

  /// Returns a real-time stream of all cases assigned to [lawyerId],
  /// checking both top-level `lawyerId` and nested `assignedLawyer.lawyerId`.
  /// Returns a real-time stream of all cases assigned to [lawyerId],
  /// checking top-level `lawyerId`, nested `assignedLawyer.lawyerId`, `assignedLawyer.uid`,
  /// `assignedLawyer.id`, `assignedLawyerId`, and lawyer name/email matching.
  /// Ordered by creation date (newest first) via client-side sort.
  static Stream<List<CaseModel>> getLawyerCases(String lawyerId) {
    if (lawyerId.isEmpty) {
      debugPrint('[CaseService] getLawyerCases called with EMPTY lawyerId. Emitting empty list.');
      return Stream.value([]);
    }

    late StreamController<List<CaseModel>> controller;
    final List<StreamSubscription> subscriptions = [];
    final Map<String, CaseModel> casesMap = {};
    int emissionCount = 0;

    void emitUpdatedList() {
      emissionCount++;
      final list = casesMap.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      debugPrint(
          '[CaseService] getLawyerCases emission #$emissionCount for lawyerId="$lawyerId": ${list.length} cases found.');
      if (!controller.isClosed) {
        controller.add(list);
      }
    }

    void addSubscription(Stream<QuerySnapshot> stream, String label) {
      final sub = stream.listen((snapshot) {
        debugPrint('[CaseService] $label emitted ${snapshot.docs.length} docs');
        for (final doc in snapshot.docs) {
          try {
            casesMap[doc.id] = CaseModel.fromFirestore(doc);
          } catch (e) {
            debugPrint('[CaseService] Error parsing case ${doc.id}: $e');
          }
        }
        emitUpdatedList();
      }, onError: (e) {
        debugPrint('[CaseService] $label Error: $e');
      });
      subscriptions.add(sub);
    }

    controller = StreamController<List<CaseModel>>.broadcast(
      onListen: () async {
        // 1. Direct ID matching streams
        addSubscription(
            _casesRef.where('assignedLawyer.lawyerId', isEqualTo: lawyerId).snapshots(),
            'Stream (assignedLawyer.lawyerId)');
        addSubscription(
            _casesRef.where('lawyerId', isEqualTo: lawyerId).snapshots(),
            'Stream (lawyerId)');
        addSubscription(
            _casesRef.where('assignedLawyer.uid', isEqualTo: lawyerId).snapshots(),
            'Stream (assignedLawyer.uid)');
        addSubscription(
            _casesRef.where('assignedLawyer.id', isEqualTo: lawyerId).snapshots(),
            'Stream (assignedLawyer.id)');
        addSubscription(
            _casesRef.where('assignedLawyerId', isEqualTo: lawyerId).snapshots(),
            'Stream (assignedLawyerId)');

        // 2. Fetch lawyer user profile to match by name and email if available
        try {
          final userDoc = await _firestore.collection('users').doc(lawyerId).get();
          final userData = userDoc.data() ?? {};
          final fullName = (userData['fullName'] ?? userData['name'] ?? '').toString().trim();
          final email = (userData['email'] ?? '').toString().trim();

          if (fullName.isNotEmpty) {
            addSubscription(
                _casesRef.where('assignedLawyer.name', isEqualTo: fullName).snapshots(),
                'Stream (assignedLawyer.name: $fullName)');
            addSubscription(
                _casesRef.where('assignedLawyer.fullName', isEqualTo: fullName).snapshots(),
                'Stream (assignedLawyer.fullName: $fullName)');
          }
          if (email.isNotEmpty) {
            addSubscription(
                _casesRef.where('assignedLawyer.email', isEqualTo: email).snapshots(),
                'Stream (assignedLawyer.email: $email)');
          }

          // 3. Auto-link un-normalized cases in background
          _autoLinkCasesForLawyer(lawyerId: lawyerId, lawyerName: fullName, lawyerEmail: email);
        } catch (e) {
          debugPrint('[CaseService] Error resolving lawyer profile for queries: $e');
        }
      },
      onCancel: () {
        for (final sub in subscriptions) {
          sub.cancel();
        }
        subscriptions.clear();
      },
    );

    return controller.stream;
  }

  /// Automatically scans cases and links any case assigned to this lawyer
  /// by name, email, or partial ID by populating `lawyerId` and `assignedLawyer.lawyerId`.
  static Future<void> _autoLinkCasesForLawyer({
    required String lawyerId,
    required String lawyerName,
    required String lawyerEmail,
  }) async {
    try {
      final snap = await _casesRef.get();
      final lowerName = lawyerName.toLowerCase().trim();
      final lowerEmail = lawyerEmail.toLowerCase().trim();

      for (final doc in snap.docs) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        final assigned = data['assignedLawyer'] as Map<String, dynamic>?;
        final topLawyerId = (data['lawyerId'] ?? '').toString();

        bool isMatch = false;

        if (assigned != null && assigned.isNotEmpty) {
          final aId = (assigned['lawyerId'] ?? assigned['uid'] ?? assigned['id'] ?? '').toString();
          final aName = (assigned['name'] ?? assigned['fullName'] ?? '').toString().toLowerCase().trim();
          final aEmail = (assigned['email'] ?? '').toString().toLowerCase().trim();

          if (aId == lawyerId) isMatch = true;
          if (lowerName.isNotEmpty && (aName == lowerName || (lowerName.length > 2 && aName.contains(lowerName)))) {
            isMatch = true;
          }
          if (lowerEmail.isNotEmpty && aEmail == lowerEmail) isMatch = true;
        }

        if (topLawyerId == lawyerId) isMatch = true;

        if (isMatch) {
          final curAssignedId = assigned?['lawyerId']?.toString() ?? '';
          if (topLawyerId != lawyerId || curAssignedId != lawyerId) {
            await doc.reference.update({
              'lawyerId': lawyerId,
              'assignedLawyer.lawyerId': lawyerId,
              'assignedLawyer.uid': lawyerId,
            });
            debugPrint('[CaseService] Auto-linked case ${doc.id} to lawyer $lawyerId');
          }
        }
      }
    } catch (e) {
      debugPrint('[CaseService] _autoLinkCasesForLawyer error: $e');
    }
  }

  /// Auto-migration helper to normalize existing case documents in Firestore.
  /// Ensures both top-level `lawyerId` and `assignedLawyer.lawyerId` are present
  /// and consistent across all assigned case documents.
  static Future<int> normalizeLawyerCases() async {
    try {
      final snapshot = await _casesRef.get();
      int updatedCount = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final assigned = data['assignedLawyer'] as Map<String, dynamic>?;
        final topLawyerId = (data['lawyerId'] ?? '').toString();

        if (assigned != null && assigned.isNotEmpty) {
          final assignedLawyerId =
              (assigned['lawyerId'] ?? assigned['uid'] ?? assigned['id'] ?? '').toString();
          final effectiveLawyerId =
              assignedLawyerId.isNotEmpty ? assignedLawyerId : topLawyerId;

          if (effectiveLawyerId.isNotEmpty) {
            bool needsUpdate = false;
            final updates = <String, dynamic>{};

            if (topLawyerId != effectiveLawyerId) {
              updates['lawyerId'] = effectiveLawyerId;
              needsUpdate = true;
            }
            if (assignedLawyerId != effectiveLawyerId) {
              updates['assignedLawyer.lawyerId'] = effectiveLawyerId;
              updates['assignedLawyer.uid'] = effectiveLawyerId;
              needsUpdate = true;
            }

            if (needsUpdate) {
              await doc.reference.update(updates);
              updatedCount++;
              debugPrint(
                  '[CaseService] Normalized case ${doc.id} with lawyerId: $effectiveLawyerId');
            }
          }
        }
      }
      debugPrint('[CaseService] Total normalized cases: $updatedCount');
      return updatedCount;
    } catch (e) {
      debugPrint('[CaseService] Error normalizing cases: $e');
      return 0;
    }
  }

  /// Stream of total case count for a lawyer.
  static Stream<int> getLawyerCaseCount(String lawyerId) {
    return getLawyerCases(lawyerId).map((cases) => cases.length);
  }

  /// Stream of case count filtered by status for a lawyer.
  static Stream<int> getLawyerCaseCountByStatus(
      String lawyerId, List<String> statuses) {
    return getLawyerCases(lawyerId).map((cases) {
      return cases.where((c) => statuses.contains(c.status)).length;
    });
  }

  // ─────────────────────────────────────────────────
  //  Lawyer-Specific Write Operations
  // ─────────────────────────────────────────────────

  /// Updates the lawyer's simplified 3-stage progress for a case.
  static Future<void> updateCaseStage(
    String caseDocId, {
    required int currentStage,
    required int totalStages,
    String? stageNote,
  }) async {
    await _casesRef.doc(caseDocId).update({
      'stages': {
        'current': currentStage,
        'total': totalStages,
        'note': stageNote ?? '',
        'updatedAt': DateTime.now().toIso8601String(),
      },
    });
  }

  /// Updates the case notes field (editable by lawyer).
  static Future<void> updateCaseNotes(
      String caseDocId, String notes) async {
    await _casesRef.doc(caseDocId).update({
      'lawyerNotes': notes,
    });
  }

  /// Appends a new entry to the case's activityLog array.
  static Future<void> addActivityLogEntry(
    String caseDocId, {
    required String type,
    required String title,
    required String description,
    required String actor,
  }) async {
    await _casesRef.doc(caseDocId).update({
      'activityLog': FieldValue.arrayUnion([
        {
          'type': type,
          'title': title,
          'description': description,
          'actor': actor,
          'timestamp': DateTime.now().toIso8601String(),
        },
      ]),
    });
  }

  /// Updates the top-level case status and appends to statusHistory.
  static Future<void> updateCaseStatus(
    String caseDocId, {
    required String newStatus,
    required String message,
  }) async {
    await _casesRef.doc(caseDocId).update({
      'status': newStatus,
      'statusHistory': FieldValue.arrayUnion([
        {
          'status': newStatus,
          'message': message,
          'timestamp': DateTime.now().toIso8601String(),
        },
      ]),
    });
  }

  // ─────────────────────────────────────────────────
  //  Document Management (Lawyer)
  // ─────────────────────────────────────────────────

  // static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads a file to Firebase Storage and appends metadata to the
  /// case's `documentUrls` array. Also creates an activity log entry.
  ///
  /// Returns the download URL on success, or null on failure.
  static Future<String?> uploadCaseDocument(
    String caseDocId, {
    required File file,
    required String fileName,
    required String fileExtension,
    required String fileSize,
    required String uploadedBy,
    String documentType = 'General',
    String description = '',
  }) async {
    try {
      /* --- FIREBASE STORAGE UPLOAD (Commented out due to Spark plan limits) ---
      final ts = DateTime.now().millisecondsSinceEpoch;
      final ref = _storage
          .ref('case_documents/$caseDocId/${ts}_$fileName');
      await ref.putFile(file);
      final downloadUrl = await ref.getDownloadURL();
      */

      // --- CLOUDINARY UPLOAD ---
      final response = await CloudinaryService.uploadFile(
        file,
        folder: 'case_documents/$caseDocId',
      );

      if (response == null || !response.containsKey('secure_url')) {
        debugPrint('CaseService: Cloudinary upload returned null or missing secure_url');
        return null;
      }

      final downloadUrl = response['secure_url'] as String;

      // Append to documentUrls array
      await _casesRef.doc(caseDocId).update({
        'documentUrls': FieldValue.arrayUnion([
          {
            'name': fileName,
            'url': downloadUrl,
            'extension': fileExtension,
            'sizeLabel': fileSize,
            'documentType': documentType,
            'description': description,
            'uploadedBy': uploadedBy,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ]),
      });

      // Add activity log entry
      await addActivityLogEntry(
        caseDocId,
        type: 'document_uploaded',
        title: 'Document Uploaded',
        description: 'Uploaded "$fileName" ($documentType)',
        actor: uploadedBy,
      );

      return downloadUrl;
    } catch (e, stackTrace) {
      debugPrint('DEBUG UPLOAD ERROR (Lawyer side): $e');
      debugPrint('StackTrace: $stackTrace');
      return null;
    }
  }

  /// Removes a document entry from the case's `documentUrls` array.
  static Future<void> deleteCaseDocument(
    String caseDocId,
    Map<String, dynamic> documentEntry,
  ) async {
    await _casesRef.doc(caseDocId).update({
      'documentUrls': FieldValue.arrayRemove([documentEntry]),
    });
  }
}

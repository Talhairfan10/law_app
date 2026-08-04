import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ─────────────────────────────────────────────────
//  Enums
// ─────────────────────────────────────────────────

enum CaseStepStatus { completed, inProgress, pending }

/// High-level case status used for filter tabs.
enum CaseStatus { underReview, active, completed, rejected, closed }

// ─────────────────────────────────────────────────
//  Category → Prefix mapping
// ─────────────────────────────────────────────────

/// Human-readable Case ID prefixes per category.
///
/// ┌─────────────────────┬────────┐
/// │ Category            │ Prefix │
/// ├─────────────────────┼────────┤
/// │ Property / Land     │ LD     │
/// │ Family              │ FM     │
/// │ Criminal            │ CR     │
/// │ Employment          │ EM     │
/// │ Consumer Rights     │ CN     │
/// │ Civil               │ CV     │
/// │ Constitutional      │ CO     │
/// │ Other               │ OT     │
/// └─────────────────────┴────────┘
const Map<String, String> kCategoryPrefixMap = {
  'Property / Land': 'LD',
  'Family': 'FM',
  'Criminal': 'CR',
  'Employment': 'EM',
  'Consumer Rights': 'CN',
  'Civil': 'CV',
  'Constitutional': 'CO',
  'Other': 'OT',
};

/// Maps category name → display label for the case card.
const Map<String, String> kCategoryDisplayName = {
  'Property / Land': 'Land Disputes',
  'Family': 'Family Law',
  'Criminal': 'Criminal Law',
  'Employment': 'Employment',
  'Consumer Rights': 'Consumer Protection',
  'Civil': 'Civil Law',
  'Constitutional': 'Constitutional Law',
  'Other': 'Other',
};

/// Maps category name → icon + colors for case cards.
const Map<String, Map<String, dynamic>> kCategoryVisuals = {
  'Property / Land': {
    'icon': Icons.home_outlined,
    'iconColor': Color(0xFF2EAD6E),
    'iconBg': Color(0xFFE5F7EF),
  },
  'Family': {
    'icon': Icons.people_outline_rounded,
    'iconColor': Color(0xFF5C3FD3),
    'iconBg': Color(0xFFEEE9FB),
  },
  'Criminal': {
    'icon': Icons.balance_outlined,
    'iconColor': Color(0xFFE05252),
    'iconBg': Color(0xFFFFECEC),
  },
  'Employment': {
    'icon': Icons.work_outline_rounded,
    'iconColor': Color(0xFFE6A817),
    'iconBg': Color(0xFFFFF5E0),
  },
  'Consumer Rights': {
    'icon': Icons.shopping_cart_outlined,
    'iconColor': Color(0xFFE05252),
    'iconBg': Color(0xFFFFECEC),
  },
  'Civil': {
    'icon': Icons.description_outlined,
    'iconColor': Color(0xFF3A82C4),
    'iconBg': Color(0xFFE3F0FB),
  },
  'Constitutional': {
    'icon': Icons.gavel_rounded,
    'iconColor': Color(0xFF2EAD6E),
    'iconBg': Color(0xFFE5F7EF),
  },
  'Other': {
    'icon': Icons.more_horiz_rounded,
    'iconColor': Color(0xFFE6A817),
    'iconBg': Color(0xFFFFF5E0),
  },
};

// ─────────────────────────────────────────────────
//  Step Progress Model
// ─────────────────────────────────────────────────

/// The 9 canonical steps in the corrected order.
enum CaseStep {
  caseSubmitted,
  documentsUploaded,
  companyReview,
  lawyerAssignment,
  lawyerFeeReview,
  payment,
  lawyerContact,
  caseStarted,
  caseCompleted,
}

/// Human-readable labels for each step.
const Map<CaseStep, String> kStepLabels = {
  CaseStep.caseSubmitted: 'Case Submitted',
  CaseStep.documentsUploaded: 'Documents Uploaded',
  CaseStep.companyReview: 'Company Review',
  CaseStep.lawyerAssignment: 'Lawyer Assignment',
  CaseStep.lawyerFeeReview: 'Lawyer Fee Review',
  CaseStep.payment: 'Payment',
  CaseStep.lawyerContact: 'Lawyer Contact',
  CaseStep.caseStarted: 'Case Started',
  CaseStep.caseCompleted: 'Case Completed',
};

/// Firestore keys for each step (used in the `caseProgress` map).
const Map<CaseStep, String> kStepKeys = {
  CaseStep.caseSubmitted: 'caseSubmitted',
  CaseStep.documentsUploaded: 'documentsUploaded',
  CaseStep.companyReview: 'companyReview',
  CaseStep.lawyerAssignment: 'lawyerAssignment',
  CaseStep.lawyerFeeReview: 'lawyerFeeReview',
  CaseStep.payment: 'payment',
  CaseStep.lawyerContact: 'lawyerContact',
  CaseStep.caseStarted: 'caseStarted',
  CaseStep.caseCompleted: 'caseCompleted',
};

class StepProgressData {
  final CaseStepStatus status;
  final DateTime? completedAt;
  final String note;

  const StepProgressData({
    this.status = CaseStepStatus.pending,
    this.completedAt,
    this.note = '',
  });

  factory StepProgressData.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const StepProgressData();
    return StepProgressData(
      status: _parseStepStatus(map['status'] as String?),
      completedAt: _parseDateTime(map['completedAt']),
      note: (map['note'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'status': status.name,
        'completedAt': completedAt?.toIso8601String(),
        'note': note,
      };

  static CaseStepStatus _parseStepStatus(String? value) {
    switch (value) {
      case 'completed':
        return CaseStepStatus.completed;
      case 'inProgress':
        return CaseStepStatus.inProgress;
      default:
        return CaseStepStatus.pending;
    }
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}

// ─────────────────────────────────────────────────
//  Assigned Lawyer Model
// ─────────────────────────────────────────────────

class AssignedLawyer {
  final String name;
  final String specialization;
  final String photoUrl;
  final double fee;
  final String feeStatus; // 'pending_review' | 'reviewed' | 'paid'

  const AssignedLawyer({
    required this.name,
    required this.specialization,
    this.photoUrl = '',
    required this.fee,
    this.feeStatus = 'pending_review',
  });

  factory AssignedLawyer.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const AssignedLawyer(
          name: '', specialization: '', fee: 0, feeStatus: '');
    }
    return AssignedLawyer(
      name: (map['name'] as String?) ?? '',
      specialization: (map['specialization'] as String?) ?? '',
      photoUrl: (map['photoUrl'] as String?) ?? '',
      fee: (map['fee'] as num?)?.toDouble() ?? 0,
      feeStatus: (map['feeStatus'] as String?) ?? 'pending_review',
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'specialization': specialization,
        'photoUrl': photoUrl,
        'fee': fee,
        'feeStatus': feeStatus,
      };

  bool get isAssigned => name.isNotEmpty;
  bool get isPaid => feeStatus == 'paid';
  bool get isPendingPayment => isAssigned && !isPaid;
}

// ─────────────────────────────────────────────────
//  Status History Entry
// ─────────────────────────────────────────────────

class StatusHistoryEntry {
  final String status;
  final String message;
  final DateTime timestamp;

  const StatusHistoryEntry({
    required this.status,
    required this.message,
    required this.timestamp,
  });

  factory StatusHistoryEntry.fromMap(Map<String, dynamic> map) {
    DateTime ts;
    final rawTs = map['timestamp'];
    if (rawTs is Timestamp) {
      ts = rawTs.toDate();
    } else if (rawTs is String) {
      ts = DateTime.tryParse(rawTs) ?? DateTime.now();
    } else {
      ts = DateTime.now();
    }

    return StatusHistoryEntry(
      status: (map['status'] as String?) ?? '',
      message: (map['message'] as String?) ?? '',
      timestamp: ts,
    );
  }

  Map<String, dynamic> toMap() => {
        'status': status,
        'message': message,
        'timestamp': timestamp.toIso8601String(),
      };
}

// ─────────────────────────────────────────────────
//  Main Case Model
// ─────────────────────────────────────────────────

class CaseModel {
  final String docId; // Firestore document ID
  final String userId;
  final String caseId; // Human-readable, e.g. "LD-2505-00024"
  final String category;
  final String subCategory;
  final String shortDescription; // used as title
  final DateTime? issueDate;
  final String location;
  final String additionalInfo;
  final List<Map<String, dynamic>> documentUrls;
  final String budgetMin;
  final String budgetMax;
  final String lawyerLevel;
  final String status; // raw status string from Firestore
  final DateTime createdAt;

  // New fields
  final Map<CaseStep, StepProgressData> caseProgress;
  final AssignedLawyer assignedLawyer;
  final List<StatusHistoryEntry> statusHistory;
  final String estimatedAssignment;

  const CaseModel({
    required this.docId,
    required this.userId,
    required this.caseId,
    required this.category,
    required this.subCategory,
    required this.shortDescription,
    this.issueDate,
    required this.location,
    required this.additionalInfo,
    required this.documentUrls,
    required this.budgetMin,
    required this.budgetMax,
    required this.lawyerLevel,
    required this.status,
    required this.createdAt,
    required this.caseProgress,
    required this.assignedLawyer,
    required this.statusHistory,
    this.estimatedAssignment = 'Within 24 Hours',
  });

  // ── Factory from Firestore ──

  factory CaseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    // Parse createdAt
    DateTime createdAt;
    final rawCreated = data['createdAt'];
    if (rawCreated is Timestamp) {
      createdAt = rawCreated.toDate();
    } else if (rawCreated is String) {
      createdAt = DateTime.tryParse(rawCreated) ?? DateTime.now();
    } else {
      createdAt = DateTime.now();
    }

    // Parse issueDate
    DateTime? issueDate;
    final rawIssue = data['issueDate'];
    if (rawIssue is Timestamp) {
      issueDate = rawIssue.toDate();
    } else if (rawIssue is String) {
      issueDate = DateTime.tryParse(rawIssue);
    }

    // Parse caseProgress
    final progressMap =
        data['caseProgress'] as Map<String, dynamic>? ?? {};
    final Map<CaseStep, StepProgressData> progress = {};
    for (final step in CaseStep.values) {
      final key = kStepKeys[step]!;
      progress[step] =
          StepProgressData.fromMap(progressMap[key] as Map<String, dynamic>?);
    }

    // Parse statusHistory
    final historyRaw = data['statusHistory'] as List<dynamic>? ?? [];
    final history = historyRaw
        .map((e) => StatusHistoryEntry.fromMap(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp)); // newest first

    // Parse documentUrls
    final docsRaw = data['documentUrls'] as List<dynamic>? ?? [];
    final docs = docsRaw.map((e) => Map<String, dynamic>.from(e as Map)).toList();

    return CaseModel(
      docId: doc.id,
      userId: (data['userId'] as String?) ?? '',
      caseId: (data['caseId'] as String?) ?? doc.id,
      category: (data['category'] as String?) ?? '',
      subCategory: (data['subCategory'] as String?) ?? '',
      shortDescription: (data['shortDescription'] as String?) ?? '',
      issueDate: issueDate,
      location: (data['location'] as String?) ?? '',
      additionalInfo: (data['additionalInfo'] as String?) ?? '',
      documentUrls: docs,
      budgetMin: (data['budgetMin'] as String?) ?? '',
      budgetMax: (data['budgetMax'] as String?) ?? '',
      lawyerLevel: (data['lawyerLevel'] as String?) ?? '',
      status: (data['status'] as String?) ?? 'under_review',
      createdAt: createdAt,
      caseProgress: progress,
      assignedLawyer:
          AssignedLawyer.fromMap(data['assignedLawyer'] as Map<String, dynamic>?),
      statusHistory: history,
      estimatedAssignment:
          (data['estimatedAssignment'] as String?) ?? 'Within 24 Hours',
    );
  }

  // ── Derived getters ──

  /// Returns the human-readable category label for the card subtitle.
  String get categoryDisplayName =>
      kCategoryDisplayName[category] ?? category;

  /// Returns the icon for this case's category.
  IconData get categoryIcon =>
      (kCategoryVisuals[category]?['icon'] as IconData?) ??
      Icons.folder_outlined;

  /// Returns the icon color for this case's category.
  Color get categoryIconColor =>
      (kCategoryVisuals[category]?['iconColor'] as Color?) ??
      const Color(0xFF5C3FD3);

  /// Returns the icon background color.
  Color get categoryIconBg =>
      (kCategoryVisuals[category]?['iconBg'] as Color?) ??
      const Color(0xFFEEE9FB);

  /// Parsed high-level status for filter tabs.
  CaseStatus get caseStatus {
    switch (status) {
      case 'under_review':
      case 'pending_assignment':
        return CaseStatus.underReview;
      case 'active':
      case 'lawyer_assigned':
      case 'in_progress':
        return CaseStatus.active;
      case 'completed':
        return CaseStatus.completed;
      case 'rejected':
        return CaseStatus.rejected;
      case 'closed':
        return CaseStatus.closed;
      default:
        return CaseStatus.underReview;
    }
  }

  /// Display label for the status badge.
  String get statusLabel {
    switch (status) {
      case 'under_review':
      case 'pending_assignment':
        return 'Under Review';
      case 'active':
      case 'in_progress':
        return 'Case In Progress';
      case 'lawyer_assigned':
        return 'Lawyer Assigned';
      case 'completed':
        return 'Completed';
      case 'rejected':
        return 'Rejected';
      case 'closed':
        return 'Closed';
      default:
        return status;
    }
  }

  /// Color for the status badge.
  Color get statusColor {
    switch (caseStatus) {
      case CaseStatus.underReview:
        return const Color(0xFFE6A817);
      case CaseStatus.active:
        return const Color(0xFF2EAD6E);
      case CaseStatus.completed:
        return const Color(0xFF2EAD6E);
      case CaseStatus.rejected:
        return const Color(0xFFE05252);
      case CaseStatus.closed:
        return const Color(0xFF8E8E93);
    }
  }

  /// Dot color for the status badge (the small circle).
  Color get statusDotColor {
    switch (status) {
      case 'lawyer_assigned':
        return const Color(0xFF3A82C4);
      default:
        return statusColor;
    }
  }

  /// The most recent status history entry, or null.
  StatusHistoryEntry? get latestUpdate =>
      statusHistory.isNotEmpty ? statusHistory.first : null;

  /// Whether the case is in a terminal state (completed/closed).
  bool get isTerminal =>
      caseStatus == CaseStatus.completed || caseStatus == CaseStatus.closed;

  /// Number of uploaded documents.
  int get documentCount => documentUrls.length;
}

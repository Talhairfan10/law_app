/// Shared state model passed through the 5-step New Case flow.
/// Passed by reference via constructors — no ChangeNotifier needed.
class NewCaseData {
  // Step 1 — Category
  String category;
  String categoryIcon; // emoji or icon key
  String categoryDescription;

  // Step 2 — Details
  String subCategory;
  String shortDescription;
  DateTime? issueDate;
  String location;
  String additionalInfo;

  // Step 3 — Documents
  List<UploadedFileData> uploadedFiles;

  // Step 4 — Lawyer
  String budgetMin;
  String budgetMax;
  String lawyerLevel; // 'recommended' | 'senior' | 'most_senior'

  NewCaseData({
    this.category = '',
    this.categoryIcon = '',
    this.categoryDescription = '',
    this.subCategory = '',
    this.shortDescription = '',
    this.issueDate,
    this.location = '',
    this.additionalInfo = '',
    List<UploadedFileData>? uploadedFiles,
    this.budgetMin = '5,000',
    this.budgetMax = '25,000+',
    this.lawyerLevel = 'recommended',
  }) : uploadedFiles = uploadedFiles ?? [];

  Map<String, dynamic> toFirestore(String userId) {
    return {
      'userId': userId,
      'category': category,
      'subCategory': subCategory,
      'shortDescription': shortDescription,
      'issueDate': issueDate?.toIso8601String(),
      'location': location,
      'additionalInfo': additionalInfo,
      'documentUrls': uploadedFiles
          .map((f) => {'name': f.name, 'url': f.downloadUrl, 'size': f.sizeLabel})
          .toList(),
      'budgetMin': budgetMin,
      'budgetMax': budgetMax,
      'lawyerLevel': lawyerLevel,
      'status': 'pending_assignment',
      'createdAt': DateTime.now().toIso8601String(), // serverTimestamp used in service
    };
  }
}

class UploadedFileData {
  final String name;
  final String sizeLabel; // e.g. "1.2 MB"
  final String extension; // e.g. "pdf", "jpg"
  final String localPath; // local file path before upload
  String downloadUrl; // filled after Firebase Storage upload

  UploadedFileData({
    required this.name,
    required this.sizeLabel,
    required this.extension,
    required this.localPath,
    this.downloadUrl = '',
  });
}

/// Sub-categories for each of the 8 categories.
const Map<String, List<String>> kCategorySubcategories = {
  'Property / Land': [
    'Land Disputes',
    'Tenant Issues',
    'Property Fraud',
    'Boundary Dispute',
    'Possession Issues',
    'Transfer of Property',
    'Illegal Construction',
    'Inheritance / Will',
  ],
  'Family': [
    'Divorce / Khula',
    'Child Custody',
    'Maintenance / Alimony',
    'Domestic Violence',
    'Marriage Dispute',
    'Inheritance',
    'Guardian Issues',
    'Adoption',
  ],
  'Criminal': [
    'FIR / Case Registration',
    'Bail Application',
    'Anticipatory Bail',
    'Trial Defense',
    'Cyber Crime',
    'Fraud / Cheating',
    'Assault / Injury',
    'Theft / Robbery',
  ],
  'Employment': [
    'Wrongful Termination',
    'Salary Dispute',
    'Workplace Harassment',
    'Contract Dispute',
    'Provident Fund',
    'Gratuity Issues',
    'Labor Rights',
    'Service Matter',
  ],
  'Consumer Rights': [
    'Product Defect',
    'Service Complaint',
    'E-Commerce Dispute',
    'Insurance Claim',
    'Medical Negligence',
    'Banking Dispute',
    'Real Estate Fraud',
    'Warranty Issue',
  ],
  'Civil': [
    'Contract Dispute',
    'Money Recovery',
    'Defamation',
    'Injunction',
    'Specific Performance',
    'Tort / Negligence',
    'Partnership Dispute',
    'General Civil Suit',
  ],
  'Constitutional': [
    'Fundamental Rights',
    'Writ Petition',
    'Habeas Corpus',
    'Mandamus',
    'Quo Warranto',
    'Public Interest Litigation',
    'Government Action',
    'Civil Liberties',
  ],
  'Other': [
    'Tax Dispute',
    'Intellectual Property',
    'Immigration / Visa',
    'Environmental Issue',
    'Company / Business',
    'Regulatory Compliance',
    'Arbitration',
    'General Legal Advice',
  ],
};

/// Recommended documents per category (icon + label pairs).
const Map<String, List<Map<String, String>>> kCategoryDocuments = {
  'Property / Land': [
    {'icon': 'id_card', 'label': 'CNIC\nFront & Back'},
    {'icon': 'document', 'label': 'Property Deed\nSale / Registry'},
    {'icon': 'file', 'label': 'Mutation\nDocuments'},
    {'icon': 'map', 'label': 'Land Map'},
    {'icon': 'receipt', 'label': 'Property Tax\nReceipt'},
    {'icon': 'bill', 'label': 'Utility Bill\n(Address Proof)'},
    {'icon': 'plan', 'label': 'Site Plan'},
    {'icon': 'photo', 'label': 'Photos of\nProperty (Optional)'},
  ],
  'Family': [
    {'icon': 'id_card', 'label': 'CNIC\nFront & Back'},
    {'icon': 'certificate', 'label': 'Nikah Nama /\nMarriage Cert'},
    {'icon': 'document', 'label': 'Divorce\nDocuments'},
    {'icon': 'child', 'label': 'Birth\nCertificate'},
    {'icon': 'family', 'label': 'Family\nRegister'},
    {'icon': 'court', 'label': 'Court Order\n(if any)'},
    {'icon': 'bank', 'label': 'Bank\nStatements'},
    {'icon': 'photo', 'label': 'Photos\n(Optional)'},
  ],
  'Criminal': [
    {'icon': 'id_card', 'label': 'CNIC\nFront & Back'},
    {'icon': 'fir', 'label': 'FIR Copy'},
    {'icon': 'document', 'label': 'Witness\nStatements'},
    {'icon': 'medical', 'label': 'Medical\nReport'},
    {'icon': 'court', 'label': 'Court\nDocuments'},
    {'icon': 'bail', 'label': 'Bail\nDocuments'},
    {'icon': 'evidence', 'label': 'Evidence /\nPhotos'},
    {'icon': 'police', 'label': 'Police\nReport'},
  ],
  'Employment': [
    {'icon': 'id_card', 'label': 'CNIC\nFront & Back'},
    {'icon': 'contract', 'label': 'Employment\nContract'},
    {'icon': 'salary', 'label': 'Pay Slips /\nSalary Proof'},
    {'icon': 'letter', 'label': 'Termination\nLetter'},
    {'icon': 'document', 'label': 'Appointment\nLetter'},
    {'icon': 'bank', 'label': 'Bank\nStatements'},
    {'icon': 'email', 'label': 'Emails /\nCorrespondence'},
    {'icon': 'certificate', 'label': 'Experience\nLetter'},
  ],
  'Consumer Rights': [
    {'icon': 'id_card', 'label': 'CNIC\nFront & Back'},
    {'icon': 'receipt', 'label': 'Purchase\nReceipt'},
    {'icon': 'product', 'label': 'Product /\nWarranty Card'},
    {'icon': 'bank', 'label': 'Bank\nStatements'},
    {'icon': 'complaint', 'label': 'Complaint\nLetter'},
    {'icon': 'photo', 'label': 'Photos of\nDefect'},
    {'icon': 'email', 'label': 'Emails /\nMessages'},
    {'icon': 'contract', 'label': 'Service\nAgreement'},
  ],
  'Civil': [
    {'icon': 'id_card', 'label': 'CNIC\nFront & Back'},
    {'icon': 'contract', 'label': 'Contract /\nAgreement'},
    {'icon': 'document', 'label': 'Legal\nNotice'},
    {'icon': 'bank', 'label': 'Bank\nStatements'},
    {'icon': 'email', 'label': 'Correspondence\n/ Emails'},
    {'icon': 'receipt', 'label': 'Payment\nReceipts'},
    {'icon': 'court', 'label': 'Court\nOrders'},
    {'icon': 'witness', 'label': 'Witness\nDetails'},
  ],
  'Constitutional': [
    {'icon': 'id_card', 'label': 'CNIC\nFront & Back'},
    {'icon': 'document', 'label': 'Petition\nDraft'},
    {'icon': 'court', 'label': 'Court\nOrders'},
    {'icon': 'letter', 'label': 'Govt. Orders /\nNotices'},
    {'icon': 'evidence', 'label': 'Supporting\nEvidence'},
    {'icon': 'witness', 'label': 'Witness\nStatements'},
    {'icon': 'news', 'label': 'News / Media\nClippings'},
    {'icon': 'photo', 'label': 'Photos /\nVideos'},
  ],
  'Other': [
    {'icon': 'id_card', 'label': 'CNIC\nFront & Back'},
    {'icon': 'document', 'label': 'Relevant\nDocuments'},
    {'icon': 'contract', 'label': 'Agreements /\nContracts'},
    {'icon': 'email', 'label': 'Correspondence\n/ Emails'},
    {'icon': 'bank', 'label': 'Bank\nStatements'},
    {'icon': 'receipt', 'label': 'Receipts /\nInvoices'},
    {'icon': 'court', 'label': 'Court\nDocuments'},
    {'icon': 'photo', 'label': 'Photos /\nProof'},
  ],
};

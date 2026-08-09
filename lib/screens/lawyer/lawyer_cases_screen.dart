import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/case_service.dart';
import '../../models/case_model.dart';
import 'lawyer_case_details_screen.dart';

class LawyerCasesScreen extends StatefulWidget {
  const LawyerCasesScreen({super.key});

  @override
  State<LawyerCasesScreen> createState() => _LawyerCasesScreenState();
}

class _LawyerCasesScreenState extends State<LawyerCasesScreen>
    with SingleTickerProviderStateMixin {
  static const Color _navyDark = Color(0xFF0A1628);
  static const Color _gold = Color(0xFFD4A843);
  static const Color _textMuted = Color(0xFF8E99A4);
  static const Color _greenAccent = Color(0xFF2EAD6E);
  static const Color _blueAccent = Color(0xFF3A82C4);

  late TabController _tabController;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  String get _currentUid => FirebaseAuth.instance.currentUser?.uid ?? '';

  final List<String> _tabLabels = ['All', 'In Progress', 'Pending', 'Completed'];
  final List<List<String>> _tabStatuses = [
    [], // all
    ['active', 'in_progress', 'lawyer_assigned'],
    ['under_review', 'pending_assignment'],
    ['completed'],
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<CaseModel> _filterCases(List<CaseModel> cases) {
    var filtered = List<CaseModel>.from(cases);

    // Apply tab filter
    final activeTab = _tabController.index;
    if (activeTab > 0) {
      final statuses = _tabStatuses[activeTab];
      filtered = filtered.where((c) => statuses.contains(c.status)).toList();
    }

    // Apply search
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((c) {
        return c.caseId.toLowerCase().contains(q) ||
            c.category.toLowerCase().contains(q) ||
            c.categoryDisplayName.toLowerCase().contains(q) ||
            c.userId.toLowerCase().contains(q);
      }).toList();
    }

    return filtered;
  }

  Map<String, int> _computeTabCounts(List<CaseModel> cases) {
    int all = cases.length;
    int inProgress = cases.where((c) =>
        ['active', 'in_progress', 'lawyer_assigned'].contains(c.status)).length;
    int pending = cases.where((c) =>
        ['under_review', 'pending_assignment'].contains(c.status)).length;
    int completed = cases.where((c) => c.status == 'completed').length;
    return {
      'All': all,
      'In Progress': inProgress,
      'Pending': pending,
      'Completed': completed,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildSearchBar(),
            const SizedBox(height: 8),
            _buildCasesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          const SizedBox(width: 40), // balance for no back button from bottom nav
          const Expanded(
            child: Center(
              child: Text(
                'Assigned Cases',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0A1628),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              // Filter action placeholder
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.filter_list_rounded,
                  color: Color(0xFF0A1628), size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: Colors.grey.shade400, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                style: GoogleFonts.poppins(fontSize: 14, color: _navyDark),
                decoration: InputDecoration(
                  hintText: 'Search cases...',
                  hintStyle: GoogleFonts.poppins(
                      fontSize: 14, color: Colors.grey.shade400),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
                child: Icon(Icons.close, color: Colors.grey.shade400, size: 20),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCasesList() {
    return Expanded(
      child: StreamBuilder<List<CaseModel>>(
        stream: CaseService.getLawyerCases(_currentUid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
          }

          final allCases = snapshot.data ?? [];
          final tabCounts = _computeTabCounts(allCases);
          final filteredCases = _filterCases(allCases);

          return Column(
            children: [
              // Tab Bar with counts
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelColor: _blueAccent,
                  unselectedLabelColor: _textMuted,
                  labelStyle: GoogleFonts.poppins(
                      fontSize: 13, fontWeight: FontWeight.w600),
                  unselectedLabelStyle: GoogleFonts.poppins(
                      fontSize: 13, fontWeight: FontWeight.w400),
                  indicatorColor: _blueAccent,
                  indicatorSize: TabBarIndicatorSize.label,
                  dividerColor: Colors.transparent,
                  tabs: _tabLabels.map((label) {
                    final count = tabCounts[label] ?? 0;
                    return Tab(text: '$label ($count)');
                  }).toList(),
                ),
              ),

              // Case Cards List
              Expanded(
                child: filteredCases.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cases_outlined,
                                size: 48,
                                color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text(
                              'No cases found',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: _textMuted,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        itemCount: filteredCases.length,
                        itemBuilder: (context, index) {
                          return _buildCaseCard(filteredCases[index]);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCaseCard(CaseModel caseData) {
    final visuals = kCategoryVisuals[caseData.category];
    final iconData = (visuals?['icon'] as IconData?) ?? Icons.gavel_rounded;
    final iconColor = (visuals?['iconColor'] as Color?) ?? _gold;
    final iconBg = (visuals?['iconBg'] as Color?) ?? const Color(0xFFFFF5E0);

    // Status badge colors
    Color statusColor;
    Color statusBg;
    String statusText;
    switch (caseData.status) {
      case 'active':
      case 'in_progress':
      case 'lawyer_assigned':
        statusColor = _blueAccent;
        statusBg = const Color(0xFFE3F0FB);
        statusText = 'In Progress';
        break;
      case 'completed':
        statusColor = _greenAccent;
        statusBg = const Color(0xFFE5F7EF);
        statusText = 'Completed';
        break;
      case 'under_review':
      case 'pending_assignment':
        statusColor = _gold;
        statusBg = const Color(0xFFFFF5E0);
        statusText = 'Pending';
        break;
      default:
        statusColor = _textMuted;
        statusBg = Colors.grey.shade100;
        statusText = caseData.statusLabel;
    }

    // Format assigned date
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final assignedDate = '${caseData.createdAt.day.toString().padLeft(2, '0')} '
        '${months[caseData.createdAt.month - 1]} ${caseData.createdAt.year}';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LawyerCaseDetailsScreen(caseDocId: caseData.docId),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
            // Category icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(iconData, color: iconColor, size: 24),
            ),
            const SizedBox(width: 14),

            // Case info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    caseData.categoryDisplayName,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _navyDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Case ID: ${caseData.caseId}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: _textMuted,
                    ),
                  ),
                  Text(
                    'Client ID: ${caseData.userId.length > 8 ? 'CLT-${caseData.userId.substring(0, 4).toUpperCase()}' : caseData.userId}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: _textMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      statusText,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Right info column
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Assigned date
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 12, color: _textMuted),
                    const SizedBox(width: 4),
                    Text(
                      'Assigned Date',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: _textMuted,
                      ),
                    ),
                  ],
                ),
                Text(
                  assignedDate,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _navyDark,
                  ),
                ),
                const SizedBox(height: 10),
                // Current Stage
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.flag_outlined,
                        size: 12, color: _textMuted),
                    const SizedBox(width: 4),
                    Text(
                      'Current Stage',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: _textMuted,
                      ),
                    ),
                  ],
                ),
                Text(
                  caseData.stageLabel,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _navyDark,
                  ),
                ),
              ],
            ),

            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: _textMuted, size: 22),
          ],
        ),
      ),
    );
  }
}

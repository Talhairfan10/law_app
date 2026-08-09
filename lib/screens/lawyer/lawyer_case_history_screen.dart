import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/case_service.dart';
import '../../models/case_model.dart';
import 'lawyer_case_details_screen.dart';

/// Full case history for the lawyer — shows ALL cases (completed, closed,
/// in progress) with filter tabs and search. This is accessed from the
/// Lawyer Profile or Dashboard.
class LawyerCaseHistoryScreen extends StatefulWidget {
  const LawyerCaseHistoryScreen({super.key});

  @override
  State<LawyerCaseHistoryScreen> createState() =>
      _LawyerCaseHistoryScreenState();
}

class _LawyerCaseHistoryScreenState extends State<LawyerCaseHistoryScreen>
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

  final List<String> _tabLabels = ['All', 'Completed', 'Closed', 'Active'];
  final List<List<String>> _tabStatuses = [
    [], // all
    ['completed'],
    ['closed'],
    ['active', 'in_progress', 'lawyer_assigned'],
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

    final activeTab = _tabController.index;
    if (activeTab > 0) {
      final statuses = _tabStatuses[activeTab];
      filtered = filtered.where((c) => statuses.contains(c.status)).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((c) {
        return c.caseId.toLowerCase().contains(q) ||
            c.category.toLowerCase().contains(q) ||
            c.categoryDisplayName.toLowerCase().contains(q);
      }).toList();
    }

    return filtered;
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
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back, color: _navyDark, size: 20),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Case History',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _navyDark,
                ),
              ),
            ),
          ),
          const SizedBox(width: 40),
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
                  hintText: 'Search case history...',
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
                child:
                    Icon(Icons.close, color: Colors.grey.shade400, size: 20),
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
            return const Center(
                child: CircularProgressIndicator(strokeWidth: 2));
          }

          final allCases = snapshot.data ?? [];
          final filteredCases = _filterCases(allCases);

          return Column(
            children: [
              // Tabs
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
                  tabs: _tabLabels.map((l) => Tab(text: l)).toList(),
                ),
              ),

              Expanded(
                child: filteredCases.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history,
                                size: 48, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text(
                              'No cases found',
                              style: GoogleFonts.poppins(
                                  fontSize: 14, color: _textMuted),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        itemCount: filteredCases.length,
                        itemBuilder: (context, index) {
                          return _buildHistoryCard(filteredCases[index]);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard(CaseModel c) {
    // Status badge
    Color statusColor;
    String statusText;
    switch (c.status) {
      case 'completed':
        statusColor = _greenAccent;
        statusText = 'Completed';
        break;
      case 'closed':
        statusColor = _textMuted;
        statusText = 'Closed';
        break;
      case 'active':
      case 'in_progress':
      case 'lawyer_assigned':
        statusColor = _blueAccent;
        statusText = 'Active';
        break;
      default:
        statusColor = _gold;
        statusText = c.statusLabel;
    }

    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final dateStr = '${c.createdAt.day} ${months[c.createdAt.month - 1]} ${c.createdAt.year}';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                LawyerCaseDetailsScreen(caseDocId: c.docId),
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: c.categoryIconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(c.categoryIcon,
                  color: c.categoryIconColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.categoryDisplayName,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _navyDark,
                    ),
                  ),
                  Text(
                    'Case ID: ${c.caseId}',
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: _textMuted),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        statusText,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  dateStr,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: _navyDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  c.stageLabel,
                  style: GoogleFonts.poppins(
                      fontSize: 10, color: _textMuted),
                ),
              ],
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, color: _textMuted, size: 22),
          ],
        ),
      ),
    );
  }
}

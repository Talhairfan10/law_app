import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/case_model.dart';
import '../services/case_service.dart';
import 'track_case_screen.dart';
import 'placeholders.dart';

class MyCasesScreen extends StatefulWidget {
  const MyCasesScreen({super.key});

  @override
  State<MyCasesScreen> createState() => _MyCasesScreenState();
}

class _MyCasesScreenState extends State<MyCasesScreen> {
  static const Color _primary = Color(0xFF5C3FD3);
  static const Color _dark = Color(0xFF1A1A2E);
  static const Color _grey = Color(0xFF8E8E93);
  static const Color _bg = Color(0xFFFAFAFA);

  String _searchQuery = '';
  int _selectedFilter = 0; // 0=All, 1=Under Review, 2=Active, 3=Completed, 4=Rejected
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filterLabels = [
    'All',
    'Under Review',
    'Active',
    'Completed',
    'Rejected',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Filters cases based on search query and selected tab.
  List<CaseModel> _filterCases(List<CaseModel> cases) {
    var filtered = cases;

    // Filter by status tab
    if (_selectedFilter != 0) {
      final CaseStatus targetStatus;
      switch (_selectedFilter) {
        case 1:
          targetStatus = CaseStatus.underReview;
          break;
        case 2:
          targetStatus = CaseStatus.active;
          break;
        case 3:
          targetStatus = CaseStatus.completed;
          break;
        case 4:
          targetStatus = CaseStatus.rejected;
          break;
        default:
          targetStatus = CaseStatus.underReview;
      }
      filtered = filtered.where((c) => c.caseStatus == targetStatus).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((c) {
        return c.caseId.toLowerCase().contains(q) ||
            c.category.toLowerCase().contains(q) ||
            c.categoryDisplayName.toLowerCase().contains(q) ||
            c.shortDescription.toLowerCase().contains(q);
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(userId),
            _buildSearchBar(),
            _buildFilterTabs(),
            Expanded(
              child: userId == null
                  ? _buildEmptyState('Please sign in to view your cases.')
                  : _buildCasesList(userId),
            ),
            _buildNeedHelpBanner(),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────
  //  Header with notification bell
  // ─────────────────────────────────────────────────

  Widget _buildHeader(String? userId) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Cases',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: _dark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'View and track all your legal cases',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: _grey,
                  ),
                ),
              ],
            ),
          ),
          // Notification bell with unread count badge
          _buildNotificationBell(userId),
        ],
      ),
    );
  }

  Widget _buildNotificationBell(String? userId) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const PlaceholderScreen(title: 'Notifications'),
          ),
        );
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: _dark,
              size: 24,
            ),
          ),
          if (userId != null)
            StreamBuilder<int>(
              stream: CaseService.getUnreadNotificationCount(userId),
              builder: (context, snapshot) {
                final count = snapshot.data ?? 0;
                if (count == 0) return const SizedBox.shrink();
                return Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE05252),
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      count > 9 ? '9+' : count.toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────
  //  Search Bar
  // ─────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                style: GoogleFonts.poppins(fontSize: 14, color: _dark),
                decoration: InputDecoration(
                  hintText: 'Search by Case ID or Category',
                  hintStyle: GoogleFonts.poppins(fontSize: 14, color: _grey),
                  prefixIcon:
                      const Icon(Icons.search, color: _grey, size: 22),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, color: _grey, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE0E0E0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  // Filter icon tap — could open advanced filter sheet
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      Icon(Icons.tune_rounded,
                          color: _primary, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Filter',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────
  //  Filter Tabs
  // ─────────────────────────────────────────────────

  Widget _buildFilterTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 14, 0, 6),
      child: SizedBox(
        height: 38,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _filterLabels.length,
          itemBuilder: (context, index) {
            final isSelected = _selectedFilter == index;
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedFilter = index;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? _primary : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? _primary : const Color(0xFFE0E0E0),
                    ),
                  ),
                  child: Text(
                    _filterLabels[index],
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? Colors.white : _dark,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────
  //  Cases List (StreamBuilder)
  // ─────────────────────────────────────────────────

  Widget _buildCasesList(String userId) {
    return StreamBuilder<List<CaseModel>>(
      stream: CaseService.getUserCases(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: _primary),
          );
        }

        if (snapshot.hasError) {
          return _buildEmptyState(
              'Something went wrong.\nPlease try again later.');
        }

        final allCases = snapshot.data ?? [];
        if (allCases.isEmpty) {
          return _buildEmptyState(
            'You haven\'t submitted any cases yet.\nTap "New Case" on the home screen to get started.',
          );
        }

        final filtered = _filterCases(allCases);
        if (filtered.isEmpty) {
          return _buildEmptyState(
            _searchQuery.isNotEmpty
                ? 'No cases match your search.\nTry a different Case ID or category.'
                : 'No cases in this category.',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          itemCount: filtered.length,
          separatorBuilder: (context, index) => const SizedBox(height: 2),
          itemBuilder: (context, index) {
            return _CaseCard(
              caseData: filtered[index],
              onTrackCase: () => _navigateToTrackCase(filtered[index]),
              onViewDetails: () => _navigateToViewDetails(filtered[index]),
            );
          },
        );
      },
    );
  }

  // ─────────────────────────────────────────────────
  //  Empty State
  // ─────────────────────────────────────────────────

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFF0ECFD),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.folder_open_rounded,
                color: _primary,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Cases Found',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _dark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: _grey,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────
  //  Need Help Banner
  // ─────────────────────────────────────────────────

  Widget _buildNeedHelpBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0ECFD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: _primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chat_bubble_outline_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need help with your cases?',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _dark,
                  ),
                ),
                Text(
                  'Our support team is here to assist you.',
                  style: GoogleFonts.poppins(fontSize: 11, color: _grey),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const PlaceholderScreen(title: 'Contact Support'),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: _primary,
              side: const BorderSide(color: _primary),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Contact Support',
              style: GoogleFonts.poppins(
                  fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────
  //  Navigation
  // ─────────────────────────────────────────────────

  void _navigateToTrackCase(CaseModel caseData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TrackCaseScreen(caseDocId: caseData.docId),
      ),
    );
  }

  void _navigateToViewDetails(CaseModel caseData) {
    // For completed/closed cases — navigate to track case for now
    // (can be replaced with a dedicated CaseDetailScreen later)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TrackCaseScreen(caseDocId: caseData.docId),
      ),
    );
  }
}

// ─────────────────────────────────────────────────
//  Case Card Widget
// ─────────────────────────────────────────────────

class _CaseCard extends StatelessWidget {
  final CaseModel caseData;
  final VoidCallback onTrackCase;
  final VoidCallback onViewDetails;

  static const Color _dark = Color(0xFF1A1A2E);
  static const Color _grey = Color(0xFF8E8E93);
  static const Color _primary = Color(0xFF5C3FD3);

  const _CaseCard({
    required this.caseData,
    required this.onTrackCase,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final isTerminal = caseData.isTerminal;
    final formattedDate = DateFormat('dd MMM yyyy').format(caseData.createdAt);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: icon + title + status badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: caseData.categoryIconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  caseData.categoryIcon,
                  color: caseData.categoryIconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),

              // Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      caseData.shortDescription,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _dark,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Status badge
              _buildStatusBadge(),
            ],
          ),
          const SizedBox(height: 12),

          // Case ID row
          _buildInfoRow(Icons.confirmation_number_outlined,
              'Case ID: ${caseData.caseId}', isBold: true),
          const SizedBox(height: 6),

          // Submitted date
          _buildInfoRow(
              Icons.calendar_today_outlined, 'Submitted: $formattedDate'),
          const SizedBox(height: 6),

          // Category
          _buildInfoRow(Icons.folder_outlined,
              'Category: ${caseData.categoryDisplayName}'),

          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          const SizedBox(height: 10),

          // Action link
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: isTerminal ? onViewDetails : onTrackCase,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isTerminal ? 'View Details' : 'Track Case',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_ios_rounded,
                      color: _primary, size: 14),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: caseData.statusColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: caseData.statusDotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            caseData.statusLabel,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: caseData.statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {bool isBold = false}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: _grey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
              color: isBold ? _primary : _grey,
            ),
          ),
        ),
      ],
    );
  }
}

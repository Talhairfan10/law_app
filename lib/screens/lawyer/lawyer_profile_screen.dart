import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/case_service.dart';
import '../../services/auth_service.dart';
import '../landing_screen.dart';
import 'lawyer_case_history_screen.dart';

/// Lawyer Profile screen — Phase 4 will add fl_chart pie chart
/// and full field editing. This is a functional stub with real data.
class LawyerProfileScreen extends StatefulWidget {
  const LawyerProfileScreen({super.key});

  @override
  State<LawyerProfileScreen> createState() => _LawyerProfileScreenState();
}

class _LawyerProfileScreenState extends State<LawyerProfileScreen> {
  static const Color _navyDark = Color(0xFF0A1628);
  static const Color _navyMedium = Color(0xFF0F1D32);
  static const Color _gold = Color(0xFFD4A843);
  static const Color _white = Colors.white;
  static const Color _textMuted = Color(0xFF8E99A4);
  static const Color _greenAccent = Color(0xFF2EAD6E);
  static const Color _blueAccent = Color(0xFF3A82C4);

  Map<String, dynamic>? _profileData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (mounted && doc.exists) {
        setState(() {
          _profileData = doc.data();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    final data = _profileData ?? {};
    final name = data['fullName'] as String? ?? 'Lawyer';
    final email = data['email'] as String? ?? '';
    final phone = data['phoneNumber'] as String? ?? '';
    final title = data['title'] as String? ?? 'Advocate High Court';
    final enrollmentNo = data['enrollmentNo'] as String? ?? '';
    final barCouncil = data['barCouncil'] as String? ?? '';
    final officeAddress = data['officeAddress'] as String? ?? '';
    final specialization = (data['specialization'] as List<dynamic>?)?.join(', ') ?? '';
    final languages = (data['languages'] as List<dynamic>?)?.join(', ') ?? 'English, Urdu';
    final experience = data['experienceYears'] as String? ?? '';
    final memberships = (data['memberships'] as List<dynamic>?)?.join(', ') ?? '';
    final photoUrl = data['photoUrl'] as String?;
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  const SizedBox(width: 40),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Profile',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: _navyDark,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Edit profile placeholder
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.edit_outlined,
                          color: _navyDark, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            // Profile Header Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_navyDark, _navyMedium],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: _gold.withValues(alpha: 0.2),
                      backgroundImage:
                          photoUrl != null ? NetworkImage(photoUrl) : null,
                      child: photoUrl == null
                          ? Text(
                              name.isNotEmpty ? name[0].toUpperCase() : 'L',
                              style: GoogleFonts.poppins(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: _gold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Adv. $name',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: _white,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(Icons.verified,
                                  color: _blueAccent, size: 18),
                            ],
                          ),
                          if (title.isNotEmpty)
                            Text(
                              title,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: _white.withValues(alpha: 0.7),
                              ),
                            ),
                          if (enrollmentNo.isNotEmpty)
                            Text(
                              'Enrollment No: $enrollmentNo',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: _textMuted,
                              ),
                            ),
                          if (barCouncil.isNotEmpty)
                            Text(
                              barCouncil,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: _textMuted,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Stats Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildProfileStat(
                    Icons.cases_outlined,
                    'Total Cases',
                    CaseService.getLawyerCaseCount(uid),
                  ),
                  const SizedBox(width: 8),
                  _buildProfileStat(
                    Icons.pending_actions,
                    'Active',
                    CaseService.getLawyerCaseCountByStatus(
                        uid, ['active', 'in_progress', 'lawyer_assigned']),
                    color: _blueAccent,
                  ),
                  const SizedBox(width: 8),
                  _buildProfileStat(
                    Icons.check_circle_outline,
                    'Completed',
                    CaseService.getLawyerCaseCountByStatus(uid, ['completed']),
                    color: _greenAccent,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Personal Information
            _buildSectionCard(
              'Personal Information',
              Icons.person_outline,
              [
                _profileRow(Icons.person_outline, 'Full Name', 'Adv. $name'),
                _profileRow(Icons.email_outlined, 'Email', email),
                _profileRow(Icons.phone_outlined, 'Phone', phone),
                if (officeAddress.isNotEmpty)
                  _profileRow(
                      Icons.location_on_outlined, 'Office', officeAddress),
                if (specialization.isNotEmpty)
                  _profileRow(Icons.school_outlined, 'Specialization',
                      specialization),
                if (languages.isNotEmpty)
                  _profileRow(
                      Icons.language_outlined, 'Languages', languages),
                if (experience.isNotEmpty)
                  _profileRow(
                      Icons.work_history_outlined, 'Experience', experience),
                if (memberships.isNotEmpty)
                  _profileRow(
                      Icons.badge_outlined, 'Memberships', memberships),
              ],
            ),

            const SizedBox(height: 16),

            // Quick Links
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Case Statistics',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _navyDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCaseStatisticsChart(uid),
                  const SizedBox(height: 24),
                  Text(
                    'Quick Links',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _navyDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildQuickLink(
                    icon: Icons.history_rounded,
                    title: 'Case History',
                    subtitle: 'View all completed & past cases',
                    color: _blueAccent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LawyerCaseHistoryScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await AuthService.signOut();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const LandingScreen()),
                        (route) => false,
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.logout, size: 20),
                  label: Text(
                    'Logout',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileStat(IconData icon, String label, Stream<int> stream,
      {Color color = _gold}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            StreamBuilder<int>(
              stream: stream,
              builder: (context, snapshot) {
                return Text(
                  '${snapshot.data ?? 0}',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _navyDark,
                  ),
                );
              },
            ),
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 11, color: _textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(
      String title, IconData icon, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(18),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: _navyDark),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _navyDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _profileRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: _textMuted),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: _textMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: _navyDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaseStatisticsChart(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('cases')
          .where('lawyerId', isEqualTo: uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        int active = 0;
        int completed = 0;
        int pending = 0; // Other statuses

        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final status = data['status'] as String? ?? '';
          if (['active', 'in_progress', 'lawyer_assigned'].contains(status)) {
            active++;
          } else if (status == 'completed') {
            completed++;
          } else {
            pending++;
          }
        }

        final total = active + completed + pending;
        if (total == 0) {
          return Container(
            height: 200,
            alignment: Alignment.center,
            child: Text(
              'No cases yet.',
              style: GoogleFonts.poppins(color: _textMuted),
            ),
          );
        }

        return Container(
          height: 220,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 30,
                    sections: [
                      if (active > 0)
                        PieChartSectionData(
                          color: _blueAccent,
                          value: active.toDouble(),
                          title: '${((active / total) * 100).toInt()}%',
                          radius: 40,
                          titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      if (completed > 0)
                        PieChartSectionData(
                          color: _greenAccent,
                          value: completed.toDouble(),
                          title: '${((completed / total) * 100).toInt()}%',
                          radius: 40,
                          titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      if (pending > 0)
                        PieChartSectionData(
                          color: _gold,
                          value: pending.toDouble(),
                          title: '${((pending / total) * 100).toInt()}%',
                          radius: 40,
                          titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLegendIndicator(_blueAccent, 'Active ($active)'),
                  const SizedBox(height: 8),
                  _buildLegendIndicator(_greenAccent, 'Completed ($completed)'),
                  const SizedBox(height: 8),
                  _buildLegendIndicator(_gold, 'Pending ($pending)'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegendIndicator(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: _navyDark,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickLink({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _navyDark,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: _textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 22, color: _textMuted),
          ],
        ),
      ),
    );
  }
}

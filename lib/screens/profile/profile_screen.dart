import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../services/user_service.dart';
import '../../services/notification_service.dart';
import 'edit_profile_screen.dart';
import 'security_screen.dart';
import 'address_screen.dart';
import 'payment_methods_screen.dart';
import 'notification_preferences_screen.dart';
import 'language_screen.dart';
import 'help_support_screen.dart';
import 'faqs_screen.dart';
import 'terms_conditions_screen.dart';
import 'privacy_policy_screen.dart';
import '../../services/auth_service.dart';
import '../landing_screen.dart';
import '../alerts_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color _primary = Color(0xFF6C5CE7);
  static const Color _dark = Color(0xFF1A1A2E);
  static const Color _gray = Color(0xFF8E8E93);
  static const Color _bg = Color(0xFFFAFAFA);

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  bool _isUploadingPhoto = false;

  Future<void> _pickAndUploadPhoto() async {
    final userId = _userId;
    if (userId == null) return;

    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );

    if (image == null) return;

    setState(() => _isUploadingPhoto = true);
    try {
      await UserService.uploadProfilePhoto(userId, File(image.path));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile photo updated!', style: GoogleFonts.poppins()),
            backgroundColor: _primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload photo.', style: GoogleFonts.poppins()),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Logout', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text(
          'Are you sure you want to log out?',
          style: GoogleFonts.poppins(color: _gray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: _gray, fontWeight: FontWeight.w500)),
          ),
          TextButton(
            onPressed: () async {
              final nav = Navigator.of(context);
              nav.pop(); // Close dialog
              await AuthService.signOut();
              nav.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LandingScreen()),
                (route) => false,
              );
            },
            child: Text('Logout',
                style: GoogleFonts.poppins(
                    color: Colors.redAccent, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = _userId;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: userId == null
            ? const Center(child: CircularProgressIndicator())
            : StreamBuilder<Map<String, dynamic>>(
                stream: UserService.getUserStream(userId),
                builder: (context, snapshot) {
                  final userData = snapshot.data ?? {};
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildHeader(userId),
                        const SizedBox(height: 8),
                        _buildUserInfoCard(userData, userId),
                        const SizedBox(height: 20),
                        _buildStatsRow(userId),
                        const SizedBox(height: 20),
                        _buildSettingsSection(),
                        const SizedBox(height: 12),
                        _buildSupportSection(),
                        const SizedBox(height: 30),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  // ───────────────────────────────────────────────
  //  Header
  // ───────────────────────────────────────────────

  Widget _buildHeader(String userId) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
      child: Row(
        children: [
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu, color: _dark, size: 28),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Profile',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _dark,
            ),
          ),
          const Spacer(),
          // Notification bell with live badge
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AlertsScreen()),
              );
            },
            child: StreamBuilder<int>(
              stream: NotificationService.getUnreadCount(userId),
              builder: (context, snapshot) {
                final unread = snapshot.data ?? 0;
                return Stack(
                  children: [
                    const Icon(Icons.notifications_none_rounded,
                        color: _dark, size: 30),
                    if (unread > 0)
                      Positioned(
                        right: 1,
                        top: 1,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: _primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: _bg, width: 2),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────
  //  User Info Card
  // ───────────────────────────────────────────────

  Widget _buildUserInfoCard(Map<String, dynamic> userData, String userId) {
    final name = userData['fullName'] as String? ??
        FirebaseAuth.instance.currentUser?.displayName ??
        'User';
    final email = userData['email'] as String? ??
        FirebaseAuth.instance.currentUser?.email ??
        '';
    final phone = userData['phoneNumber'] as String? ?? '';
    final photoUrl = userData['photoUrl'] as String? ??
        FirebaseAuth.instance.currentUser?.photoURL;
    final isVerified = userData['isVerified'] as bool? ??
        (FirebaseAuth.instance.currentUser?.emailVerified ?? false);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EditProfileScreen()),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Profile photo with camera button
              Stack(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: const Color(0xFFE0E0E0),
                    backgroundImage:
                        photoUrl != null ? NetworkImage(photoUrl) : null,
                    child: photoUrl == null
                        ? const Icon(Icons.person, size: 38, color: Color(0xFF9E9E9E))
                        : null,
                  ),
                  if (_isUploadingPhoto)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickAndUploadPhoto,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: _primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),

              // User info text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: _dark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: GoogleFonts.poppins(fontSize: 12, color: _gray),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (phone.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.phone_outlined,
                              size: 13, color: _gray),
                          const SizedBox(width: 4),
                          Text(
                            phone,
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: _gray),
                          ),
                        ],
                      ),
                    ],
                    if (isVerified) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.verified_rounded,
                                size: 14, color: Color(0xFF4CAF50)),
                            const SizedBox(width: 4),
                            Text(
                              'Verified Account',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF4CAF50),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const Icon(Icons.chevron_right_rounded,
                  color: Color(0xFFBDBDBD), size: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────
  //  Stats Row
  // ───────────────────────────────────────────────

  Widget _buildStatsRow(String userId) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // My Cases
            Expanded(
              child: StreamBuilder<int>(
                stream: UserService.getCaseCount(userId),
                builder: (_, snap) => _buildStatItem(
                  icon: Icons.work_outline_rounded,
                  iconColor: _primary,
                  value: '${snap.data ?? 0}',
                  label: 'My Cases',
                ),
              ),
            ),
            _statDivider(),
            // Total Payments
            Expanded(
              child: StreamBuilder<double>(
                stream: UserService.getTotalPayments(userId),
                builder: (_, snap) {
                  final val = snap.data ?? 0;
                  final formatted = val > 0
                      ? 'PKR ${NumberFormat('#,###').format(val.toInt())}'
                      : 'PKR 0';
                  return _buildStatItem(
                    icon: Icons.account_balance_wallet_outlined,
                    iconColor: const Color(0xFF4CAF50),
                    value: formatted,
                    label: 'Total Payments',
                  );
                },
              ),
            ),
            _statDivider(),
            // Messages
            Expanded(
              child: StreamBuilder<int>(
                stream: UserService.getMessagesCount(userId),
                builder: (_, snap) => _buildStatItem(
                  icon: Icons.chat_bubble_outline_rounded,
                  iconColor: const Color(0xFFF5A623),
                  value: '${snap.data ?? 0}',
                  label: 'Messages',
                ),
              ),
            ),
            _statDivider(),
            // Documents
            Expanded(
              child: StreamBuilder<int>(
                stream: UserService.getTotalDocumentsCount(userId),
                builder: (_, snap) => _buildStatItem(
                  icon: Icons.description_outlined,
                  iconColor: const Color(0xFF3A82C4),
                  value: '${snap.data ?? 0}',
                  label: 'Documents',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: _dark,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 10, color: _gray),
          textAlign: TextAlign.center,
          maxLines: 1,
        ),
      ],
    );
  }

  Widget _statDivider() {
    return Container(
      width: 1,
      height: 40,
      color: const Color(0xFFEEEEEE),
    );
  }

  // ───────────────────────────────────────────────
  //  Settings Section
  // ───────────────────────────────────────────────

  Widget _buildSettingsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildSettingsItem(
              icon: Icons.person_outline_rounded,
              title: 'Personal Information',
              subtitle: 'View and update your personal details',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const EditProfileScreen())),
            ),
            _divider(),
            _buildSettingsItem(
              icon: Icons.shield_outlined,
              title: 'Security',
              subtitle: 'Change password, and security settings',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SecurityScreen())),
            ),
            _divider(),
            _buildSettingsItem(
              icon: Icons.location_on_outlined,
              title: 'Address',
              subtitle: 'Manage your address information',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AddressScreen())),
            ),
            _divider(),
            _buildSettingsItem(
              icon: Icons.credit_card_rounded,
              title: 'Payment Methods',
              subtitle: 'Manage your saved cards and accounts',
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const PaymentMethodsScreen())),
            ),
            _divider(),
            _buildSettingsItem(
              icon: Icons.notifications_outlined,
              title: 'Notification Preferences',
              subtitle: 'Manage your notification settings',
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const NotificationPreferencesScreen())),
            ),
            _divider(),
            _buildSettingsItem(
              icon: Icons.language_rounded,
              title: 'Language',
              subtitle: 'English',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const LanguageScreen())),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────
  //  Support Section
  // ───────────────────────────────────────────────

  Widget _buildSupportSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildSettingsItem(
              icon: Icons.headset_mic_outlined,
              title: 'Help & Support',
              subtitle: 'Get help and contact support',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const HelpSupportScreen())),
            ),
            _divider(),
            _buildSettingsItem(
              icon: Icons.help_outline_rounded,
              title: 'FAQs',
              subtitle: 'Find answers to common questions',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const FaqsScreen())),
            ),
            _divider(),
            _buildSettingsItem(
              icon: Icons.description_outlined,
              title: 'Terms & Conditions',
              subtitle: 'Read our terms and conditions',
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const TermsConditionsScreen())),
            ),
            _divider(),
            _buildSettingsItem(
              icon: Icons.verified_user_outlined,
              title: 'Privacy Policy',
              subtitle: 'Read our privacy policy',
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const PrivacyPolicyScreen())),
            ),
            _divider(),
            _buildSettingsItem(
              icon: Icons.logout_rounded,
              iconColor: Colors.redAccent,
              title: 'Log Out',
              titleColor: Colors.redAccent,
              subtitle: 'Sign out from your account',
              onTap: _showLogoutDialog,
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────
  //  Shared Widgets
  // ───────────────────────────────────────────────

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Color? titleColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (iconColor ?? _primary).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor ?? _primary, size: 20),
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
                      color: titleColor ?? _dark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(fontSize: 11, color: _gray),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: Color(0xFFBDBDBD), size: 22),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, color: Colors.grey.shade100),
    );
  }
}

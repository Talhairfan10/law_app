import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LawyerSettingsScreen extends StatelessWidget {
  const LawyerSettingsScreen({super.key});

  static const Color _navyDark = Color(0xFF0A1628);
  static const Color _textMuted = Color(0xFF8E99A4);
  static const Color _gold = Color(0xFFD4A843);
  static const Color _red = Color(0xFFE74C3C);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: _navyDark),
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _navyDark,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionHeader('Account Security'),
          _buildSettingsTile(
            icon: Icons.lock_outline,
            title: 'Change Password',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Change Password coming soon')));
            },
          ),
          _buildSettingsTile(
            icon: Icons.security,
            title: 'Two-Factor Authentication',
            subtitle: 'Recommended for extra security',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('2FA coming soon')));
            },
          ),
          const SizedBox(height: 24),
          
          _buildSectionHeader('App Preferences'),
          _buildSettingsTile(
            icon: Icons.notifications_none,
            title: 'Push Notifications',
            onTap: () {},
            trailing: Switch(
              value: true,
              activeThumbColor: _gold,
              onChanged: (val) {},
            ),
          ),
          _buildSettingsTile(
            icon: Icons.language,
            title: 'Language',
            subtitle: 'English',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.dark_mode_outlined,
            title: 'Dark Mode',
            onTap: () {},
            trailing: Switch(
              value: false,
              activeThumbColor: _gold,
              onChanged: (val) {},
            ),
          ),
          const SizedBox(height: 24),

          _buildSectionHeader('Support & About'),
          _buildSettingsTile(
            icon: Icons.help_outline,
            title: 'Help Center',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () {},
          ),
          const SizedBox(height: 32),

          Center(
            child: TextButton.icon(
              onPressed: () {
                // Should route to logout
              },
              icon: const Icon(Icons.logout, color: _red),
              label: Text(
                'Log Out',
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.w600, color: _red),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              'App Version 1.0.0',
              style: GoogleFonts.poppins(fontSize: 12, color: _textMuted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: _textMuted,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _navyDark.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: _navyDark, size: 22),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _navyDark,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: _textMuted,
                ),
              )
            : null,
        trailing: trailing ?? const Icon(Icons.chevron_right, color: _textMuted),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/user_service.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen> {
  static const Color _primary = Color(0xFF6C5CE7);
  static const Color _dark = Color(0xFF1A1A2E);
  static const Color _gray = Color(0xFF8E8E93);

  bool _pushEnabled = true;
  bool _emailEnabled = true;
  bool _smsEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final data = await UserService.getUserData(userId);
    final prefs = data['preferences'] as Map<String, dynamic>?;
    if (mounted) {
      setState(() {
        if (prefs != null) {
          _pushEnabled = prefs['pushNotifications'] as bool? ?? true;
          _emailEnabled = prefs['emailNotifications'] as bool? ?? true;
          _smsEnabled = prefs['smsNotifications'] as bool? ?? false;
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _savePreferences() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    await UserService.savePreferences(
      userId,
      pushNotifications: _pushEnabled,
      emailNotifications: _emailEnabled,
      smsNotifications: _smsEnabled,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: _dark),
        title: Text('Notification Preferences',
            style:
                GoogleFonts.poppins(color: _dark, fontWeight: FontWeight.w600)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Manage your notification settings',
                      style: GoogleFonts.poppins(
                          fontSize: 13, color: _gray)),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
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
                        _buildToggle(
                          icon: Icons.notifications_active_outlined,
                          title: 'Push Notifications',
                          subtitle: 'Receive push notifications on your device',
                          value: _pushEnabled,
                          onChanged: (v) {
                            setState(() => _pushEnabled = v);
                            _savePreferences();
                          },
                        ),
                        _divider(),
                        _buildToggle(
                          icon: Icons.email_outlined,
                          title: 'Email Notifications',
                          subtitle: 'Receive updates via email',
                          value: _emailEnabled,
                          onChanged: (v) {
                            setState(() => _emailEnabled = v);
                            _savePreferences();
                          },
                        ),
                        _divider(),
                        _buildToggle(
                          icon: Icons.sms_outlined,
                          title: 'SMS Notifications',
                          subtitle: 'Receive updates via SMS',
                          value: _smsEnabled,
                          onChanged: (v) {
                            setState(() => _smsEnabled = v);
                            _savePreferences();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildToggle({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: _primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _dark)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: GoogleFonts.poppins(fontSize: 11, color: _gray)),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: _primary,
          ),
        ],
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

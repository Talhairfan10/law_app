import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/user_service.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  static const Color _primary = Color(0xFF6C5CE7);
  static const Color _dark = Color(0xFF1A1A2E);

  final _formKey = GlobalKey<FormState>();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  String _selectedProvince = 'Punjab';
  bool _isLoading = true;
  bool _isSaving = false;

  static const List<String> _provinces = [
    'Punjab',
    'Sindh',
    'Khyber Pakhtunkhwa',
    'Balochistan',
    'Islamabad Capital Territory',
    'Azad Jammu & Kashmir',
    'Gilgit-Baltistan',
  ];

  @override
  void initState() {
    super.initState();
    _loadAddress();
  }

  Future<void> _loadAddress() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final data = await UserService.getUserData(userId);
    final address = data['address'] as Map<String, dynamic>?;
    if (mounted) {
      setState(() {
        if (address != null) {
          _streetController.text = address['street'] as String? ?? '';
          _cityController.text = address['city'] as String? ?? '';
          _postalCodeController.text = address['postalCode'] as String? ?? '';
          final province = address['province'] as String?;
          if (province != null && _provinces.contains(province)) {
            _selectedProvince = province;
          }
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    setState(() => _isSaving = true);
    try {
      await UserService.saveAddress(
        userId,
        street: _streetController.text.trim(),
        city: _cityController.text.trim(),
        province: _selectedProvince,
        postalCode: _postalCodeController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Address saved!', style: GoogleFonts.poppins()),
            backgroundColor: _primary,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save address.',
                style: GoogleFonts.poppins()),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: _dark),
        title: Text('Address',
            style: GoogleFonts.poppins(
                color: _dark, fontWeight: FontWeight.w600)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Manage your address information',
                        style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: const Color(0xFF8E8E93))),
                    const SizedBox(height: 24),
                    _buildField(
                      label: 'Street Address',
                      controller: _streetController,
                      icon: Icons.home_outlined,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Street is required'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      label: 'City',
                      controller: _cityController,
                      icon: Icons.location_city_rounded,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'City is required'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    // Province dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _selectedProvince,
                      items: _provinces
                          .map((p) => DropdownMenuItem(
                              value: p,
                              child: Text(p,
                                  style: GoogleFonts.poppins(
                                      fontSize: 14, color: _dark))))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedProvince = v);
                      },
                      decoration: InputDecoration(
                        labelText: 'Province',
                        labelStyle: GoogleFonts.poppins(
                            fontSize: 13,
                            color: const Color(0xFF8E8E93)),
                        prefixIcon: const Icon(Icons.map_outlined,
                            color: _primary, size: 20),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide:
                              BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide:
                              BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide:
                              const BorderSide(color: _primary, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      label: 'Postal Code',
                      controller: _postalCodeController,
                      icon: Icons.markunread_mailbox_outlined,
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Postal code is required'
                          : null,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primary,
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : Text('Save Address',
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.poppins(fontSize: 14, color: _dark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF8E8E93)),
        prefixIcon: Icon(icon, color: _primary, size: 20),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/user_service.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  static const Color _primary = Color(0xFF6C5CE7);
  static const Color _dark = Color(0xFF1A1A2E);
  static const Color _gray = Color(0xFF8E8E93);

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  void _showAddPaymentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddPaymentMethodSheet(userId: _userId!),
    );
  }

  void _confirmDelete(String docId, String displayName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Remove Payment Method',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Text('Remove "$displayName"?',
            style: GoogleFonts.poppins(color: _gray, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: _gray)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              UserService.deletePaymentMethod(_userId!, docId);
            },
            child: Text('Remove',
                style: GoogleFonts.poppins(
                    color: Colors.redAccent, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  IconData _getMethodIcon(String type) {
    switch (type) {
      case 'visa':
        return Icons.credit_card_rounded;
      case 'mastercard':
        return Icons.credit_card_rounded;
      case 'jazzcash':
        return Icons.phone_android_rounded;
      case 'easypaisa':
        return Icons.phone_android_rounded;
      default:
        return Icons.payment_rounded;
    }
  }

  Color _getMethodColor(String type) {
    switch (type) {
      case 'visa':
        return const Color(0xFF1A1F71);
      case 'mastercard':
        return const Color(0xFFEB001B);
      case 'jazzcash':
        return const Color(0xFFE30613);
      case 'easypaisa':
        return const Color(0xFF00A651);
      default:
        return _primary;
    }
  }

  String _getMethodLabel(String type) {
    switch (type) {
      case 'visa':
        return 'Visa';
      case 'mastercard':
        return 'Mastercard';
      case 'jazzcash':
        return 'JazzCash';
      case 'easypaisa':
        return 'Easypaisa';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = _userId;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: _dark),
        title: Text('Payment Methods',
            style:
                GoogleFonts.poppins(color: _dark, fontWeight: FontWeight.w600)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: userId != null ? _showAddPaymentSheet : null,
        backgroundColor: _primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Add Method',
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: userId == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<Map<String, dynamic>>>(
              stream: UserService.getPaymentMethodsStream(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: _primary));
                }

                final methods = snapshot.data ?? [];

                if (methods.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF2F0FE),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.credit_card_off_rounded,
                              color: _primary, size: 40),
                        ),
                        const SizedBox(height: 20),
                        Text('No payment methods',
                            style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _dark)),
                        const SizedBox(height: 8),
                        Text('Add a card or mobile wallet\nto get started.',
                            textAlign: TextAlign.center,
                            style:
                                GoogleFonts.poppins(fontSize: 13, color: _gray)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: methods.length,
                  itemBuilder: (_, i) {
                    final m = methods[i];
                    final type = m['methodType'] as String? ?? '';
                    final display = m['displayName'] as String? ?? '';
                    final holder = m['holderName'] as String? ?? '';
                    final docId = m['id'] as String;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
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
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color:
                                  _getMethodColor(type).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(_getMethodIcon(type),
                                color: _getMethodColor(type), size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: _getMethodColor(type)
                                            .withValues(alpha: 0.1),
                                        borderRadius:
                                            BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        _getMethodLabel(type),
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: _getMethodColor(type),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(display,
                                    style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: _dark)),
                                if (holder.isNotEmpty)
                                  Text(holder,
                                      style: GoogleFonts.poppins(
                                          fontSize: 12, color: _gray)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded,
                                color: Colors.redAccent, size: 22),
                            onPressed: () => _confirmDelete(docId, display),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

// ─────────────────────────────────────────────────
//  Add Payment Method Bottom Sheet
// ─────────────────────────────────────────────────

class _AddPaymentMethodSheet extends StatefulWidget {
  final String userId;
  const _AddPaymentMethodSheet({required this.userId});

  @override
  State<_AddPaymentMethodSheet> createState() => _AddPaymentMethodSheetState();
}

class _AddPaymentMethodSheetState extends State<_AddPaymentMethodSheet> {
  static const Color _primary = Color(0xFF6C5CE7);
  static const Color _dark = Color(0xFF1A1A2E);

  final _formKey = GlobalKey<FormState>();
  String _selectedType = 'visa';
  final _holderController = TextEditingController();
  final _detailController = TextEditingController(); // last4 or phone
  bool _isSaving = false;

  bool get _isCardType =>
      _selectedType == 'visa' || _selectedType == 'mastercard';

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final detail = _detailController.text.trim();
      String displayName;
      if (_isCardType) {
        displayName = '•••• •••• •••• $detail';
      } else {
        displayName = '${_selectedType == 'jazzcash' ? 'JazzCash' : 'Easypaisa'} $detail';
      }

      await UserService.addPaymentMethod(
        widget.userId,
        methodType: _selectedType,
        displayName: displayName,
        holderName: _holderController.text.trim(),
        last4: _isCardType ? detail : null,
        phoneNumber: !_isCardType ? detail : null,
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Failed to add method.', style: GoogleFonts.poppins()),
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
    _holderController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 12, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text('Add Payment Method',
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _dark)),
            const SizedBox(height: 20),

            // Type selector
            Row(
              children: [
                _typeChip('visa', 'Visa'),
                const SizedBox(width: 8),
                _typeChip('mastercard', 'Mastercard'),
                const SizedBox(width: 8),
                _typeChip('jazzcash', 'JazzCash'),
                const SizedBox(width: 8),
                _typeChip('easypaisa', 'Easypaisa'),
              ],
            ),
            const SizedBox(height: 20),

            // Detail field
            TextFormField(
              controller: _detailController,
              keyboardType:
                  _isCardType ? TextInputType.number : TextInputType.phone,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return _isCardType
                      ? 'Enter last 4 digits'
                      : 'Enter phone number';
                }
                if (_isCardType && v.trim().length != 4) {
                  return 'Enter exactly 4 digits';
                }
                return null;
              },
              style: GoogleFonts.poppins(fontSize: 14, color: _dark),
              decoration: InputDecoration(
                labelText:
                    _isCardType ? 'Last 4 Digits' : 'Phone Number',
                labelStyle: GoogleFonts.poppins(
                    fontSize: 13, color: const Color(0xFF8E8E93)),
                prefixIcon: Icon(
                  _isCardType
                      ? Icons.credit_card_rounded
                      : Icons.phone_android_rounded,
                  color: _primary,
                  size: 20,
                ),
                filled: true,
                fillColor: const Color(0xFFFAFAFA),
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
                  borderSide:
                      const BorderSide(color: _primary, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Holder name
            TextFormField(
              controller: _holderController,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Enter holder name' : null,
              style: GoogleFonts.poppins(fontSize: 14, color: _dark),
              decoration: InputDecoration(
                labelText: 'Account Holder Name',
                labelStyle: GoogleFonts.poppins(
                    fontSize: 13, color: const Color(0xFF8E8E93)),
                prefixIcon: const Icon(Icons.person_outline,
                    color: _primary, size: 20),
                filled: true,
                fillColor: const Color(0xFFFAFAFA),
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
                  borderSide:
                      const BorderSide(color: _primary, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
                    : Text('Add Payment Method',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeChip(String value, String label) {
    final isSelected = _selectedType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _selectedType = value;
          _detailController.clear();
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? _primary : const Color(0xFFF2F0FE),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? Colors.white : const Color(0xFF8E8E93),
            ),
          ),
        ),
      ),
    );
  }
}

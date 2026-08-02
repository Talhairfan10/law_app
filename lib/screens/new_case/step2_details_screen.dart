import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/new_case_data.dart';
import 'widgets/step_progress_indicator.dart';
import 'widgets/nav_buttons.dart';
import 'step3_documents_screen.dart';

class Step2DetailsScreen extends StatefulWidget {
  final NewCaseData caseData;

  const Step2DetailsScreen({super.key, required this.caseData});

  @override
  State<Step2DetailsScreen> createState() => _Step2DetailsScreenState();
}

class _Step2DetailsScreenState extends State<Step2DetailsScreen> {
  static const Color _primary = Color(0xFF5C3FD3);

  String? _selectedSubCategory;
  final _descriptionController = TextEditingController();
  final _additionalController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime? _selectedDate;

  List<String> get _subCategories =>
      kCategorySubcategories[widget.caseData.category] ?? [];

  @override
  void initState() {
    super.initState();
    // Restore previously filled data
    _selectedSubCategory = widget.caseData.subCategory.isEmpty
        ? null
        : widget.caseData.subCategory;
    _descriptionController.text = widget.caseData.shortDescription;
    _additionalController.text = widget.caseData.additionalInfo;
    _locationController.text = widget.caseData.location;
    _selectedDate = widget.caseData.issueDate;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _additionalController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _primary,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      if (!mounted) return;
      setState(() => _selectedDate = picked);
    }
  }

  bool _validate() {
    if (_selectedSubCategory == null || _selectedSubCategory!.isEmpty) {
      _showError('Please select a sub category.');
      return false;
    }
    if (_descriptionController.text.trim().isEmpty) {
      _showError('Please provide a short description.');
      return false;
    }
    if (_selectedDate == null) {
      _showError('Please select when the issue occurred.');
      return false;
    }
    return true;
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.poppins()),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _onContinue() {
    if (!_validate()) return;

    widget.caseData.subCategory = _selectedSubCategory!;
    widget.caseData.shortDescription = _descriptionController.text.trim();
    widget.caseData.issueDate = _selectedDate;
    widget.caseData.location = _locationController.text.trim();
    widget.caseData.additionalInfo = _additionalController.text.trim();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Step3DocumentsScreen(caseData: widget.caseData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          const StepProgressIndicator(currentStep: 2),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStepHeader(),
                  const SizedBox(height: 20),
                  _buildSubCategoryDropdown(),
                  const SizedBox(height: 16),
                  _buildDescriptionField(),
                  const SizedBox(height: 16),
                  _buildDateField(),
                  const SizedBox(height: 16),
                  _buildLocationField(),
                  const SizedBox(height: 16),
                  _buildAdditionalInfoField(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          NewCaseNavButtons(
            onBack: () => Navigator.pop(context),
            onContinue: _onContinue,
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1A1A2E)),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        children: [
          Text(
            'New Case',
            style: GoogleFonts.poppins(
              color: const Color(0xFF1A1A2E),
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          Text(
            'Provide more details about your issue',
            style: GoogleFonts.poppins(
              color: const Color(0xFF8E8E93),
              fontSize: 11,
            ),
          ),
        ],
      ),
      centerTitle: true,
    );
  }

  Widget _buildStepHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step 2 of 5',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Case Details',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Please provide a few details so we can\nunderstand your issue better.',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: const Color(0xFF8E8E93),
          ),
        ),
      ],
    );
  }

  Widget _buildSubCategoryDropdown() {
    return _buildFieldCard(
      label: 'Sub Category',
      isRequired: true,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedSubCategory,
          hint: Text(
            'Select Sub Category',
            style: GoogleFonts.poppins(
              color: const Color(0xFFAAAAAA),
              fontSize: 14,
            ),
          ),
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: Color(0xFFAAAAAA)),
          isExpanded: true,
          items: _subCategories.map((sub) {
            return DropdownMenuItem<String>(
              value: sub,
              child: Text(
                sub,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedSubCategory = val),
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return _buildFieldCard(
      label: 'Short Description',
      isRequired: true,
      child: Column(
        children: [
          TextField(
            controller: _descriptionController,
            maxLines: 4,
            maxLength: 200,
            buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
                null,
            style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF1A1A2E)),
            decoration: InputDecoration(
              hintText: 'Write a short summary of your issue...',
              hintStyle: GoogleFonts.poppins(
                color: const Color(0xFFAAAAAA),
                fontSize: 13,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (_) => setState(() {}),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              '${_descriptionController.text.length}/200',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: const Color(0xFFAAAAAA),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField() {
    return _buildFieldCard(
      label: 'When did the issue occur?',
      isRequired: true,
      child: GestureDetector(
        onTap: _pickDate,
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined,
                color: Color(0xFF8E8E93), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _selectedDate == null
                    ? 'Select Date'
                    : DateFormat('d MMMM yyyy').format(_selectedDate!),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: _selectedDate == null
                      ? const Color(0xFFAAAAAA)
                      : const Color(0xFF1A1A2E),
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded,
                color: Color(0xFFAAAAAA)),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationField() {
    return _buildFieldCard(
      label: 'Where did the issue occur?',
      isRequired: false,
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined,
              color: Color(0xFF8E8E93), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _locationController,
              style: GoogleFonts.poppins(
                  fontSize: 14, color: const Color(0xFF1A1A2E)),
              decoration: InputDecoration(
                hintText: 'Enter location (City, Area)',
                hintStyle: GoogleFonts.poppins(
                  color: const Color(0xFFAAAAAA),
                  fontSize: 13,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const Icon(Icons.keyboard_arrow_down_rounded,
              color: Color(0xFFAAAAAA)),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoField() {
    return _buildFieldCard(
      label: 'Any other important information',
      isRequired: false,
      labelSuffix: ' (Optional)',
      child: Column(
        children: [
          TextField(
            controller: _additionalController,
            maxLines: 4,
            maxLength: 300,
            buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
                null,
            style: GoogleFonts.poppins(
                fontSize: 14, color: const Color(0xFF1A1A2E)),
            decoration: InputDecoration(
              hintText: 'Additional information that may help us...',
              hintStyle: GoogleFonts.poppins(
                color: const Color(0xFFAAAAAA),
                fontSize: 13,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (_) => setState(() {}),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              '${_additionalController.text.length}/300',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: const Color(0xFFAAAAAA),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldCard({
    required String label,
    required bool isRequired,
    required Widget child,
    String labelSuffix = '',
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: label,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                if (labelSuffix.isNotEmpty)
                  TextSpan(
                    text: labelSuffix,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF8E8E93),
                    ),
                  ),
                if (isRequired)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.red, fontSize: 13),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

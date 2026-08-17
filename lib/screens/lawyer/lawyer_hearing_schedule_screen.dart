import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../services/hearing_service.dart';
import '../../services/case_service.dart';
import '../../models/case_model.dart';

class LawyerHearingScheduleScreen extends StatefulWidget {
  const LawyerHearingScheduleScreen({super.key});

  @override
  State<LawyerHearingScheduleScreen> createState() =>
      _LawyerHearingScheduleScreenState();
}

class _LawyerHearingScheduleScreenState
    extends State<LawyerHearingScheduleScreen> {
  static const Color _navyDark = Color(0xFF0A1628);
  static const Color _gold = Color(0xFFD4A843);
  static const Color _textMuted = Color(0xFF8E99A4);
  static const Color _greenAccent = Color(0xFF2EAD6E);
  static const Color _blueAccent = Color(0xFF3A82C4);
  static const Color _redAccent = Color(0xFFE74C3C);

  String get _currentUid => FirebaseAuth.instance.currentUser?.uid ?? '';

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Cache the stream to prevent re-creation on rebuilds
  Stream<List<Map<String, dynamic>>>? _hearingsStream;
  List<Map<String, dynamic>> _allHearings = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _initStream();
  }

  void _initStream() {
    if (_currentUid.isNotEmpty) {
      _hearingsStream = HearingService.getAllLawyerHearings(_currentUid);
    }
  }

  List<Map<String, dynamic>> _getHearingsForDay(DateTime day) {
    return _allHearings.where((h) {
      final hDate = _parseDate(h['date']);
      if (hDate == null) return false;
      return isSameDay(hDate, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_hearingsStream == null) {
      return const SafeArea(
        child: Center(child: Text('Not signed in')),
      );
    }

    return SafeArea(
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _hearingsStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _allHearings = snapshot.data!;
          }

          final selectedDayHearings = _selectedDay != null
              ? _getHearingsForDay(_selectedDay!)
              : <Map<String, dynamic>>[];

          return Column(
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
                          'Hearing Schedule',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: _navyDark,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showAddHearingSheet(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child:
                            const Icon(Icons.add, color: _navyDark, size: 20),
                      ),
                    ),
                  ],
                ),
              ),

              // Calendar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
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
                child: Theme(
                  data: ThemeData.light().copyWith(
                    primaryColor: _navyDark,
                    colorScheme:
                        const ColorScheme.light(primary: _navyDark),
                  ),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) =>
                        isSameDay(_selectedDay, day),
                    eventLoader: _getHearingsForDay,
                    onDaySelected: (selectedDay, focusedDay) {
                      if (!isSameDay(_selectedDay, selectedDay)) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      }
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                    calendarStyle: CalendarStyle(
                      defaultTextStyle:
                          GoogleFonts.poppins(color: Colors.black87),
                      weekendTextStyle:
                          GoogleFonts.poppins(color: Colors.black87),
                      outsideTextStyle:
                          GoogleFonts.poppins(color: Colors.black38),
                      todayDecoration: BoxDecoration(
                        color: _gold.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      todayTextStyle: const TextStyle(
                          color: _navyDark, fontWeight: FontWeight.bold),
                      selectedDecoration: const BoxDecoration(
                        color: _navyDark,
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: const BoxDecoration(
                        color: _gold,
                        shape: BoxShape.circle,
                      ),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _navyDark,
                      ),
                      leftChevronIcon:
                          const Icon(Icons.chevron_left, color: _navyDark),
                      rightChevronIcon:
                          const Icon(Icons.chevron_right, color: _navyDark),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Hearing List Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _selectedDay != null
                        ? 'Hearings on ${DateFormat('dd MMM yyyy').format(_selectedDay!)}'
                        : 'Select a day',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _navyDark,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Hearing List
              Expanded(
                child: snapshot.connectionState == ConnectionState.waiting
                    ? const Center(child: CircularProgressIndicator())
                    : selectedDayHearings.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            itemCount: selectedDayHearings.length,
                            itemBuilder: (context, index) {
                              return _buildHearingCard(
                                  selectedDayHearings[index]);
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Empty State ──
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'No hearings scheduled',
            style: GoogleFonts.poppins(fontSize: 14, color: _textMuted),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap + to add a new hearing.',
            style: GoogleFonts.poppins(fontSize: 12, color: _textMuted),
          ),
        ],
      ),
    );
  }

  // ── Hearing Card ──
  Widget _buildHearingCard(Map<String, dynamic> hearing) {
    final date = _parseDate(hearing['date']);
    final time = hearing['time'] as String? ?? '';
    final courtName = hearing['courtName'] as String? ?? '';
    final courtRoom = hearing['courtRoom'] as String? ?? '';
    final hearingType = hearing['hearingType'] as String? ?? '';
    final purpose = hearing['purpose'] as String? ?? '';
    final caseId = hearing['caseId'] as String? ?? '';
    final caseDocId = hearing['caseDocId'] as String? ?? '';
    final hearingId = hearing['id'] as String? ?? '';
    final status = hearing['status'] as String? ?? 'upcoming';
    final outcomeNotes = hearing['outcomeNotes'] as String? ?? '';

    final isCompleted = status == 'completed';

    final months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
    ];
    final dayNames = [
      'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'
    ];

    String monthStr = '';
    String dayStr = '';
    String dayName = '';
    if (date != null) {
      monthStr = months[date.month - 1];
      dayStr = date.day.toString().padLeft(2, '0');
      dayName = dayNames[date.weekday - 1];
    }

    return GestureDetector(
      onTap: () {
        if (!isCompleted && caseDocId.isNotEmpty && hearingId.isNotEmpty) {
          _showMarkCompleteSheet(context, hearing);
        } else if (isCompleted) {
          _showCompletedDetails(context, hearing);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: isCompleted
              ? Border.all(color: _greenAccent.withValues(alpha: 0.3))
              : null,
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
            // Date block
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isCompleted
                    ? _greenAccent.withValues(alpha: 0.1)
                    : const Color(0xFFFFF5E0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    monthStr,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isCompleted ? _greenAccent : _gold,
                    ),
                  ),
                  Text(
                    dayStr,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _navyDark,
                    ),
                  ),
                  Text(
                    dayName,
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: _textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status badge + time
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? _greenAccent.withValues(alpha: 0.1)
                              : _gold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isCompleted ? 'Completed' : 'Upcoming',
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: isCompleted ? _greenAccent : _gold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.access_time,
                          size: 13, color: _greenAccent),
                      const SizedBox(width: 3),
                      Text(
                        time,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _greenAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (hearingType.isNotEmpty)
                    Text(
                      hearingType,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _navyDark,
                      ),
                    ),
                  if (courtName.isNotEmpty || courtRoom.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 13, color: _textMuted),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '$courtName${courtRoom.isNotEmpty ? ' — Room $courtRoom' : ''}',
                            style: GoogleFonts.poppins(
                                fontSize: 11, color: _textMuted),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (purpose.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      purpose,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: _navyDark.withValues(alpha: 0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (caseId.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Case: $caseId',
                      style: GoogleFonts.poppins(
                          fontSize: 10, color: _textMuted),
                    ),
                  ],
                  if (isCompleted && outcomeNotes.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _greenAccent.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline,
                              size: 12, color: _greenAccent),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              outcomeNotes,
                              style: GoogleFonts.poppins(
                                  fontSize: 10, color: _greenAccent),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              isCompleted ? Icons.check_circle : Icons.chevron_right,
              size: 22,
              color: isCompleted ? _greenAccent : _textMuted,
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  //  ADD HEARING BOTTOM SHEET
  // ══════════════════════════════════════════════════════════

  void _showAddHearingSheet(BuildContext context,
      {String? preSelectedCaseDocId}) {
    final formKey = GlobalKey<FormState>();
    String? selectedCaseDocId = preSelectedCaseDocId;
    DateTime selectedDate = _selectedDay ?? DateTime.now();
    TimeOfDay selectedTime = const TimeOfDay(hour: 10, minute: 0);
    final courtNameCtrl = TextEditingController();
    final courtRoomCtrl = TextEditingController();
    String selectedHearingType = 'Arguments';
    final purposeCtrl = TextEditingController();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * 0.88,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    24, 16, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Drag handle
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Title
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: _gold.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.event_available,
                                  color: _gold, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Schedule New Hearing',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: _navyDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Case Selector
                        Text('Select Case *',
                            style: _labelStyle()),
                        const SizedBox(height: 6),
                        StreamBuilder<List<CaseModel>>(
                          stream: CaseService.getLawyerCases(_currentUid),
                          builder: (ctx, snap) {
                            final cases = snap.data ?? [];
                            if (cases.isEmpty) {
                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: _fieldDecoration(),
                                child: Text(
                                  snap.connectionState ==
                                          ConnectionState.waiting
                                      ? 'Loading cases...'
                                      : 'No cases assigned to you',
                                  style: GoogleFonts.poppins(
                                      fontSize: 13, color: _textMuted),
                                ),
                              );
                            }
                            // Auto-select if only one case or pre-selected
                            if (selectedCaseDocId == null && cases.length == 1) {
                              selectedCaseDocId = cases.first.docId;
                            }
                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: _fieldDecoration(),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: cases.any(
                                          (c) => c.docId == selectedCaseDocId)
                                      ? selectedCaseDocId
                                      : null,
                                  hint: Text('Choose a case',
                                      style: GoogleFonts.poppins(
                                          fontSize: 13, color: _textMuted)),
                                  items: cases.map((c) {
                                    return DropdownMenuItem(
                                      value: c.docId,
                                      child: Text(
                                        '${c.caseId} — ${c.categoryDisplayName}',
                                        style: GoogleFonts.poppins(
                                            fontSize: 13, color: _navyDark),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    setSheetState(
                                        () => selectedCaseDocId = val);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // Date & Time Row
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Date *', style: _labelStyle()),
                                  const SizedBox(height: 6),
                                  GestureDetector(
                                    onTap: () async {
                                      final picked = await showDatePicker(
                                        context: ctx,
                                        initialDate: selectedDate,
                                        firstDate: DateTime.now()
                                            .subtract(
                                                const Duration(days: 30)),
                                        lastDate: DateTime.now()
                                            .add(const Duration(days: 365)),
                                      );
                                      if (picked != null) {
                                        setSheetState(
                                            () => selectedDate = picked);
                                      }
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: _fieldDecoration(),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.calendar_today,
                                              size: 16, color: _textMuted),
                                          const SizedBox(width: 8),
                                          Text(
                                            DateFormat('dd MMM yyyy')
                                                .format(selectedDate),
                                            style: GoogleFonts.poppins(
                                                fontSize: 13,
                                                color: _navyDark),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Time *', style: _labelStyle()),
                                  const SizedBox(height: 6),
                                  GestureDetector(
                                    onTap: () async {
                                      final picked = await showTimePicker(
                                        context: ctx,
                                        initialTime: selectedTime,
                                      );
                                      if (picked != null) {
                                        setSheetState(
                                            () => selectedTime = picked);
                                      }
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: _fieldDecoration(),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.access_time,
                                              size: 16, color: _textMuted),
                                          const SizedBox(width: 8),
                                          Text(
                                            selectedTime.format(ctx),
                                            style: GoogleFonts.poppins(
                                                fontSize: 13,
                                                color: _navyDark),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Court Name & Room
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Court Name *', style: _labelStyle()),
                                  const SizedBox(height: 6),
                                  _buildTextField(courtNameCtrl,
                                      'e.g. Lahore High Court',
                                      validator: (v) => (v == null || v.isEmpty)
                                          ? 'Required'
                                          : null),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Court Room', style: _labelStyle()),
                                  const SizedBox(height: 6),
                                  _buildTextField(
                                      courtRoomCtrl, 'e.g. Room 5'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Hearing Type
                        Text('Hearing Type *', style: _labelStyle()),
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 12),
                          decoration: _fieldDecoration(),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: selectedHearingType,
                              items: [
                                'Arguments',
                                'Evidence',
                                'Bail Hearing',
                                'Judgment',
                                'Interim Order',
                                'Cross-Examination',
                                'Plea Hearing',
                                'Preliminary Hearing',
                                'Settlement Conference',
                                'Other',
                              ]
                                  .map((t) => DropdownMenuItem(
                                        value: t,
                                        child: Text(t,
                                            style: GoogleFonts.poppins(
                                                fontSize: 13,
                                                color: _navyDark)),
                                      ))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setSheetState(
                                      () => selectedHearingType = val);
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Purpose
                        Text('Purpose / Notes', style: _labelStyle()),
                        const SizedBox(height: 6),
                        _buildTextField(purposeCtrl,
                            'e.g. Cross-examination of witness #2',
                            maxLines: 3),
                        const SizedBox(height: 24),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: isSubmitting
                                ? null
                                : () async {
                                    if (selectedCaseDocId == null ||
                                        selectedCaseDocId!.isEmpty) {
                                      ScaffoldMessenger.of(ctx).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Please select a case')),
                                      );
                                      return;
                                    }
                                    if (courtNameCtrl.text.trim().isEmpty) {
                                      ScaffoldMessenger.of(ctx).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Court name is required')),
                                      );
                                      return;
                                    }

                                    setSheetState(
                                        () => isSubmitting = true);

                                    try {
                                      final timeStr =
                                          selectedTime.format(ctx);
                                      await HearingService.addHearing(
                                        selectedCaseDocId!,
                                        date: selectedDate,
                                        time: timeStr,
                                        courtName:
                                            courtNameCtrl.text.trim(),
                                        courtRoom:
                                            courtRoomCtrl.text.trim(),
                                        hearingType: selectedHearingType,
                                        purpose:
                                            purposeCtrl.text.trim(),
                                        createdBy: _currentUid,
                                      );

                                      if (ctx.mounted) {
                                        Navigator.pop(ctx);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Hearing scheduled on ${DateFormat('dd MMM yyyy').format(selectedDate)} at $timeStr',
                                            ),
                                            backgroundColor: _greenAccent,
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      debugPrint(
                                          'Error adding hearing: $e');
                                      setSheetState(
                                          () => isSubmitting = false);
                                      if (ctx.mounted) {
                                        ScaffoldMessenger.of(ctx)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Failed to schedule hearing: $e'),
                                            backgroundColor: _redAccent,
                                          ),
                                        );
                                      }
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _navyDark,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2),
                                  )
                                : Text(
                                    'Schedule Hearing',
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════
  //  MARK HEARING COMPLETED BOTTOM SHEET
  // ══════════════════════════════════════════════════════════

  void _showMarkCompleteSheet(
      BuildContext context, Map<String, dynamic> hearing) {
    final caseDocId = hearing['caseDocId'] as String? ?? '';
    final hearingId = hearing['id'] as String? ?? '';
    final hearingType = hearing['hearingType'] as String? ?? 'Hearing';
    final date = _parseDate(hearing['date']);
    final time = hearing['time'] as String? ?? '';
    final courtName = hearing['courtName'] as String? ?? '';
    final caseId = hearing['caseId'] as String? ?? '';
    final outcomeCtrl = TextEditingController();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    24, 16, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Drag handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Title
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _greenAccent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.check_circle_outline,
                                color: _greenAccent, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Complete Hearing',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: _navyDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Hearing Summary Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: const Color(0xFFEFEFEF)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(hearingType,
                                style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _navyDark)),
                            const SizedBox(height: 4),
                            if (date != null)
                              _summaryRow(Icons.event,
                                  DateFormat('dd MMM yyyy').format(date)),
                            if (time.isNotEmpty)
                              _summaryRow(Icons.access_time, time),
                            if (courtName.isNotEmpty)
                              _summaryRow(
                                  Icons.location_on_outlined, courtName),
                            if (caseId.isNotEmpty)
                              _summaryRow(Icons.folder_outlined,
                                  'Case: $caseId'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Outcome Notes
                      Text('Outcome / Notes (Optional)',
                          style: _labelStyle()),
                      const SizedBox(height: 6),
                      _buildTextField(
                        outcomeCtrl,
                        'e.g. Arguments concluded, next date given for judgment...',
                        maxLines: 4,
                      ),
                      const SizedBox(height: 24),

                      // Mark Complete Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  setSheetState(
                                      () => isSubmitting = true);
                                  try {
                                    await HearingService
                                        .markHearingCompleted(
                                      caseDocId,
                                      hearingId,
                                      outcomeNotes:
                                          outcomeCtrl.text.trim(),
                                    );
                                    if (ctx.mounted) {
                                      Navigator.pop(ctx);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Hearing marked as completed'),
                                          backgroundColor: _greenAccent,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    setSheetState(
                                        () => isSubmitting = false);
                                    if (ctx.mounted) {
                                      ScaffoldMessenger.of(ctx)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Error: $e'),
                                          backgroundColor: _redAccent,
                                        ),
                                      );
                                    }
                                  }
                                },
                          icon: isSubmitting
                              ? const SizedBox.shrink()
                              : const Icon(Icons.check_circle, size: 20),
                          label: isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2),
                                )
                              : Text(
                                  'Mark as Completed',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _greenAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Schedule Next Hearing Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _showAddHearingSheet(context,
                                preSelectedCaseDocId: caseDocId);
                          },
                          icon: const Icon(Icons.event_available, size: 18),
                          label: Text(
                            'Schedule Next Hearing',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _blueAccent,
                            side: BorderSide(
                                color:
                                    _blueAccent.withValues(alpha: 0.4)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ── Completed Hearing Details ──
  void _showCompletedDetails(
      BuildContext context, Map<String, dynamic> hearing) {
    final hearingType = hearing['hearingType'] as String? ?? 'Hearing';
    final date = _parseDate(hearing['date']);
    final time = hearing['time'] as String? ?? '';
    final courtName = hearing['courtName'] as String? ?? '';
    final courtRoom = hearing['courtRoom'] as String? ?? '';
    final caseId = hearing['caseId'] as String? ?? '';
    final purpose = hearing['purpose'] as String? ?? '';
    final outcomeNotes = hearing['outcomeNotes'] as String? ?? '';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _greenAccent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.check_circle,
                          color: _greenAccent, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Completed: $hearingType',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _navyDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (date != null)
                  _summaryRow(Icons.event,
                      DateFormat('dd MMM yyyy').format(date)),
                if (time.isNotEmpty)
                  _summaryRow(Icons.access_time, time),
                if (courtName.isNotEmpty)
                  _summaryRow(Icons.location_on_outlined,
                      '$courtName${courtRoom.isNotEmpty ? ' — Room $courtRoom' : ''}'),
                if (caseId.isNotEmpty)
                  _summaryRow(Icons.folder_outlined, 'Case: $caseId'),
                if (purpose.isNotEmpty)
                  _summaryRow(Icons.notes, 'Purpose: $purpose'),
                if (outcomeNotes.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text('Outcome Notes',
                      style: _labelStyle()),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _greenAccent.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: _greenAccent.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      outcomeNotes,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: _navyDark,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Shared Helpers ──

  Widget _summaryRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 15, color: _textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(fontSize: 12, color: _navyDark),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _labelStyle() {
    return GoogleFonts.poppins(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: _textMuted,
    );
  }

  BoxDecoration _fieldDecoration() {
    return BoxDecoration(
      color: const Color(0xFFF8F9FA),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFFEFEFEF)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      {int maxLines = 1, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: GoogleFonts.poppins(fontSize: 13, color: _navyDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(fontSize: 13, color: _textMuted),
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFEFEFEF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFEFEFEF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _navyDark),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        isDense: true,
      ),
    );
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    try {
      return (value as dynamic).toDate();
    } catch (_) {
      return null;
    }
  }
}

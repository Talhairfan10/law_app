import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../services/hearing_service.dart';

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

  String get _currentUid => FirebaseAuth.instance.currentUser?.uid ?? '';

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // We will store all hearings here when the stream updates
  List<Map<String, dynamic>> _allHearings = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  /// Get hearings for a specific day to show markers on the calendar
  List<Map<String, dynamic>> _getHearingsForDay(DateTime day) {
    return _allHearings.where((h) {
      final hDate = _parseDate(h['date']);
      if (hDate == null) return false;
      return isSameDay(hDate, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: HearingService.getAllLawyerHearings(_currentUid),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _allHearings = snapshot.data!;
          }

          final selectedDayHearings = _selectedDay != null
              ? _getHearingsForDay(_selectedDay!)
              : [];

          return Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
                      onTap: () {
                        // TODO: Phase 4 Add Hearing Flow
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Add Hearing feature coming soon.')),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.add, color: _navyDark, size: 20),
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
                    colorScheme: const ColorScheme.light(primary: _navyDark),
                  ),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
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
                      defaultTextStyle: GoogleFonts.poppins(color: Colors.black87),
                      weekendTextStyle: GoogleFonts.poppins(color: Colors.black87),
                      outsideTextStyle: GoogleFonts.poppins(color: Colors.black38),
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
                    'Hearings on ${_selectedDay != null ? "${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}" : "Selected Day"}',
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'No hearings scheduled',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: _textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Select a different date from the calendar.',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: _textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHearingCard(Map<String, dynamic> hearing) {
    final date = _parseDate(hearing['date']);
    final time = hearing['time'] as String? ?? '';
    final courtName = hearing['courtName'] as String? ?? '';
    final courtRoom = hearing['courtRoom'] as String? ?? '';
    final hearingType = hearing['hearingType'] as String? ?? '';
    final purpose = hearing['purpose'] as String? ?? '';
    final caseId = hearing['caseId'] as String? ?? '';
    final status = hearing['status'] as String? ?? 'upcoming';

    final isUpcoming = status == 'upcoming';
    final months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
    ];
    final dayNames = [
      'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY',
      'FRIDAY', 'SATURDAY', 'SUNDAY'
    ];

    String monthStr = '';
    String dayStr = '';
    String dayName = '';
    String yearStr = '';
    if (date != null) {
      monthStr = months[date.month - 1];
      dayStr = date.day.toString().padLeft(2, '0');
      dayName = dayNames[date.weekday - 1];
      yearStr = date.year.toString();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
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
          // Date block
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isUpcoming ? const Color(0xFFFFF5E0) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  monthStr,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _gold,
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
                  yearStr,
                  style: GoogleFonts.poppins(fontSize: 10, color: _textMuted),
                ),
                Text(
                  dayName,
                  style: GoogleFonts.poppins(
                    fontSize: 8,
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
                Row(
                  children: [
                    const Icon(Icons.access_time,
                        size: 14, color: _greenAccent),
                    const SizedBox(width: 4),
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
                Text(
                  isUpcoming ? 'Next Hearing' : 'Hearing',
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
                          '$courtName${courtRoom.isNotEmpty ? ' - $courtRoom' : ''}',
                          style: GoogleFonts.poppins(
                              fontSize: 11, color: _textMuted),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                if (hearingType.isNotEmpty || purpose.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _blueAccent.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Hearing Type: $hearingType\nPurpose: $purpose',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: _navyDark,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
                if (caseId.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Case: $caseId',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: _textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Icon(Icons.chevron_right, size: 22, color: _textMuted),
        ],
      ),
    );
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    // Firestore Timestamp
    try {
      return (value as dynamic).toDate();
    } catch (_) {
      return null;
    }
  }
}

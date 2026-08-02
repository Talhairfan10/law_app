import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Horizontal 5-step progress indicator shown at the top of each New Case step screen.
class StepProgressIndicator extends StatelessWidget {
  final int currentStep; // 1-based

  const StepProgressIndicator({super.key, required this.currentStep});

  static const List<String> _labels = [
    'Category',
    'Details',
    'Documents',
    'Lawyer',
    'Review',
  ];

  static const Color _primary = Color(0xFF5C3FD3);
  static const Color _lineCompleted = Color(0xFF5C3FD3);
  static const Color _lineIncomplete = Color(0xFFDDDDDD);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Column(
        children: [
          // Row of circles + lines
          Row(
            children: List.generate(5, (i) {
              final step = i + 1;
              final isCompleted = step < currentStep;
              final isCurrent = step == currentStep;
              final isLast = i == 4;

              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 0,
                      child: _buildCircle(step, isCompleted, isCurrent),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: isCompleted ? _lineCompleted : _lineIncomplete,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          // Labels row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (i) {
              final step = i + 1;
              final isCurrent = step == currentStep;
              final isCompleted = step < currentStep;
              return SizedBox(
                width: 56,
                child: Text(
                  _labels[i],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: (isCurrent || isCompleted)
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: (isCurrent || isCompleted)
                        ? _primary
                        : const Color(0xFFAAAAAA),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCircle(int step, bool isCompleted, bool isCurrent) {
    if (isCompleted) {
      return Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(
          color: _primary,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
      );
    } else if (isCurrent) {
      return Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(
          color: _primary,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '$step',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      );
    } else {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFCCCCCC), width: 1.5),
        ),
        child: Center(
          child: Text(
            '$step',
            style: GoogleFonts.poppins(
              color: const Color(0xFFAAAAAA),
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      );
    }
  }
}

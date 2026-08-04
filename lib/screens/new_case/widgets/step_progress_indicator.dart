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
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate sizes based on available width to prevent overflow.
          // Total width is shared between 5 circles and 4 connecting lines.
          final circleSize = (constraints.maxWidth * 0.085).clamp(24.0, 32.0);
          final totalCircles = circleSize * 5;
          final totalLineSpace = constraints.maxWidth - totalCircles;
          final lineWidth = totalLineSpace / 4;

          return Column(
            children: [
              // Row of circles + lines
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final step = i + 1;
                  final isCompleted = step < currentStep;
                  final isLast = i == 4;

                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildCircle(step, isCompleted, step == currentStep,
                          circleSize),
                      if (!isLast)
                        Container(
                          width: lineWidth,
                          height: 2,
                          color:
                              isCompleted ? _lineCompleted : _lineIncomplete,
                        ),
                    ],
                  );
                }),
              ),
              const SizedBox(height: 8),
              // Labels row — use Expanded so they flex to fit
              Row(
                children: List.generate(5, (i) {
                  final step = i + 1;
                  final isCurrent = step == currentStep;
                  final isCompleted = step < currentStep;
                  return Expanded(
                    child: Text(
                      _labels[i],
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 9.5,
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
          );
        },
      ),
    );
  }

  Widget _buildCircle(
      int step, bool isCompleted, bool isCurrent, double size) {
    if (isCompleted) {
      return Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: _primary,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.check_rounded,
            color: Colors.white, size: size * 0.56),
      );
    } else if (isCurrent) {
      return Container(
        width: size,
        height: size,
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
              fontSize: size * 0.44,
            ),
          ),
        ),
      );
    } else {
      return Container(
        width: size,
        height: size,
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
              fontSize: size * 0.41,
            ),
          ),
        ),
      );
    }
  }
}

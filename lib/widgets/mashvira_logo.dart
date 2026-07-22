import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MashviraLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final Color primaryColor;
  final Color secondaryColor;

  const MashviraLogo({
    super.key,
    this.size = 140,
    this.showText = true,
    this.primaryColor = const Color(0xFFD4A843), // Gold
    this.secondaryColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo Graphic (Shield + Scale + Laurels)
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _LogoPainter(color: primaryColor),
          ),
        ),
        if (showText) ...[
          SizedBox(height: size * 0.05),
          Text(
            'MASHVIRA',
            style: GoogleFonts.playfairDisplay(
              fontSize: size * 0.22,
              fontWeight: FontWeight.w700,
              color: primaryColor,
              letterSpacing: 2.0,
            ),
          ),
          SizedBox(height: size * 0.04),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: size * 0.25, height: 1, color: primaryColor),
              const SizedBox(width: 8),
              Text(
                'LAW HOUSE',
                style: GoogleFonts.inter(
                  fontSize: size * 0.08,
                  fontWeight: FontWeight.w500,
                  color: secondaryColor,
                  letterSpacing: 3.0,
                ),
              ),
              const SizedBox(width: 8),
              Container(width: size * 0.25, height: 1, color: primaryColor),
            ],
          ),
        ],
      ],
    );
  }
}

class _LogoPainter extends CustomPainter {
  final Color color;
  _LogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.025
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // ── 1. Draw the Shield ──
    final shieldPath = Path();
    shieldPath.moveTo(w * 0.25, h * 0.15); // Top left
    shieldPath.lineTo(w * 0.5, h * 0.05);  // Top center peak
    shieldPath.lineTo(w * 0.75, h * 0.15); // Top right
    shieldPath.lineTo(w * 0.75, h * 0.55); // Right edge down
    // Curve to bottom point
    shieldPath.quadraticBezierTo(w * 0.75, h * 0.85, w * 0.5, h * 0.95);
    // Curve back up to left edge
    shieldPath.quadraticBezierTo(w * 0.25, h * 0.85, w * 0.25, h * 0.55);
    shieldPath.close();
    canvas.drawPath(shieldPath, paint);

    // ── 2. Draw the Balance Scale inside the Shield ──
    // Center post
    canvas.drawLine(Offset(w * 0.5, h * 0.25), Offset(w * 0.5, h * 0.75), paint);
    // Base of scale
    canvas.drawLine(Offset(w * 0.4, h * 0.75), Offset(w * 0.6, h * 0.75), paint);
    // Top beam
    canvas.drawLine(Offset(w * 0.35, h * 0.35), Offset(w * 0.65, h * 0.35), paint);
    
    // Left pan strings
    paint.strokeWidth = w * 0.01;
    canvas.drawLine(Offset(w * 0.35, h * 0.35), Offset(w * 0.3, h * 0.55), paint);
    canvas.drawLine(Offset(w * 0.35, h * 0.35), Offset(w * 0.4, h * 0.55), paint);
    // Left pan
    canvas.drawLine(Offset(w * 0.28, h * 0.55), Offset(w * 0.42, h * 0.55), paint);

    // Right pan strings
    canvas.drawLine(Offset(w * 0.65, h * 0.35), Offset(w * 0.6, h * 0.55), paint);
    canvas.drawLine(Offset(w * 0.65, h * 0.35), Offset(w * 0.7, h * 0.55), paint);
    // Right pan
    canvas.drawLine(Offset(w * 0.58, h * 0.55), Offset(w * 0.72, h * 0.55), paint);

    // ── 3. Draw the Laurels around the Shield ──
    paint.strokeWidth = w * 0.02;
    
    // Left Laurel Branch
    final leftBranch = Path();
    leftBranch.moveTo(w * 0.15, h * 0.85);
    leftBranch.quadraticBezierTo(w * 0.05, h * 0.6, w * 0.15, h * 0.3);
    canvas.drawPath(leftBranch, paint);

    // Right Laurel Branch
    final rightBranch = Path();
    rightBranch.moveTo(w * 0.85, h * 0.85);
    rightBranch.quadraticBezierTo(w * 0.95, h * 0.6, w * 0.85, h * 0.3);
    canvas.drawPath(rightBranch, paint);

    // Draw Leaves (small ovals)
    for (int i = 0; i < 5; i++) {
      double t = i / 4; // 0.0 to 1.0
      // Left leaves
      double lx = w * 0.1 + (t * w * 0.05);
      double ly = h * 0.8 - (t * h * 0.45);
      canvas.save();
      canvas.translate(lx, ly);
      canvas.rotate(0.5 - t * 0.5); // Angled leaves
      canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: w * 0.06, height: h * 0.03), fillPaint);
      canvas.restore();

      // Right leaves
      double rx = w * 0.9 - (t * w * 0.05);
      double ry = h * 0.8 - (t * h * 0.45);
      canvas.save();
      canvas.translate(rx, ry);
      canvas.rotate(-0.5 + t * 0.5);
      canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: w * 0.06, height: h * 0.03), fillPaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

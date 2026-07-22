import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Custom painter for the scales of justice shield logo
class ScalesOfJusticeLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Draw shield
    _drawShield(canvas, size, centerX, centerY);

    // Draw scales of justice
    _drawScales(canvas, size, centerX, centerY);
  }

  void _drawShield(Canvas canvas, Size size, double cx, double cy) {
    final shieldWidth = size.width * 0.7;
    final shieldHeight = size.height * 0.75;
    final shieldTop = cy - shieldHeight * 0.45;

    // Shield outline glow
    final glowPaint = Paint()
      ..color = AppColors.goldPrimary.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final shieldPath = _createShieldPath(cx, shieldTop, shieldWidth, shieldHeight);
    canvas.drawPath(shieldPath, glowPaint);

    // Shield gradient fill
    final shieldFillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.backgroundLight.withValues(alpha: 0.6),
          AppColors.backgroundDark.withValues(alpha: 0.8),
        ],
      ).createShader(Rect.fromLTWH(cx - shieldWidth / 2, shieldTop, shieldWidth, shieldHeight));
    canvas.drawPath(shieldPath, shieldFillPaint);

    // Shield border
    final borderPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.goldLight,
          AppColors.goldPrimary,
          AppColors.goldDark,
        ],
      ).createShader(Rect.fromLTWH(cx - shieldWidth / 2, shieldTop, shieldWidth, shieldHeight))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawPath(shieldPath, borderPaint);

    // Inner border
    final innerShield = _createShieldPath(cx, shieldTop + 6, shieldWidth - 12, shieldHeight - 12);
    final innerPaint = Paint()
      ..color = AppColors.goldPrimary.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(innerShield, innerPaint);
  }

  Path _createShieldPath(double cx, double top, double width, double height) {
    final path = Path();
    final halfW = width / 2;

    path.moveTo(cx, top);
    // Top right curve
    path.quadraticBezierTo(cx + halfW * 0.3, top, cx + halfW, top + height * 0.08);
    // Right side
    path.lineTo(cx + halfW, top + height * 0.5);
    // Bottom right curve to point
    path.quadraticBezierTo(cx + halfW * 0.6, top + height * 0.8, cx, top + height);
    // Bottom left curve
    path.quadraticBezierTo(cx - halfW * 0.6, top + height * 0.8, cx - halfW, top + height * 0.5);
    // Left side
    path.lineTo(cx - halfW, top + height * 0.08);
    // Top left curve
    path.quadraticBezierTo(cx - halfW * 0.3, top, cx, top);

    path.close();
    return path;
  }

  void _drawScales(Canvas canvas, Size size, double cx, double cy) {
    final goldPaint = Paint()
      ..color = AppColors.goldPrimary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    final goldFillPaint = Paint()
      ..color = AppColors.goldPrimary
      ..style = PaintingStyle.fill;

    final scaleY = cy - size.height * 0.05;
    final beamWidth = size.width * 0.32;
    final chainLength = size.height * 0.16;

    // Vertical pillar
    canvas.drawLine(
      Offset(cx, scaleY - size.height * 0.18),
      Offset(cx, scaleY + size.height * 0.08),
      goldPaint,
    );

    // Pillar base
    final basePath = Path();
    basePath.moveTo(cx - size.width * 0.1, scaleY + size.height * 0.08);
    basePath.lineTo(cx + size.width * 0.1, scaleY + size.height * 0.08);
    basePath.lineTo(cx + size.width * 0.07, scaleY + size.height * 0.12);
    basePath.lineTo(cx - size.width * 0.07, scaleY + size.height * 0.12);
    basePath.close();

    final basePaint = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.goldLight, AppColors.goldDark],
      ).createShader(Rect.fromLTWH(cx - size.width * 0.1, scaleY, size.width * 0.2, size.height * 0.12))
      ..style = PaintingStyle.fill;
    canvas.drawPath(basePath, basePaint);

    // Top ornament circle
    canvas.drawCircle(
      Offset(cx, scaleY - size.height * 0.18),
      3.5,
      goldFillPaint,
    );

    // Horizontal beam
    canvas.drawLine(
      Offset(cx - beamWidth, scaleY - size.height * 0.12),
      Offset(cx + beamWidth, scaleY - size.height * 0.12),
      goldPaint,
    );

    // Left chain and pan
    _drawChainAndPan(canvas, cx - beamWidth, scaleY - size.height * 0.12, chainLength, size.width * 0.1, goldPaint, goldFillPaint);

    // Right chain and pan
    _drawChainAndPan(canvas, cx + beamWidth, scaleY - size.height * 0.12, chainLength, size.width * 0.1, goldPaint, goldFillPaint);
  }

  void _drawChainAndPan(Canvas canvas, double x, double topY, double chainLen, double panRadius, Paint strokePaint, Paint fillPaint) {
    // Chain lines
    final bottomY = topY + chainLen;
    canvas.drawLine(Offset(x, topY), Offset(x - panRadius * 0.6, bottomY), strokePaint);
    canvas.drawLine(Offset(x, topY), Offset(x + panRadius * 0.6, bottomY), strokePaint);

    // Pan (curved arc)
    final panPaint = Paint()
      ..shader = LinearGradient(
        colors: [AppColors.goldLight, AppColors.goldDark],
      ).createShader(Rect.fromLTWH(x - panRadius, bottomY - 4, panRadius * 2, 12))
      ..style = PaintingStyle.fill;

    final panPath = Path();
    panPath.moveTo(x - panRadius * 0.6, bottomY);
    panPath.quadraticBezierTo(x, bottomY + panRadius * 0.5, x + panRadius * 0.6, bottomY);
    panPath.close();
    canvas.drawPath(panPath, panPaint);

    // Pan border
    final panBorderPaint = Paint()
      ..color = AppColors.goldPrimary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(panPath, panBorderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for laurel wreath branches
class LaurelWreathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    _drawBranch(canvas, size, isLeft: true);
    _drawBranch(canvas, size, isLeft: false);
  }

  void _drawBranch(Canvas canvas, Size size, {required bool isLeft}) {
    final paint = Paint()
      ..color = AppColors.goldPrimary
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = AppColors.goldDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final startX = isLeft ? cx - size.width * 0.22 : cx + size.width * 0.22;
    final direction = isLeft ? -1.0 : 1.0;

    // Branch stem
    final stemPath = Path();
    stemPath.moveTo(startX, size.height * 0.85);
    stemPath.quadraticBezierTo(
      startX + direction * size.width * 0.18,
      size.height * 0.5,
      startX + direction * size.width * 0.05,
      size.height * 0.15,
    );
    canvas.drawPath(stemPath, strokePaint);

    // Draw leaves along the stem
    for (int i = 0; i < 7; i++) {
      final t = 0.15 + (i * 0.1);
      // Calculate point on stem curve
      final py = size.height * (0.85 - t * 0.7);
      final px = startX + direction * size.width * 0.18 * sin(t * pi * 0.8) * (1 - t * 0.3);

      _drawLeaf(canvas, px, py, direction, t, size, paint);
    }
  }

  void _drawLeaf(Canvas canvas, double x, double y, double dir, double t, Size size, Paint paint) {
    final leafSize = size.width * 0.05 * (1 - t * 0.3);
    final angle = dir * (0.4 + t * 0.3);

    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(angle);

    final leafPath = Path();
    leafPath.moveTo(0, 0);
    leafPath.quadraticBezierTo(
      leafSize * 0.5 * dir,
      -leafSize * 0.8,
      leafSize * 1.2 * dir,
      -leafSize * 0.3,
    );
    leafPath.quadraticBezierTo(
      leafSize * 0.5 * dir,
      leafSize * 0.2,
      0,
      0,
    );

    final leafPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.goldLight.withValues(alpha: 0.8),
          AppColors.goldDark.withValues(alpha: 0.6),
        ],
      ).createShader(Rect.fromLTWH(-leafSize, -leafSize, leafSize * 3, leafSize * 2));

    canvas.drawPath(leafPath, leafPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Widget that combines the shield logo and laurel wreath
class LawLogo extends StatelessWidget {
  final double size;

  const LawLogo({super.key, this.size = 180});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Laurel wreath behind
          CustomPaint(
            size: Size(size * 1.4, size * 1.1),
            painter: LaurelWreathPainter(),
          ),
          // Shield with scales
          CustomPaint(
            size: Size(size * 0.75, size * 0.85),
            painter: ScalesOfJusticeLogoPainter(),
          ),
        ],
      ),
    );
  }
}

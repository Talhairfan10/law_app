import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Custom painter for the hero illustration — gavel and law books
class HeroIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Background atmosphere glow
    _drawAtmosphere(canvas, size);

    // Draw books stack
    _drawBooks(canvas, size);

    // Draw gavel
    _drawGavel(canvas, size);

    // Draw ambient particles
    _drawParticles(canvas, size);
  }

  void _drawAtmosphere(Canvas canvas, Size size) {
    // Warm golden ambient glow from center
    final glowPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.8,
        colors: [
          AppColors.goldPrimary.withValues(alpha: 0.08),
          AppColors.purpleDark.withValues(alpha: 0.05),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), glowPaint);
  }

  void _drawBooks(Canvas canvas, Size size) {
    final bookX = size.width * 0.55;
    final bookY = size.height * 0.3;
    final bookWidth = size.width * 0.38;
    final bookHeight = size.height * 0.55;

    // Book colors — rich leather tones
    final bookColors = [
      const Color(0xFF2D1810), // Dark brown
      const Color(0xFF1A2040), // Dark navy
      const Color(0xFF3D1520), // Dark burgundy
    ];

    for (int i = 0; i < 3; i++) {
      final offsetX = i * 4.0;
      final offsetY = i * -bookHeight * 0.28;
      final bx = bookX + offsetX;
      final by = bookY + offsetY;

      // Book shadow
      final shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(bx + 3, by + 3, bookWidth, bookHeight * 0.28),
          const Radius.circular(2),
        ),
        shadowPaint,
      );

      // Book body
      final bookPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            bookColors[i],
            bookColors[i].withValues(alpha: 0.8),
          ],
        ).createShader(Rect.fromLTWH(bx, by, bookWidth, bookHeight * 0.28));
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(bx, by, bookWidth, bookHeight * 0.28),
          const Radius.circular(2),
        ),
        bookPaint,
      );

      // Book spine highlight
      final spinePaint = Paint()
        ..color = AppColors.goldPrimary.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawLine(
        Offset(bx + 2, by + 3),
        Offset(bx + 2, by + bookHeight * 0.28 - 3),
        spinePaint,
      );

      // Gold text lines on spine
      final textPaint = Paint()
        ..color = AppColors.goldPrimary.withValues(alpha: 0.6)
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round;
      final textY = by + bookHeight * 0.14;
      canvas.drawLine(
        Offset(bx + bookWidth * 0.2, textY - 3),
        Offset(bx + bookWidth * 0.8, textY - 3),
        textPaint,
      );
      canvas.drawLine(
        Offset(bx + bookWidth * 0.3, textY + 3),
        Offset(bx + bookWidth * 0.7, textY + 3),
        textPaint,
      );
    }
  }

  void _drawGavel(Canvas canvas, Size size) {
    final gavelCenterX = size.width * 0.35;
    final gavelCenterY = size.height * 0.5;

    // Gavel handle
    final handlePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF8B6914),
          const Color(0xFF6B4F10),
          const Color(0xFF4A3508),
        ],
      ).createShader(Rect.fromLTWH(gavelCenterX - 40, gavelCenterY - 5, 80, 10));

    canvas.save();
    canvas.translate(gavelCenterX, gavelCenterY);
    canvas.rotate(-0.5); // Slight angle

    // Handle
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-45, -5, 90, 10),
        const Radius.circular(3),
      ),
      handlePaint,
    );

    // Gavel head
    final headPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF8B6914),
          Color(0xFFAA8420),
          Color(0xFF6B4F10),
        ],
      ).createShader(const Rect.fromLTWH(-55, -18, 20, 36));

    // Left head
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-55, -18, 20, 36),
        const Radius.circular(4),
      ),
      headPaint,
    );

    // Right head
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(35, -18, 20, 36),
        const Radius.circular(4),
      ),
      headPaint,
    );

    // Gold band on heads
    final bandPaint = Paint()
      ..color = AppColors.goldPrimary.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-53, -15, 16, 30),
        const Radius.circular(3),
      ),
      bandPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(37, -15, 16, 30),
        const Radius.circular(3),
      ),
      bandPaint,
    );

    canvas.restore();

    // Gavel base/sound block
    final basePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF6B4F10),
          const Color(0xFF4A3508),
        ],
      ).createShader(Rect.fromLTWH(gavelCenterX - 30, gavelCenterY + 35, 60, 15));

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(gavelCenterX - 30, gavelCenterY + 35, 60, 15),
        const Radius.circular(3),
      ),
      basePaint,
    );

    // Base shadow
    final baseShadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawOval(
      Rect.fromLTWH(gavelCenterX - 28, gavelCenterY + 48, 56, 6),
      baseShadow,
    );
  }

  void _drawParticles(Canvas canvas, Size size) {
    final random = Random(42); // Fixed seed for consistency
    final particlePaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 15; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = 0.5 + random.nextDouble() * 1.5;
      final opacity = 0.1 + random.nextDouble() * 0.3;

      particlePaint.color = AppColors.goldPrimary.withValues(alpha: opacity);
      canvas.drawCircle(Offset(x, y), radius, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

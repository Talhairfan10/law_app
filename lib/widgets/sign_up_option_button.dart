import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// A premium sign-up option row button (e.g. "Continue with Google").
class SignUpOptionButton extends StatefulWidget {
  final IconData? icon;
  final Widget? customIcon;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final Color? iconBorderColor;
  final String label;
  final VoidCallback? onPressed;
  final double iconSize;

  const SignUpOptionButton({
    super.key,
    this.icon,
    this.customIcon,
    this.iconColor,
    required this.label,
    this.iconBackgroundColor,
    this.iconBorderColor,
    this.onPressed,
    this.iconSize = 24,
  }) : assert(
         icon != null || customIcon != null,
         'Must provide either icon or customIcon',
       );

  @override
  State<SignUpOptionButton> createState() => _SignUpOptionButtonState();
}

class _SignUpOptionButtonState extends State<SignUpOptionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.975,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) =>
          Transform.scale(scale: _scaleAnimation.value, child: child),
      child: GestureDetector(
        onTapDown: (_) {
          setState(() => _isPressed = true);
          _controller.forward();
        },
        onTapUp: (_) {
          setState(() => _isPressed = false);
          _controller.reverse();
          widget.onPressed?.call();
        },
        onTapCancel: () {
          setState(() => _isPressed = false);
          _controller.reverse();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            color: _isPressed
                ? AppColors.purpleDark.withValues(alpha: 0.75)
                : AppColors.backgroundLight.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.purpleAccent.withValues(alpha: 0.4),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              // Circular icon container
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color:
                      widget.iconBackgroundColor ??
                      AppColors.purpleAccent.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: widget.iconBorderColor != null
                      ? Border.all(color: widget.iconBorderColor!, width: 1.5)
                      : null,
                ),
                alignment: Alignment.center,
                child:
                    widget.customIcon ??
                    Icon(
                      widget.icon,
                      color: widget.iconColor,
                      size: widget.iconSize,
                    ),
              ),
              const SizedBox(width: 16),
              // Label
              Expanded(
                child: Text(
                  widget.label,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
              // Trailing arrow — larger, white
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white.withValues(alpha: 0.5),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A circular feature chip used at the bottom of the sign-up screen.
class FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const FeatureChip({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 52, // Increased icon circle size
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.purpleAccent.withValues(alpha: 0.1),
            border: Border.all(
              color: AppColors.goldPrimary.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: Icon(
            icon,
            color: AppColors.goldPrimary,
            size: 24, // Matched icon sizes
          ),
        ),
        const SizedBox(height: 10), // Increased spacing
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 12, // Match text alignment and spacing
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

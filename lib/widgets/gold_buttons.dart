import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Premium gold-filled CTA button with icon and arrow
class GoldButton extends StatefulWidget {
  final String label;
  final IconData leadingIcon;
  final VoidCallback? onPressed;

  const GoldButton({
    super.key,
    required this.label,
    required this.leadingIcon,
    this.onPressed,
  });

  @override
  State<GoldButton> createState() => _GoldButtonState();
}

class _GoldButtonState extends State<GoldButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97,
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
        child: Container(
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            color: AppColors.goldPrimary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.goldPrimary.withValues(
                  alpha: _isPressed ? 0.2 : 0.35,
                ),
                blurRadius: _isPressed ? 8 : 16,
                offset: const Offset(0, 4),
                spreadRadius: _isPressed ? 0 : 2,
              ),
              BoxShadow(
                color: AppColors.goldLight.withValues(alpha: 0.1),
                blurRadius: 1,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 24),
              Icon(
                widget.leadingIcon,
                color: AppColors.backgroundDark.withValues(alpha: 0.8),
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.backgroundDark,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.backgroundDark.withValues(alpha: 0.7),
                size: 20,
              ),
              const SizedBox(width: 24),
            ],
          ),
        ),
      ),
    );
  }
}

/// Premium outlined button with gold border
class GoldOutlineButton extends StatefulWidget {
  final String label;
  final IconData leadingIcon;
  final VoidCallback? onPressed;

  const GoldOutlineButton({
    super.key,
    required this.label,
    required this.leadingIcon,
    this.onPressed,
  });

  @override
  State<GoldOutlineButton> createState() => _GoldOutlineButtonState();
}

class _GoldOutlineButtonState extends State<GoldOutlineButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97,
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
        child: Container(
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            color: _isPressed
                ? AppColors.goldPrimary.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.goldPrimary.withValues(alpha: 0.6),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 24),
              Icon(widget.leadingIcon, color: AppColors.goldPrimary, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.goldPrimary,
                size: 20,
              ),
              const SizedBox(width: 24),
            ],
          ),
        ),
      ),
    );
  }
}

/// Social login circle button
class SocialButton extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onPressed;

  const SocialButton({
    super.key,
    required this.icon,
    this.iconColor = AppColors.textPrimary,
    this.onPressed,
  });

  @override
  State<SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<SocialButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: _isPressed
              ? Colors.white.withValues(alpha: 0.9)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.transparent, width: 0),
          boxShadow: [
            if (!_isPressed)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Icon(widget.icon, color: widget.iconColor, size: 24),
      ),
    );
  }
}

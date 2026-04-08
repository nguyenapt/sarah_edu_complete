import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Đồng bộ gradient với nút Continue trong Exercise.
const Color kAuthPrimary = Color(0xFF006286);
const Color kAuthPrimaryContainer = Color(0xFF2DB7F2);

const LinearGradient kAuthPrimaryCtaGradient = LinearGradient(
  colors: [kAuthPrimary, kAuthPrimaryContainer],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _AuthBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: kAuthPrimary,
              size: 26,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          title,
          style: const TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.6,
            height: 1.05,
            color: Color(0xFF132B45),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            height: 1.35,
            color: const Color(0xFF445D7F).withValues(alpha: 0.85),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.textInputAction,
    this.onFieldSubmitted,
    this.autofillHints,
  });

  final TextEditingController controller;
  final String label;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Color(0xFF445D7F),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          autofillHints: autofillHints,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: const Color(0xFF445D7F).withValues(alpha: 0.55),
              fontWeight: FontWeight.w600,
            ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.9),
            prefixIcon: prefixIcon == null
                ? null
                : Icon(prefixIcon, color: kAuthPrimary.withValues(alpha: 0.8)),
            suffixIcon: suffixIcon,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(999),
              borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(999),
              borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.18)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(999),
              borderSide: const BorderSide(color: kAuthPrimary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(999),
              borderSide: BorderSide(color: Colors.red.withValues(alpha: 0.7)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(999),
              borderSide: BorderSide(color: Colors.red.withValues(alpha: 0.8)),
            ),
          ),
        ),
      ],
    );
  }
}

class AuthGradientButton extends StatelessWidget {
  const AuthGradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: enabled ? kAuthPrimaryCtaGradient : null,
          color: enabled ? null : Colors.grey.shade400,
          borderRadius: BorderRadius.circular(999),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: kAuthPrimary.withValues(alpha: 0.22),
                    blurRadius: 16,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onPressed : null,
            borderRadius: BorderRadius.circular(999),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.2,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthBackground extends StatelessWidget {
  const _AuthBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _AuthBackgroundPainter(),
      child: const ColoredBox(
        color: Color(0xFFF4F9FF),
      ),
    );
  }
}

class _AuthBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFFF4F9FF);
    canvas.drawRect(Offset.zero & size, bg);

    final gradient = LinearGradient(
      colors: [
        kAuthPrimaryContainer.withValues(alpha: 0.22),
        Colors.white.withValues(alpha: 0.0),
      ],
      begin: Alignment.bottomRight,
      end: Alignment.topLeft,
    );
    final rect = Offset.zero & size;
    final p = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, p);

    // Subtle dotted pattern.
    final dotPaint = Paint()
      ..color = kAuthPrimary.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;

    const spacing = 22.0;
    final radius = 1.2;
    final cols = (size.width / spacing).ceil();
    final rows = (size.height / spacing).ceil();
    for (var y = 0; y <= rows; y++) {
      for (var x = 0; x <= cols; x++) {
        final dx = x * spacing + (y.isEven ? 0 : spacing / 2);
        final dy = y * spacing;
        if (dx < 0 || dx > size.width || dy < 0 || dy > size.height) continue;
        canvas.drawCircle(Offset(dx, dy), radius, dotPaint);
      }
    }

    // A soft glow blob.
    final glow = Paint()
      ..color = kAuthPrimaryContainer.withValues(alpha: 0.10)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 48);
    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.2),
      math.min(size.width, size.height) * 0.28,
      glow,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


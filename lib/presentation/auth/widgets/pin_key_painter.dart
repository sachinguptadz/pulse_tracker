import 'package:flutter/material.dart';

class PinKeyPainter extends CustomPainter {
  PinKeyPainter({required this.pressed, required this.accent, required this.dark});

  final bool pressed;
  final Color accent;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final radius = Radius.circular(24);
    final rrect = RRect.fromRectAndRadius(rect, radius);
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: pressed
            ? [accent.withOpacity(0.42), accent.withOpacity(0.22)]
            : dark
                ? [Colors.white.withOpacity(0.12), Colors.white.withOpacity(0.05)]
                : [Colors.white.withOpacity(0.95), accent.withOpacity(0.12)],
      ).createShader(rect);
    canvas.drawRRect(rrect, paint);
    final border = Paint()
      ..color = pressed ? accent.withOpacity(0.7) : Colors.white.withOpacity(dark ? 0.08 : 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawRRect(rrect, border);
  }

  @override
  bool shouldRepaint(covariant PinKeyPainter oldDelegate) => oldDelegate.pressed != pressed || oldDelegate.accent != accent || oldDelegate.dark != dark;
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

class FocusCountdownPainter extends CustomPainter {
  FocusCountdownPainter({required this.progress, required this.color, required this.dark});

  final double progress;
  final Color color;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2 - 7;
    final bg = Paint()
      ..color = dark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.08)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final fg = Paint()
      ..shader = SweepGradient(colors: [color, color.withOpacity(0.45), color]).createShader(rect)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bg);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -math.pi / 2, math.pi * 2 * progress.clamp(0, 1), false, fg);
  }

  @override
  bool shouldRepaint(covariant FocusCountdownPainter oldDelegate) => oldDelegate.progress != progress || oldDelegate.color != color || oldDelegate.dark != dark;
}

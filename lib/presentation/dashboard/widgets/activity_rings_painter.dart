import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../data/models/habit.dart';

class ActivityRingsPainter extends CustomPainter {
  ActivityRingsPainter({required this.habits, required this.progress, required this.dark});

  final List<Habit> habits;
  final double progress;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final base = math.min(size.width, size.height) / 2;
    for (var i = 0; i < 3; i++) {
      final habit = i < habits.length ? habits[i] : null;
      final radius = base - 18 - i * 28;
      final stroke = 18.0;
      final rect = Rect.fromCircle(center: center, radius: radius);
      final bg = Paint()
        ..color = dark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06)
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      canvas.drawArc(rect, -math.pi / 2, math.pi * 2, false, bg);
      if (habit == null) continue;
      final value = habit.ratio * progress;
      final fg = Paint()
        ..shader = SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: math.pi * 1.5,
          colors: [Color(habit.accent), Color(habit.accent).withOpacity(0.55), Color(habit.accent)],
        ).createShader(rect)
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * value, false, fg);
    }
    final text = TextPainter(
      text: TextSpan(
        text: '${habits.isEmpty ? 0 : (habits.map((e) => e.ratio).reduce((a, b) => a + b) / habits.length * 100).round()}%',
        style: TextStyle(color: dark ? Colors.white : const Color(0xFF1C2030), fontSize: 34, fontWeight: FontWeight.w800),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    text.paint(canvas, center - Offset(text.width / 2, text.height / 2));
  }

  @override
  bool shouldRepaint(covariant ActivityRingsPainter oldDelegate) => oldDelegate.habits != habits || oldDelegate.progress != progress || oldDelegate.dark != dark;
}

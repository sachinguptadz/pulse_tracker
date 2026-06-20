import 'package:flutter/material.dart';

class TaskCheckPainter extends CustomPainter {
  TaskCheckPainter({required this.progress, required this.color, required this.dark});

  final double progress;
  final Color color;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 3;
    final bg = Paint()
      ..color = dark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bg);
    final ring = Paint()
      ..color = color
      ..strokeWidth = 3.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, ring);
    if (progress <= 0) return;
    final path = Path()
      ..moveTo(size.width * 0.28, size.height * 0.52)
      ..lineTo(size.width * 0.44, size.height * 0.66)
      ..lineTo(size.width * 0.74, size.height * 0.35);
    final metric = path.computeMetrics().first;
    final extract = metric.extractPath(0, metric.length * progress.clamp(0, 1));
    canvas.drawPath(extract, ring..strokeWidth = 4.4);
  }

  @override
  bool shouldRepaint(covariant TaskCheckPainter oldDelegate) => oldDelegate.progress != progress || oldDelegate.color != color || oldDelegate.dark != dark;
}

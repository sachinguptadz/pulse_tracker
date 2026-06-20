import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class PinDotsPainter extends CustomPainter {
  PinDotsPainter({required this.count, required this.color});

  final int count;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final gap = size.width / 4;
    for (var i = 0; i < 4; i++) {
      final filled = i < count;
      final center = Offset(gap * i + gap / 2, size.height / 2);
      final paint = Paint()
        ..color = filled ? AppColors.coral : color.withOpacity(0.16)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, filled ? 8 : 6, paint);
    }
  }

  @override
  bool shouldRepaint(covariant PinDotsPainter oldDelegate) => oldDelegate.count != count || oldDelegate.color != color;
}

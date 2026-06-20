import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class PulseLogo extends StatelessWidget {
  const PulseLogo({this.size = 52, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.82, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutBack,
      builder: (_, value, child) => Transform.scale(scale: value, child: child),
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _PulseLogoPainter(dark: Theme.of(context).brightness == Brightness.dark),
        ),
      ),
    );
  }
}

class _PulseLogoPainter extends CustomPainter {
  const _PulseLogoPainter({required this.dark});

  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = size.shortestSide / 2;
    final bg = Paint()
      ..shader = const LinearGradient(colors: [AppColors.coral, AppColors.orange, AppColors.mint, AppColors.blue]).createShader(rect);
    canvas.drawCircle(center, radius, bg);

    final ring = Paint()
      ..color = Colors.white.withOpacity(0.82)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.07
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius * 0.67), -math.pi * 0.84, math.pi * 1.55, false, ring);

    final pulse = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.07
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(size.width * 0.25, size.height * 0.56)
      ..lineTo(size.width * 0.38, size.height * 0.56)
      ..lineTo(size.width * 0.46, size.height * 0.39)
      ..lineTo(size.width * 0.58, size.height * 0.68)
      ..lineTo(size.width * 0.66, size.height * 0.52)
      ..lineTo(size.width * 0.78, size.height * 0.52);
    canvas.drawPath(path, pulse);

    final shine = Paint()..color = Colors.white.withOpacity(dark ? 0.16 : 0.24);
    canvas.drawCircle(Offset(size.width * 0.34, size.height * 0.26), radius * 0.18, shine);
  }

  @override
  bool shouldRepaint(covariant _PulseLogoPainter oldDelegate) => oldDelegate.dark != dark;
}

import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class PulseBackground extends StatelessWidget {
  const PulseBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 460),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? [AppColors.ink, const Color(0xFF151927), const Color(0xFF0D1020)]
              : [const Color(0xFFFFF5E7), const Color(0xFFEFFFF3), const Color(0xFFFFFAF2)],
        ),
      ),
      child: Stack(
        children: [
          AnimatedPositioned(duration: const Duration(milliseconds: 520), curve: Curves.easeOutCubic, top: -120, left: -80, child: _Blob(color: AppColors.orange.withOpacity(dark ? 0.18 : 0.28), size: 260)),
          AnimatedPositioned(duration: const Duration(milliseconds: 520), curve: Curves.easeOutCubic, top: 110, right: -110, child: _Blob(color: AppColors.mint.withOpacity(dark ? 0.16 : 0.28), size: 280)),
          AnimatedPositioned(duration: const Duration(milliseconds: 520), curve: Curves.easeOutCubic, bottom: -120, left: 20, child: _Blob(color: AppColors.lavender.withOpacity(dark ? 0.15 : 0.24), size: 260)),
          child,
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 44, sigmaY: 44),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 460),
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}

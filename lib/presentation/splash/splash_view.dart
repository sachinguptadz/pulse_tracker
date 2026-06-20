import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/widgets/pulse_background.dart';
import '../../core/widgets/pulse_logo.dart';
import 'splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PulseBackground(
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (_, value, child) => Opacity(
              opacity: value,
              child: Transform.translate(offset: Offset(0, 24 * (1 - value)), child: child),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const PulseLogo(size: 116),
                const SizedBox(height: 20),
                Text('PulseTrack', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 6),
                Text('Habits. Focus. Momentum.', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/pulse_background.dart';
import '../dashboard/widgets/focus_countdown_painter.dart';
import 'focus_controller.dart';

class FocusView extends GetView<FocusController> {
  const FocusView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PulseBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton.filledTonal(onPressed: () => Get.back<void>(), icon: const Icon(Icons.arrow_back_rounded)),
                const SizedBox(height: 26),
                Text('Focus session', style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: 8),
                Obx(() => Text(controller.sessionId.value, style: Theme.of(context).textTheme.bodyLarge)),
                const Spacer(),
                Center(
                  child: Obx(() {
                    final seconds = controller.seconds.value;
                    final progress = 1 - seconds / (25 * 60);
                    return SizedBox(
                      width: 280,
                      height: 280,
                      child: CustomPaint(
                        painter: FocusCountdownPainter(progress: progress, color: AppColors.blue, dark: Theme.of(context).brightness == Brightness.dark),
                        child: Center(
                          child: Text('${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}', style: Theme.of(context).textTheme.displayLarge),
                        ),
                      ),
                    );
                  }),
                ),
                const Spacer(),
                GlassCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Obx(() => FilledButton.icon(
                              onPressed: controller.toggle,
                              icon: Icon(controller.running.value ? Icons.pause_rounded : Icons.play_arrow_rounded),
                              label: Text(controller.running.value ? 'Pause' : 'Start'),
                            )),
                      ),
                      const SizedBox(width: 12),
                      IconButton.filledTonal(onPressed: controller.reset, icon: const Icon(Icons.restart_alt_rounded)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/font_scale.dart';
import '../../core/theme/theme_controller.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/pulse_background.dart';
import '../../core/widgets/pulse_logo.dart';
import '../../core/widgets/skeleton_box.dart';
import '../../data/models/habit.dart';
import 'dashboard_controller.dart';
import 'widgets/activity_rings_painter.dart';
import 'widgets/focus_countdown_painter.dart';
import 'widgets/habit_detail_sheet.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PulseBackground(
        child: SafeArea(
          child: Obx(() => controller.loading.value ? const _DashboardSkeleton() : const _DashboardContent()),
        ),
      ),
    );
  }
}

class _DashboardContent extends GetView<DashboardController> {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    return Obx(() {
      final large = themeController.fontScale.value.isLarge;
      return CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TopBar(),
                  const SizedBox(height: 24),
                  Text('Your connected daily coach', style: Theme.of(context).textTheme.headlineLarge),
                  const SizedBox(height: 8),
                  Text(DateFormat('EEEE, d MMM').format(DateTime.now()), style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 20),
                  large ? const _LargeMetrics() : const _NormalMetrics(),
                  const SizedBox(height: 18),
                  _RingsCard(),
                  const SizedBox(height: 18),
                  _FocusCard(),
                  const SizedBox(height: 18),
                  _TodayTasks(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _TopBar extends GetView<DashboardController> {
  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    return Row(
      children: [
        const PulseLogo(size: 48),
        const SizedBox(width: 12),
        Expanded(child: Text('PulseTrack', style: Theme.of(context).textTheme.titleLarge)),
        Obx(() {
          final dark = themeController.themeMode.value == ThemeMode.dark || Get.isDarkMode;
          return GlassCard(
            padding: const EdgeInsets.all(8),
            radius: 18,
            onTap: () => themeController.toggleMode(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 360),
              curve: Curves.easeOutCubic,
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: dark ? AppColors.blue.withOpacity(0.18) : AppColors.orange.withOpacity(0.18),
                borderRadius: BorderRadius.circular(16),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                transitionBuilder: (child, animation) => RotationTransition(turns: animation, child: ScaleTransition(scale: animation, child: child)),
                child: Icon(dark ? Icons.dark_mode_rounded : Icons.light_mode_rounded, key: ValueKey(dark), size: 20),
              ),
            ),
          );
        }),
        const SizedBox(width: 10),
        GlassCard(
          padding: const EdgeInsets.all(10),
          radius: 18,
          onTap: () async {
            await Get.toNamed(AppRoutes.tasks);
            if (Get.isRegistered<DashboardController>()) {
              await controller.load();
            }
          },
          child: const Icon(Icons.view_agenda_rounded, size: 20),
        ),
      ],
    );
  }
}

class _NormalMetrics extends GetView<DashboardController> {
  const _NormalMetrics();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _MetricCard(label: 'Recovery', value: '${((controller.habits.firstOrNull?.ratio ?? 0) * 100).round()}%', color: AppColors.coral)),
        const SizedBox(width: 12),
        Expanded(child: _MetricCard(label: 'Overdue', value: '${controller.overdueCount.value}', color: AppColors.orange)),
      ],
    );
  }
}

class _LargeMetrics extends GetView<DashboardController> {
  const _LargeMetrics();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MetricCard(label: 'Recovery', value: '${((controller.habits.firstOrNull?.ratio ?? 0) * 100).round()}%', color: AppColors.coral),
        const SizedBox(height: 12),
        _MetricCard(label: 'Overdue', value: '${controller.overdueCount.value}', color: AppColors.orange),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        children: [
          Container(width: 12, height: 42, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12))),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: Theme.of(context).textTheme.headlineMedium),
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingsCard extends GetView<DashboardController> {
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Today rings', style: Theme.of(context).textTheme.titleLarge)),
              Obx(() => controller.syncActive.value ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : IconButton(onPressed: controller.runSync, icon: const Icon(Icons.sync_rounded))),
            ],
          ),
          const SizedBox(height: 14),
          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 1100),
              curve: Curves.easeOutCubic,
              builder: (_, value, __) => GestureDetector(
                onTapUp: (_) {
                  if (controller.habits.isNotEmpty) {
                    final habit = controller.habits.first;
                    controller.selectHabit(habit);
                    showHabitDetail(context, habit);
                  }
                },
                child: SizedBox(
                  width: 230,
                  height: 230,
                  child: CustomPaint(painter: ActivityRingsPainter(habits: controller.habits, progress: value, dark: Theme.of(context).brightness == Brightness.dark)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: controller.habits.map((habit) => _HabitChip(habit: habit)).toList(),
          ),
        ],
      ),
    );
  }
}

class _HabitChip extends GetView<DashboardController> {
  const _HabitChip({required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        controller.selectHabit(habit);
        showHabitDetail(context, habit);
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: Color(habit.accent).withOpacity(0.14), borderRadius: BorderRadius.circular(18)),
        child: Text('${habit.name} ${(habit.ratio * 100).round()}%', style: Theme.of(context).textTheme.labelLarge),
      ),
    );
  }
}

class _FocusCard extends GetView<DashboardController> {
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        children: [
          Obx(() {
            final seconds = controller.focusSeconds.value;
            final progress = 1 - seconds / (25 * 60);
            return SizedBox(
              width: 86,
              height: 86,
              child: CustomPaint(
                painter: FocusCountdownPainter(progress: progress, color: AppColors.blue, dark: Theme.of(context).brightness == Brightness.dark),
                child: Center(child: Text('${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}', style: Theme.of(context).textTheme.labelLarge)),
              ),
            );
          }),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Focus sprint', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text('25 minutes of clean work. Tiny promise, big payoff.', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Obx(() => IconButton.filled(
                onPressed: controller.toggleFocus,
                icon: Icon(controller.focusRunning.value ? Icons.pause_rounded : Icons.play_arrow_rounded),
              )),
        ],
      ),
    );
  }
}

class _TodayTasks extends GetView<DashboardController> {
  @override
  Widget build(BuildContext context) {
    final visible = controller.tasks.take(3).toList();
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Next actions', style: Theme.of(context).textTheme.titleLarge)),
              TextButton(onPressed: () async { await Get.toNamed(AppRoutes.tasks); if (Get.isRegistered<DashboardController>()) { await controller.load(); } }, child: const Text('Open board')),
            ],
          ),
          const SizedBox(height: 10),
          ...visible.map((task) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(width: 10, height: 10, decoration: BoxDecoration(color: Color(task.accent), shape: BoxShape.circle)),
                    const SizedBox(width: 12),
                    Expanded(child: Text(task.title, style: Theme.of(context).textTheme.bodyLarge)),
                    Text(DateFormat('HH:mm').format(task.dueAt), style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16),
          SkeletonBox(width: 160, height: 42),
          SizedBox(height: 26),
          SkeletonBox(width: 280, height: 46),
          SizedBox(height: 16),
          SkeletonBox(height: 92),
          SizedBox(height: 16),
          SkeletonBox(height: 300),
          SizedBox(height: 16),
          SkeletonBox(height: 128),
        ],
      ),
    );
  }
}

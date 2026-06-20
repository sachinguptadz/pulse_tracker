import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../data/models/habit.dart';

void showHabitDetail(BuildContext context, Habit habit) {
  Get.bottomSheet(
    _HabitDetailSheet(habit: habit),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

class _HabitDetailSheet extends StatelessWidget {
  const _HabitDetailSheet({required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: GlassCard(
        radius: 36,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 56,
                height: 5,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
              ),
            ),
            Row(
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Color(habit.accent).withOpacity(0.18)),
                  child: Icon(Icons.auto_graph_rounded, color: Color(habit.accent), size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(habit.name, style: Theme.of(context).textTheme.titleLarge),
                      Text(habit.category, style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('${habit.progress.toStringAsFixed(habit.progress % 1 == 0 ? 0 : 1)} / ${habit.target.toStringAsFixed(habit.target % 1 == 0 ? 0 : 1)}', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(value: habit.ratio, minHeight: 14, color: Color(habit.accent), backgroundColor: Color(habit.accent).withOpacity(0.14)),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _TinyStat(label: 'Streak', value: '${habit.streak} days', color: AppColors.orange)),
                const SizedBox(width: 12),
                Expanded(child: _TinyStat(label: 'Status', value: habit.ratio >= 1 ? 'Done' : 'On track', color: AppColors.mint)),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(onPressed: () => Get.back<void>(), child: const Text('Looks good')),
            ),
          ],
        ),
      ),
    );
  }
}

class _TinyStat extends StatelessWidget {
  const _TinyStat({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: color.withOpacity(0.14), borderRadius: BorderRadius.circular(22)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

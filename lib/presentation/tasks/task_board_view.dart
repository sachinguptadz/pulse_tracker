import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/pulse_background.dart';
import '../../core/widgets/skeleton_box.dart';
import 'task_controller.dart';
import 'widgets/spring_task_card.dart';

class TaskBoardView extends GetView<TaskController> {
  const TaskBoardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTaskSheet(context, controller),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add task'),
      ),
      body: PulseBackground(
        child: SafeArea(
          child: Obx(() {
            if (controller.loading.value) return const _TaskSkeleton();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
                  child: Row(
                    children: [
                      IconButton.filledTonal(onPressed: () => Get.back<void>(), icon: const Icon(Icons.arrow_back_rounded)),
                      const SizedBox(width: 12),
                      Expanded(child: Text('Gesture board', style: Theme.of(context).textTheme.headlineMedium)),
                      IconButton.filled(onPressed: () => _showAddTaskSheet(context, controller), icon: const Icon(Icons.add_rounded)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 4, 22, 16),
                  child: Text('Add your own habits. Tap to complete. Long press to reorder.', style: Theme.of(context).textTheme.bodyMedium),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    child: controller.tasks.isEmpty
                        ? const _EmptyTasks()
                        : ReorderableListView.builder(
                            key: const ValueKey('task-list'),
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                            itemCount: controller.tasks.length,
                            onReorder: controller.reorder,
                            proxyDecorator: (child, index, animation) {
                              return ScaleTransition(scale: Tween<double>(begin: 1, end: 1.03).animate(animation), child: child);
                            },
                            itemBuilder: (_, index) {
                              final task = controller.tasks[index];
                              return AnimatedSlide(
                                key: ValueKey(task.id),
                                offset: Offset.zero,
                                duration: Duration(milliseconds: 180 + index * 35),
                                curve: Curves.easeOutCubic,
                                child: SpringTaskCard(
                                  key: ValueKey('card-${task.id}'),
                                  task: task,
                                  onComplete: () => controller.complete(task.id),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

void _showAddTaskSheet(BuildContext context, TaskController controller) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _AddTaskSheet(controller: controller),
  );
}

class _AddTaskSheet extends StatefulWidget {
  const _AddTaskSheet({required this.controller});

  final TaskController controller;

  @override
  State<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<_AddTaskSheet> {
  final _title = TextEditingController();
  final _category = TextEditingController(text: 'Personal');
  final _note = TextEditingController();
  TimeOfDay _time = const TimeOfDay(hour: 20, minute: 0);

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(14, 0, 14, bottom + 14),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.94, end: 1),
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutBack,
        builder: (_, value, child) => Transform.scale(scale: value, alignment: Alignment.bottomCenter, child: child),
        child: GlassCard(
          radius: 34,
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 44, height: 5, decoration: BoxDecoration(color: AppColors.muted.withOpacity(0.45), borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 18),
              Text('Add a new task', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              Text('Create any habit or action you want to track today.', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 18),
              TextField(
                controller: _title,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Task name', hintText: 'Example: Read 20 pages'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _category,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Category', hintText: 'Personal, Focus, Health'),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: ['Personal', 'Focus', 'Health', 'Fitness', 'Mind'].map((item) {
                  return ActionChip(
                    label: Text(item),
                    onPressed: () => setState(() => _category.text = item),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _note,
                minLines: 1,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Note', hintText: 'Optional'),
              ),
              const SizedBox(height: 14),
              InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: _pickTime,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: Theme.of(context).dividerColor)),
                  child: Row(
                    children: [
                      const Icon(Icons.schedule_rounded),
                      const SizedBox(width: 12),
                      Expanded(child: Text('Due today at ${_time.format(context)}', style: Theme.of(context).textTheme.bodyLarge)),
                      const Icon(Icons.expand_more_rounded),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: () => Get.back<void>(), child: const Text('Cancel'))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.add_task_rounded),
                      label: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _save() async {
    final now = DateTime.now();
    final dueAt = DateTime(now.year, now.month, now.day, _time.hour, _time.minute);
    await widget.controller.addTask(title: _title.text, category: _category.text, note: _note.text, dueAt: dueAt);
  }

  @override
  void dispose() {
    _title.dispose();
    _category.dispose();
    _note.dispose();
    super.dispose();
  }
}

class _EmptyTasks extends StatelessWidget {
  const _EmptyTasks();

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const ValueKey('empty'),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_task_rounded, size: 46),
              const SizedBox(height: 12),
              Text('No tasks yet', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              Text('Tap Add task and build your own daily routine.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskSkeleton extends StatelessWidget {
  const _TaskSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          SizedBox(height: 22),
          SkeletonBox(height: 48),
          SizedBox(height: 18),
          SkeletonBox(height: 116),
          SizedBox(height: 12),
          SkeletonBox(height: 116),
          SizedBox(height: 12),
          SkeletonBox(height: 116),
        ],
      ),
    );
  }
}

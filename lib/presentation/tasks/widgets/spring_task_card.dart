import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../data/models/task.dart';
import 'task_check_painter.dart';

class SpringTaskCard extends StatefulWidget {
  const SpringTaskCard({required this.task, required this.onComplete, super.key});

  final Task task;
  final VoidCallback onComplete;

  @override
  State<SpringTaskCard> createState() => _SpringTaskCardState();
}

class _SpringTaskCardState extends State<SpringTaskCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController.unbounded(vsync: this)
    ..addListener(() => setState(() {}));
  double _drag = 0;
  bool _checkAnimating = false;

  @override
  Widget build(BuildContext context) {
    final value = _drag + _controller.value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() => _drag = (_drag + details.delta.dx).clamp(0, 130));
        },
        onPanEnd: (details) {
          if (_drag > 78 && !widget.task.isCompleted) {
            _playCheck();
          }
          final simulation = SpringSimulation(const SpringDescription(mass: 1, stiffness: 180, damping: 16), _drag, 0, details.velocity.pixelsPerSecond.dx / 800);
          _drag = 0;
          _controller.animateWith(simulation);
        },
        onTap: () {
          if (!widget.task.isCompleted) _playCheck();
        },
        child: Transform.translate(
          offset: Offset(value, 0),
          child: GlassCard(
            padding: const EdgeInsets.all(18),
            radius: 28,
            child: Row(
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: CustomPaint(
                    painter: TaskCheckPainter(
                      progress: widget.task.isCompleted || _checkAnimating ? 1 : 0,
                      color: Color(widget.task.accent),
                      dark: Theme.of(context).brightness == Brightness.dark,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.task.title, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 5),
                      Text('${widget.task.category} · ${DateFormat('HH:mm').format(widget.task.dueAt)}', style: Theme.of(context).textTheme.bodyMedium),
                      if (widget.task.note.isNotEmpty) ...[
                        const SizedBox(height: 5),
                        Text(widget.task.note, style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ],
                  ),
                ),
                const Icon(Icons.drag_indicator_rounded, color: AppColors.muted),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _playCheck() async {
    setState(() => _checkAnimating = true);
    await Future<void>.delayed(const Duration(milliseconds: 160));
    widget.onComplete();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

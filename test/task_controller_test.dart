import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pulsetrack/core/services/haptic_service.dart';
import 'package:pulsetrack/core/services/storage_service.dart';
import 'package:pulsetrack/data/models/task.dart';
import 'package:pulsetrack/data/repositories/task_repository.dart';
import 'package:pulsetrack/domain/use_cases/complete_task.dart';
import 'package:pulsetrack/domain/use_cases/get_tasks.dart';
import 'package:pulsetrack/presentation/tasks/task_controller.dart';

import 'test_helpers.dart';

class FakeTaskRepository extends TaskRepository {
  FakeTaskRepository() : super(FakeStorageService());

  final List<Task> items = [
    Task(id: '1', title: 'A', category: 'Focus', dueAt: DateTime(2026), accent: 0xFFFF7A59, order: 0),
    Task(id: '2', title: 'B', category: 'Move', dueAt: DateTime(2026), accent: 0xFF70E0AE, order: 1),
  ];

  @override
  Future<List<Task>> getTasks() async => items;

  @override
  Future<void> saveAll(List<Task> tasks) async {
    items
      ..clear()
      ..addAll(tasks);
  }

  @override
  Future<void> complete(String id) async {
    final index = items.indexWhere((task) => task.id == id);
    items[index] = items[index].copyWith(isCompleted: true);
  }
}

void main() {
  setUp(resetGetX);

  test('reorder updates task order', () async {
    final repo = FakeTaskRepository();
    Get.put<TaskRepository>(repo);
    Get.put<GetTasks>(GetTasks(repo));
    Get.put<CompleteTask>(CompleteTask(repo));
    Get.put<HapticService>(HapticService());
    final controller = TaskController();

    await controller.load();
    controller.reorder(0, 2);

    expect(controller.tasks.first.id, '2');
    expect(controller.tasks.last.order, 1);
  });

  test('complete marks task done', () async {
    final repo = FakeTaskRepository();
    Get.put<TaskRepository>(repo);
    Get.put<GetTasks>(GetTasks(repo));
    Get.put<CompleteTask>(CompleteTask(repo));
    Get.put<HapticService>(HapticService());
    final controller = TaskController();

    await controller.load();
    await controller.complete('1');

    expect(controller.tasks.firstWhere((task) => task.id == '1').isCompleted, true);
  });
}

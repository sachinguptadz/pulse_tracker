import 'package:get/get.dart';

import '../../core/services/haptic_service.dart';
import '../../data/models/task.dart';
import '../../data/repositories/task_repository.dart';
import '../../domain/use_cases/complete_task.dart';
import '../../domain/use_cases/get_tasks.dart';

class TaskController extends GetxController {
  final GetTasks _getTasks = Get.find<GetTasks>();
  final CompleteTask _completeTask = Get.find<CompleteTask>();
  final TaskRepository _repository = Get.find<TaskRepository>();
  final HapticService _haptic = Get.find<HapticService>();

  final RxBool loading = true.obs;
  final RxList<Task> tasks = <Task>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
    debounce(tasks, (_) => _saveOrder(), time: const Duration(milliseconds: 350));
  }

  Future<void> load() async {
    loading.value = true;
    tasks.assignAll(await _getTasks());
    loading.value = false;
  }

  Future<void> addTask({required String title, required String category, required String note, required DateTime dueAt}) async {
    final cleanTitle = title.trim();
    final cleanCategory = category.trim().isEmpty ? 'Personal' : category.trim();
    if (cleanTitle.length < 2) {
      await _haptic.error();
      Get.snackbar('Task title needed', 'Please write at least 2 characters');
      return;
    }
    final task = Task(
      id: 'task-${DateTime.now().microsecondsSinceEpoch}',
      title: cleanTitle,
      category: cleanCategory,
      note: note.trim(),
      dueAt: dueAt,
      accent: _accentFor(cleanCategory),
      order: tasks.length,
    );
    tasks.add(task);
    await _repository.save(task);
    await _haptic.success();
    Get.back<void>();
    Get.snackbar('Task added', '$cleanTitle is ready on your board');
  }

  Future<void> complete(String id) async {
    await _completeTask(id);
    await _haptic.success();
    await load();
  }

  Future<void> delete(String id) async {
    await _repository.delete(id);
    tasks.removeWhere((task) => task.id == id);
    await _haptic.light();
  }

  void reorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final item = tasks.removeAt(oldIndex);
    tasks.insert(newIndex, item);
    for (var i = 0; i < tasks.length; i++) {
      tasks[i] = tasks[i].copyWith(order: i);
    }
    _haptic.tick();
  }

  int _accentFor(String category) {
    final value = category.toLowerCase();
    if (value.contains('focus')) return 0xFF78A7FF;
    if (value.contains('work')) return 0xFF78A7FF;
    if (value.contains('health')) return 0xFF70E0AE;
    if (value.contains('water')) return 0xFF70E0AE;
    if (value.contains('mind')) return 0xFFFF7A59;
    if (value.contains('fitness')) return 0xFFD8F36A;
    return 0xFFFF8E4F;
  }

  Future<void> _saveOrder() async {
    if (tasks.isEmpty) return;
    await _repository.saveAll(tasks.toList());
  }
}

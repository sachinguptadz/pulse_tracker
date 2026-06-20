import '../../core/services/storage_service.dart';
import '../models/task.dart';

class TaskRepository {
  TaskRepository(this._storage);

  final StorageService _storage;

  Future<List<Task>> getTasks() => _storage.readTasks();

  Future<void> save(Task task) => _storage.saveTask(task);

  Future<void> saveAll(List<Task> tasks) => _storage.saveTasks(tasks);

  Future<void> delete(String id) => _storage.deleteTask(id);

  Future<void> complete(String id) async {
    final tasks = await getTasks();
    final next = tasks.map((task) {
      if (task.id != id) return task;
      return task.copyWith(isCompleted: true, completedAt: DateTime.now());
    }).toList();
    await saveAll(next);
  }
}

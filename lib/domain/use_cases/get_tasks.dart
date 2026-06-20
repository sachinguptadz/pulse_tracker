import '../../data/models/task.dart';
import '../../data/repositories/task_repository.dart';

class GetTasks {
  const GetTasks(this._repository);

  final TaskRepository _repository;

  Future<List<Task>> call() => _repository.getTasks();
}

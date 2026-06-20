import '../../data/repositories/task_repository.dart';

class CompleteTask {
  const CompleteTask(this._repository);

  final TaskRepository _repository;

  Future<void> call(String id) => _repository.complete(id);
}

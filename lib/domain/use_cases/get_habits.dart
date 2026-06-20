import '../../data/models/habit.dart';
import '../../data/repositories/habit_repository.dart';

class GetHabits {
  const GetHabits(this._repository);

  final HabitRepository _repository;

  Future<List<Habit>> call() => _repository.getHabits();
}

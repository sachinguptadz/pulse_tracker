import '../../core/services/storage_service.dart';
import '../models/habit.dart';

class HabitRepository {
  HabitRepository(this._storage);

  final StorageService _storage;

  Future<List<Habit>> getHabits() => _storage.readHabits();

  Future<void> saveAll(List<Habit> habits) => _storage.saveHabits(habits);
}

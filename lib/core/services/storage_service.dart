import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../data/models/habit.dart';
import '../../data/models/task.dart';

class StorageService extends GetxService {
  late final Box<Task> _taskBox;
  late final Box<Habit> _habitBox;
  late final Box<dynamic> _settingsBox;

  Future<StorageService> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(TaskAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(HabitAdapter());
    _taskBox = await _openBox<Task>('tasks');
    _habitBox = await _openBox<Habit>('habits');
    _settingsBox = await _openBox<dynamic>('settings');
    await _seedIfNeeded();
    return this;
  }

  Future<Box<T>> _openBox<T>(String name) async {
    try {
      return await Hive.openBox<T>(name);
    } catch (_) {
      await Hive.deleteBoxFromDisk(name);
      return Hive.openBox<T>(name);
    }
  }

  Future<List<Task>> readTasks() async {
    final tasks = _taskBox.values.toList()..sort((a, b) => a.order.compareTo(b.order));
    return tasks;
  }

  Future<List<Habit>> readHabits() async => _habitBox.values.toList();

  Future<void> saveTask(Task task) => _taskBox.put(task.id, task);

  Future<void> deleteTask(String id) => _taskBox.delete(id);

  Future<void> saveTasks(List<Task> tasks) async {
    await _taskBox.clear();
    final map = {for (final task in tasks) task.id: task};
    await _taskBox.putAll(map);
  }

  Future<void> saveHabits(List<Habit> habits) async {
    await _habitBox.clear();
    final map = {for (final habit in habits) habit.id: habit};
    await _habitBox.putAll(map);
  }

  bool get hasPinSetup => _settingsBox.get('pin_setup_done', defaultValue: false) as bool;

  bool get isAuthenticated => hasPinSetup && (_settingsBox.get('auth_ok', defaultValue: false) as bool);

  bool get biometricEnabled => _settingsBox.get('biometric_enabled', defaultValue: false) as bool;

  Future<void> saveAuth(bool value) => _settingsBox.put('auth_ok', value);

  Future<void> saveBiometricEnabled(bool value) => _settingsBox.put('biometric_enabled', value);

  String get pin => _settingsBox.get('pin', defaultValue: '') as String;

  Future<void> savePin(String value) async {
    await _settingsBox.put('pin', value);
    await _settingsBox.put('pin_setup_done', true);
    await _settingsBox.put('auth_ok', false);
  }

  bool verifyPin(String value) => hasPinSetup && value == pin;

  ThemeMode get themeMode {
    final raw = _settingsBox.get('theme_mode', defaultValue: 'system') as String;
    return switch (raw) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> saveThemeMode(ThemeMode mode) {
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    return _settingsBox.put('theme_mode', value);
  }

  DateTime? get lastSyncAt {
    final raw = _settingsBox.get('last_sync_at') as String?;
    return raw == null ? null : DateTime.tryParse(raw);
  }

  Future<void> saveLastSync(DateTime value) => _settingsBox.put('last_sync_at', value.toIso8601String());

  Future<void> _seedIfNeeded() async {
    if (_habitBox.isEmpty) {
      await _habitBox.putAll({
        'habit-mind': const Habit(id: 'habit-mind', name: 'Mind reset', category: 'Recovery', target: 10, progress: 7, streak: 12, accent: 0xFFFF7A59),
        'habit-steps': const Habit(id: 'habit-steps', name: 'Daily movement', category: 'Strain', target: 10000, progress: 7200, streak: 5, accent: 0xFFD8F36A),
        'habit-water': const Habit(id: 'habit-water', name: 'Hydration', category: 'Fuel', target: 8, progress: 5, streak: 8, accent: 0xFF70E0AE),
      });
    }
    if (_taskBox.isEmpty) {
      final now = DateTime.now();
      final tasks = <Task>[
        Task(id: 'task-1', title: 'Ten minute breathwork', category: 'Recovery', note: 'Keep it calm and slow', dueAt: DateTime(now.year, now.month, now.day, 9, 30), accent: 0xFFFF7A59, order: 0),
        Task(id: 'task-2', title: 'Walk 7,000 steps', category: 'Strain', note: 'Small steps count', dueAt: DateTime(now.year, now.month, now.day, 18), accent: 0xFFD8F36A, order: 1),
        Task(id: 'task-3', title: 'Drink two bottles of water', category: 'Fuel', note: 'Before evening coffee', dueAt: DateTime(now.year, now.month, now.day, 16), accent: 0xFF70E0AE, order: 2),
        Task(id: 'task-4', title: '25 minute focus session', category: 'Focus', note: 'No phone on desk', dueAt: DateTime(now.year, now.month, now.day, 14), accent: 0xFF78A7FF, order: 3),
      ];
      await _taskBox.putAll({for (final task in tasks) task.id: task});
    }
  }
}

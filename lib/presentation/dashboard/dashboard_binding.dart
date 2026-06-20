import 'package:get/get.dart';

import '../../data/repositories/habit_repository.dart';
import '../../data/repositories/task_repository.dart';
import '../../domain/use_cases/get_habits.dart';
import '../../domain/use_cases/get_tasks.dart';
import '../../core/services/storage_service.dart';
import 'dashboard_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HabitRepository>(() => HabitRepository(Get.find<StorageService>()));
    Get.lazyPut<TaskRepository>(() => TaskRepository(Get.find<StorageService>()));
    Get.lazyPut<GetHabits>(() => GetHabits(Get.find<HabitRepository>()));
    Get.lazyPut<GetTasks>(() => GetTasks(Get.find<TaskRepository>()));
    Get.lazyPut<DashboardController>(() => DashboardController());
  }
}

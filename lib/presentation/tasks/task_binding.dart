import 'package:get/get.dart';

import '../../core/services/storage_service.dart';
import '../../data/repositories/task_repository.dart';
import '../../domain/use_cases/complete_task.dart';
import '../../domain/use_cases/get_tasks.dart';
import 'task_controller.dart';

class TaskBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TaskRepository>(() => TaskRepository(Get.find<StorageService>()));
    Get.lazyPut<GetTasks>(() => GetTasks(Get.find<TaskRepository>()));
    Get.lazyPut<CompleteTask>(() => CompleteTask(Get.find<TaskRepository>()));
    Get.lazyPut<TaskController>(() => TaskController());
  }
}

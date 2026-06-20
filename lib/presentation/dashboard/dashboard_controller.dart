import 'dart:async';

import 'package:get/get.dart';

import '../../core/services/haptic_service.dart';
import '../../core/services/sync_service.dart';
import '../../data/models/habit.dart';
import '../../data/models/task.dart';
import '../../domain/use_cases/get_habits.dart';
import '../../domain/use_cases/get_tasks.dart';

class DashboardController extends GetxController {
  final GetHabits _getHabits = Get.find<GetHabits>();
  final GetTasks _getTasks = Get.find<GetTasks>();
  final SyncService _sync = Get.find<SyncService>();
  final HapticService _haptic = Get.find<HapticService>();

  final RxBool loading = true.obs;
  final RxList<Habit> habits = <Habit>[].obs;
  final RxList<Task> tasks = <Task>[].obs;
  final RxInt overdueCount = 0.obs;
  final RxBool syncActive = false.obs;
  final RxInt focusSeconds = (25 * 60).obs;
  final RxBool focusRunning = false.obs;

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    load();
    ever(focusRunning, (running) {
      if (running) {
        _startTimer();
      } else {
        _timer?.cancel();
      }
    });
  }

  Future<void> load() async {
    loading.value = true;
    habits.assignAll(await _getHabits());
    tasks.assignAll(await _getTasks());
    overdueCount.value = tasks.where((task) => task.isOverdue).length;
    loading.value = false;
  }

  Future<void> runSync() async {
    syncActive.value = true;
    overdueCount.value = await _sync.syncNow();
    syncActive.value = false;
  }

  void selectHabit(Habit habit) {
    _haptic.light();
  }

  void toggleFocus() {
    focusRunning.toggle();
    _haptic.light();
  }

  void resetFocus() {
    focusRunning.value = false;
    focusSeconds.value = 25 * 60;
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (focusSeconds.value <= 1) {
        focusSeconds.value = 0;
        focusRunning.value = false;
        _haptic.success();
      } else {
        focusSeconds.value--;
      }
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}

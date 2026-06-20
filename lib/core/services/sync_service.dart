import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'storage_service.dart';

class SyncService extends GetxService {
  static const MethodChannel _native = MethodChannel('pulsetrack/sync_native');

  final StorageService _storage = Get.find<StorageService>();

  Future<void> scheduleBackgroundSync() async {
    try {
      await _native.invokeMethod<void>('schedule');
    } catch (_) {}
  }

  Future<int> syncNow() async {
    final tasks = await _storage.readTasks();
    final overdue = tasks.where((task) => task.isOverdue).length;
    await _storage.saveLastSync(DateTime.now());
    try {
      await _native.invokeMethod<void>('flushBadge', {'overdue': overdue});
    } catch (_) {}
    return overdue;
  }
}

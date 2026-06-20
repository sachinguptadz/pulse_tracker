import 'dart:async';

import 'package:get/get.dart';

import '../../core/routes/app_routes.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/sync_service.dart';

class SplashController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  final SyncService _syncService = Get.find<SyncService>();
  bool _opened = false;

  @override
  void onReady() {
    super.onReady();
    _open();
  }

  Future<void> _open() async {
    if (_opened) return;
    _opened = true;
    unawaited(_syncService.scheduleBackgroundSync());
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (isClosed) return;
    final route = _storage.isAuthenticated && _storage.hasPinSetup ? AppRoutes.dashboard : AppRoutes.auth;
    Get.offAllNamed(route);
  }
}

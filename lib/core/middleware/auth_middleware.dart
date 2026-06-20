import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../routes/app_routes.dart';
import '../services/storage_service.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final storage = Get.find<StorageService>();
    if (!storage.hasPinSetup || !storage.isAuthenticated) {
      return const RouteSettings(name: AppRoutes.auth);
    }
    return null;
  }
}

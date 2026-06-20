import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../routes/app_routes.dart';
import '../services/deep_link_service.dart';
import '../services/storage_service.dart';

class DeepLinkMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final deepLink = Get.find<DeepLinkService>();
    final storage = Get.find<StorageService>();
    if (deepLink.pendingLink.value != null && !storage.isAuthenticated) {
      return const RouteSettings(name: AppRoutes.auth);
    }
    return null;
  }
}

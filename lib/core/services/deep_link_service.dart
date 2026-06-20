import 'dart:async';

import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../routes/app_routes.dart';
import 'storage_service.dart';

class DeepLinkService extends GetxService {
  static const EventChannel _events = EventChannel('pulsetrack/deep_links');
  static const MethodChannel _methods = MethodChannel('pulsetrack/deep_link_method');

  final StorageService _storage = Get.find<StorageService>();
  final Rxn<Uri> pendingLink = Rxn<Uri>();
  StreamSubscription<dynamic>? _sub;

  @override
  void onInit() {
    super.onInit();
    _loadInitialLink();
    _sub = _events.receiveBroadcastStream().listen((event) {
      final uri = Uri.tryParse(event.toString());
      if (uri != null) handle(uri);
    }, onError: (_) {});
  }

  Future<void> _loadInitialLink() async {
    try {
      final raw = await _methods.invokeMethod<String>('initialLink');
      final uri = raw == null ? null : Uri.tryParse(raw);
      if (uri != null) handle(uri);
    } catch (_) {}
  }

  void handle(Uri uri) {
    if (!_storage.isAuthenticated) {
      pendingLink.value = uri;
      Get.offAllNamed(AppRoutes.auth);
      return;
    }
    open(uri);
  }

  void openPending() {
    final uri = pendingLink.value;
    if (uri == null) return;
    pendingLink.value = null;
    open(uri);
  }

  void open(Uri uri) {
    final segments = uri.pathSegments;
    final section = uri.scheme == 'pulsetrack' ? uri.host : (segments.isNotEmpty ? segments.first : null);
    final id = uri.scheme == 'pulsetrack'
        ? (segments.isNotEmpty ? segments.first : null)
        : (segments.length > 1 ? segments[1] : null);
    if (section == 'habit' && id != null) {
      Get.offAllNamed(AppRoutes.dashboard, arguments: {'habitId': id});
      return;
    }
    if (section == 'focus') {
      Get.offAllNamed(AppRoutes.focus, arguments: {'sessionId': id ?? 'session-25'});
      return;
    }
    Get.offAllNamed(AppRoutes.dashboard);
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}

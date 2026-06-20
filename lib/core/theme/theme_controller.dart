import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../services/storage_service.dart';
import 'font_scale.dart';

class ThemeController extends GetxController {
  static const EventChannel _fontChannel = EventChannel('pulsetrack/font_scale');

  final StorageService _storage = Get.find<StorageService>();
  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;
  final Rx<FontScaleLevel> fontScale = FontScaleLevel.normal.obs;

  StreamSubscription<dynamic>? _fontSub;

  @override
  void onInit() {
    super.onInit();
    themeMode.value = _storage.themeMode;
    _listenFontScale();
    WidgetsBinding.instance.platformDispatcher.onPlatformBrightnessChanged = () {
      if (themeMode.value == ThemeMode.system) {
        themeMode.refresh();
      }
    };
  }

  Future<void> setMode(ThemeMode mode) async {
    themeMode.value = mode;
    await _storage.saveThemeMode(mode);
    Get.changeThemeMode(mode);
  }

  Future<void> toggleMode() async {
    final current = Get.isDarkMode ? ThemeMode.light : ThemeMode.dark;
    await setMode(current);
  }

  void _listenFontScale() {
    _fontSub = _fontChannel.receiveBroadcastStream().listen((event) {
      fontScale.value = FontScaleLevelX.fromNativeValue(event);
    }, onError: (_) {
      fontScale.value = FontScaleLevel.normal;
    });
  }

  @override
  void onClose() {
    _fontSub?.cancel();
    super.onClose();
  }
}

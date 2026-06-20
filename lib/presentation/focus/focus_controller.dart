import 'dart:async';

import 'package:get/get.dart';

import '../../core/services/haptic_service.dart';

class FocusController extends GetxController {
  final HapticService _haptic = Get.find<HapticService>();
  final RxInt seconds = (25 * 60).obs;
  final RxBool running = false.obs;
  final RxString sessionId = 'session-25'.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map && args['sessionId'] is String) {
      sessionId.value = args['sessionId'] as String;
    }
    ever(running, (value) => value ? _start() : _timer?.cancel());
  }

  void toggle() {
    running.toggle();
    _haptic.light();
  }

  void reset() {
    running.value = false;
    seconds.value = 25 * 60;
  }

  void _start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (seconds.value <= 1) {
        seconds.value = 0;
        running.value = false;
        _haptic.success();
      } else {
        seconds.value--;
      }
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}

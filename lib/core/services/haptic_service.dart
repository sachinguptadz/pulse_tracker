import 'package:flutter/services.dart';
import 'package:get/get.dart';

class HapticService extends GetxService {
  static const MethodChannel _channel = MethodChannel('pulsetrack/haptic');

  Future<void> light() => _play('light');

  Future<void> success() => _play('success');

  Future<void> error() => _play('error');

  Future<void> tick() => _play('light');

  Future<void> _play(String pattern) async {
    try {
      await _channel.invokeMethod<void>('play', {'pattern': pattern});
    } catch (_) {}
  }
}

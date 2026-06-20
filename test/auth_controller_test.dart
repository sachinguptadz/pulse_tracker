import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pulsetrack/core/services/deep_link_service.dart';
import 'package:pulsetrack/core/services/haptic_service.dart';
import 'package:pulsetrack/core/services/storage_service.dart';
import 'package:pulsetrack/presentation/auth/auth_controller.dart';

import 'test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(resetGetX);

  test('pin fallback unlocks with correct pin', () async {
    final storage = FakeStorageService();
    Get.put<StorageService>(storage);
    Get.put<HapticService>(HapticService());
    Get.put<DeepLinkService>(FakeDeepLinkService());
    Get.put<AuthController>(AuthController());

    final controller = Get.find<AuthController>();
    controller.status.value = AuthStatus.pinFallback;
    for (final digit in [2, 4, 6, 8]) {
      await controller.inputDigit(digit);
    }

    expect(storage.auth, true);
    expect(controller.status.value, AuthStatus.unlocked);
  });

  test('wrong pin returns typed error', () async {
    final storage = FakeStorageService();
    Get.put<StorageService>(storage);
    Get.put<HapticService>(HapticService());
    Get.put<DeepLinkService>(FakeDeepLinkService());
    final controller = AuthController();
    controller.status.value = AuthStatus.pinFallback;

    for (final digit in [1, 1, 1, 1]) {
      await controller.inputDigit(digit);
    }

    expect(controller.error.value, isA<PinIncorrect>());
    expect(controller.pinDigits, isEmpty);
  });
}

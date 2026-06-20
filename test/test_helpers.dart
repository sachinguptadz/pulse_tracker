import 'package:get/get.dart';
import 'package:pulsetrack/core/services/deep_link_service.dart';
import 'package:pulsetrack/core/services/storage_service.dart';

class FakeStorageService extends StorageService {
  bool auth = false;
  bool pinReady = true;
  bool bio = false;
  String fakePin = '2468';

  @override
  bool get hasPinSetup => pinReady;

  @override
  bool get isAuthenticated => auth && pinReady;

  @override
  bool get biometricEnabled => bio;

  @override
  Future<void> saveAuth(bool value) async {
    auth = value;
  }

  @override
  Future<void> saveBiometricEnabled(bool value) async {
    bio = value;
  }

  @override
  String get pin => fakePin;

  @override
  Future<void> savePin(String value) async {
    fakePin = value;
    pinReady = true;
    auth = false;
  }

  @override
  bool verifyPin(String value) => pinReady && value == fakePin;
}

class FakeDeepLinkService extends DeepLinkService {
  @override
  void onInit() {}

  @override
  void openPending() {}

  @override
  void open(Uri uri) {}
}

void resetGetX() {
  Get.testMode = true;
  Get.reset();
}

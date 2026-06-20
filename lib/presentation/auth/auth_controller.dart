import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';

import '../../core/routes/app_routes.dart';
import '../../core/services/deep_link_service.dart';
import '../../core/services/haptic_service.dart';
import '../../core/services/storage_service.dart';

sealed class AuthErrorState {
  const AuthErrorState(this.message);
  final String message;
}

class BiometricNotAvailable extends AuthErrorState {
  const BiometricNotAvailable() : super('Biometric unlock is not available on this device');
}

class BiometricFailed extends AuthErrorState {
  const BiometricFailed() : super('Biometric authentication failed');
}

class PinIncorrect extends AuthErrorState {
  const PinIncorrect() : super('Incorrect PIN');
}

class PinMismatch extends AuthErrorState {
  const PinMismatch() : super('PIN did not match. Set it again');
}

enum AuthStatus { locked, setupPin, confirmPin, askBiometric, checking, pinFallback, unlocked }

class AuthController extends GetxController {
  final LocalAuthentication _auth = LocalAuthentication();
  final StorageService _storage = Get.find<StorageService>();
  final HapticService _haptic = Get.find<HapticService>();
  final DeepLinkService _deepLink = Get.find<DeepLinkService>();

  final Rx<AuthStatus> status = AuthStatus.locked.obs;
  final Rxn<AuthErrorState> error = Rxn<AuthErrorState>();
  final RxList<int> pinDigits = <int>[].obs;
  final RxBool shakePin = false.obs;
  final RxBool biometricAvailable = false.obs;
  final RxString biometricLabel = 'Biometric'.obs;

  String _pendingPin = '';

  bool get isSetupFlow => status.value == AuthStatus.setupPin || status.value == AuthStatus.confirmPin;

  @override
  void onReady() {
    super.onReady();
    _prepare();
  }

  Future<void> _prepare() async {
    await _readBiometrics();
    if (!_storage.hasPinSetup) {
      status.value = AuthStatus.setupPin;
      return;
    }
    if (_storage.biometricEnabled && biometricAvailable.value) {
      await authenticateWithBiometrics();
    } else {
      status.value = AuthStatus.pinFallback;
    }
  }

  Future<void> _readBiometrics() async {
    try {
      final supported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      final types = await _auth.getAvailableBiometrics();
      biometricAvailable.value = supported && canCheck && types.isNotEmpty;
      biometricLabel.value = _labelFor(types);
    } catch (_) {
      biometricAvailable.value = false;
      biometricLabel.value = 'Biometric';
    }
  }

  String _labelFor(List<BiometricType> types) {
    if (types.contains(BiometricType.face)) return 'Face ID';
    if (types.contains(BiometricType.fingerprint)) return 'Fingerprint';
    if (types.contains(BiometricType.iris)) return 'Iris unlock';
    return 'Biometric';
  }

  Future<void> authenticateWithBiometrics({bool enableAfterSuccess = false}) async {
    await _readBiometrics();
    if (!biometricAvailable.value) {
      status.value = _storage.hasPinSetup ? AuthStatus.pinFallback : AuthStatus.askBiometric;
      error.value = const BiometricNotAvailable();
      return;
    }
    status.value = AuthStatus.checking;
    error.value = null;
    try {
      final ok = await _auth.authenticate(
        localizedReason: enableAfterSuccess ? 'Enable ${biometricLabel.value} for PulseTrack' : 'Unlock PulseTrack',
        options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
      );
      if (ok) {
        if (enableAfterSuccess) await _storage.saveBiometricEnabled(true);
        await _unlock();
      } else {
        status.value = _storage.hasPinSetup ? AuthStatus.pinFallback : AuthStatus.askBiometric;
        error.value = const BiometricFailed();
      }
    } catch (_) {
      // iOS Simulator biometrics can behave differently from a real iPhone.
      status.value = _storage.hasPinSetup ? AuthStatus.pinFallback : AuthStatus.askBiometric;
      error.value = const BiometricFailed();
    }
  }

  Future<void> inputDigit(int digit) async {
    if (pinDigits.length >= 4) return;
    pinDigits.add(digit);
    await _haptic.light();
    if (pinDigits.length != 4) return;
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final value = pinDigits.join();
    if (status.value == AuthStatus.setupPin) {
      _pendingPin = value;
      pinDigits.clear();
      status.value = AuthStatus.confirmPin;
      return;
    }
    if (status.value == AuthStatus.confirmPin) {
      await _finishPinSetup(value);
      return;
    }
    await _verifyPin(value);
  }

  void backspace() {
    if (pinDigits.isNotEmpty) pinDigits.removeLast();
  }

  Future<void> _finishPinSetup(String value) async {
    if (value != _pendingPin) {
      await _haptic.error();
      error.value = const PinMismatch();
      _pendingPin = '';
      pinDigits.clear();
      shakePin.value = true;
      await Future<void>.delayed(const Duration(milliseconds: 260));
      shakePin.value = false;
      status.value = AuthStatus.setupPin;
      return;
    }
    await _storage.savePin(value);
    await _haptic.success();
    pinDigits.clear();
    error.value = null;
    await _readBiometrics();
    if (biometricAvailable.value) {
      status.value = AuthStatus.askBiometric;
    } else {
      await _storage.saveBiometricEnabled(false);
      await _unlock();
    }
  }

  Future<void> chooseBiometric(bool enable) async {
    if (!enable) {
      await _storage.saveBiometricEnabled(false);
      await _unlock();
      return;
    }
    await authenticateWithBiometrics(enableAfterSuccess: true);
  }

  Future<void> _verifyPin(String value) async {
    if (_storage.verifyPin(value)) {
      await _unlock();
      return;
    }
    await _haptic.error();
    error.value = const PinIncorrect();
    shakePin.value = true;
    await Future<void>.delayed(const Duration(milliseconds: 320));
    shakePin.value = false;
    pinDigits.clear();
    Get.snackbar('PIN not matched', 'Please try again');
  }

  Future<void> _unlock() async {
    status.value = AuthStatus.unlocked;
    await _storage.saveAuth(true);
    await _haptic.success();
    if (_deepLink.pendingLink.value != null) {
      _deepLink.openPending();
    } else {
      Get.offAllNamed(AppRoutes.dashboard);
    }
  }
}

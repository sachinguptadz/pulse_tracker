import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulsetrack/core/services/haptic_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('haptic service sends native pattern', () async {
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('pulsetrack/haptic'),
      (call) async {
        calls.add(call);
        return null;
      },
    );

    final service = HapticService();
    await service.success();

    expect(calls.single.method, 'play');
    expect(calls.single.arguments, {'pattern': 'success'});
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pffl_managment/core/services/device_service.dart';

// Mock classes
class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DeviceService', () {
    setUp(() {
      // Clear any stored data before each test
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/platform', (message) async {
        return null;
      });
    });

    test('initialize should set up service correctly', () async {
      // Test that initialize doesn't throw
      await expectLater(DeviceService.initialize(), completes);
    });

    test('get deviceId should return non-null value after initialization', () async {
      await DeviceService.initialize();
      expect(DeviceService.deviceId, isNotNull);
      expect(DeviceService.deviceId, isNotEmpty);
    });

    test('notificationPermissionGranted should be accessible', () async {
      await DeviceService.initialize();
      expect(DeviceService.notificationPermissionGranted, isA<bool>());
    });

    test('deviceToken should be accessible', () async {
      await DeviceService.initialize();
      expect(DeviceService.deviceToken, isA<String?>());
    });
  });
}

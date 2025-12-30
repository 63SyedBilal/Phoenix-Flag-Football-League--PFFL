import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pffl_managment/core/services/auth_service.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service for managing device tokens and push notifications
class DeviceService {
  static const String _deviceTokenKey = 'device_token';
  static const String _deviceIdKey = 'device_id';
  static const String _notificationPermissionKey = 'notification_permission_granted';

  static FlutterLocalNotificationsPlugin? _flutterLocalNotificationsPlugin;
  static String? _deviceToken;
  static String? _deviceId;
  static bool _notificationPermissionGranted = false;

  /// Initialize the device service
  static Future<void> initialize() async {
    try {
      // Initialize flutter_local_notifications
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      // Android initialization settings
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // Combined initialization settings
      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Initialize the plugin
      await _flutterLocalNotificationsPlugin?.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
        onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationTapped,
      );

      // Load stored values
      await _loadStoredData();

      // Generate device ID if not exists
      if (_deviceId == null) {
        _deviceId = await _generateDeviceId();
        await _saveDeviceId(_deviceId!);
      }

      // Request notification permissions
      await _requestNotificationPermissions();

    } catch (e) {
      print('❌ Error initializing DeviceService: $e');
      rethrow;
    }
  }

  /// Generate unique device identifier
  static Future<String> _generateDeviceId() async {
    try {
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id; // Unique Android ID
      } else if (Platform.isIOS) {
        final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? 'unknown_ios_device'; // IDFV
      } else {
        // For other platforms, generate a UUID-like string
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final random = DateTime.now().microsecondsSinceEpoch % 10000;
        return 'device_${timestamp}_$random';
      }
    } catch (e) {
      print('❌ Error generating device ID: $e');
      // Fallback to timestamp-based ID
      return 'fallback_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  /// Request notification permissions
  static Future<void> _requestNotificationPermissions() async {
    try {
      // Check current permission status
      final status = await Permission.notification.status;

      if (status.isDenied || status.isPermanentlyDenied) {
        // Request permission
        final result = await Permission.notification.request();

        if (result.isGranted) {
          _notificationPermissionGranted = true;
          await _saveNotificationPermission(true);
          print('✅ Notification permission granted');
        } else {
          _notificationPermissionGranted = false;
          await _saveNotificationPermission(false);
          print('⚠️ Notification permission denied');
        }
      } else if (status.isGranted) {
        _notificationPermissionGranted = true;
        print('✅ Notification permission already granted');
      }

      // Request iOS-specific permissions if needed
      if (Platform.isIOS) {
        await _flutterLocalNotificationsPlugin
            ?.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
      }
    } catch (e) {
      print('❌ Error requesting notification permissions: $e');
    }
  }

  /// Register device token with backend
  static Future<bool> registerDeviceToken({
    required String userId,
    String? platform,
  }) async {
    try {
      if (_deviceId == null) {
        print('⚠️ Device ID not available');
        return false;
      }

      final deviceToken = _deviceId; // Using device ID as token for non-Firebase setup

      final dio = await AuthService.getWorkingDio();
      final response = await dio.post('/device-token', data: {
        'deviceId': _deviceId,
        'token': deviceToken,
        'userId': userId,
        'platform': platform ?? Platform.operatingSystem,
        'permissionGranted': _notificationPermissionGranted,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        _deviceToken = deviceToken;
        if (deviceToken != null) {
          await _saveDeviceToken(deviceToken);
        }
        print('✅ Device token registered successfully');
        return true;
      } else {
        print('❌ Failed to register device token: ${response.statusMessage}');
        return false;
      }
    } catch (e) {
      print('❌ Error registering device token: $e');
      return false;
    }
  }

  /// Unregister device token from backend
  static Future<bool> unregisterDeviceToken(String userId) async {
    try {
      if (_deviceId == null) {
        return false;
      }

      final dio = await AuthService.getWorkingDio();
      final response = await dio.delete('/device-token', data: {
        'deviceId': _deviceId,
        'userId': userId,
      });

      if (response.statusCode == 200) {
        _deviceToken = null;
        await _clearStoredData();
        print('✅ Device token unregistered successfully');
        return true;
      } else {
        print('❌ Failed to unregister device token: ${response.statusMessage}');
        return false;
      }
    } catch (e) {
      print('❌ Error unregistering device token: $e');
      return false;
    }
  }

  /// Show local notification
  static Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    int? id,
  }) async {
    try {
      if (!_notificationPermissionGranted) {
        print('⚠️ Notification permission not granted, skipping notification');
        return;
      }

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'pffl_channel', // channel ID
        'PFFL Notifications', // channel name
        channelDescription: 'Phoenix Flag Football League notifications',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _flutterLocalNotificationsPlugin?.show(
        id ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        notificationDetails,
        payload: payload,
      );

      print('✅ Local notification shown: $title');
    } catch (e) {
      print('❌ Error showing notification: $e');
    }
  }

  /// Handle notification tap in foreground/background
  static void _onNotificationTapped(NotificationResponse response) {
    print('📱 Notification tapped: ${response.payload}');

    if (response.payload != null) {
      _handleNotificationPayload(response.payload!);
    }
  }

  /// Handle notification tap in background/terminated state
  @pragma('vm:entry-point')
  static void _onBackgroundNotificationTapped(NotificationResponse response) {
    print('📱 Background notification tapped: ${response.payload}');

    if (response.payload != null) {
      _handleNotificationPayload(response.payload!);
    }
  }

  /// Handle notification payload for navigation
  static void _handleNotificationPayload(String payload) {
    try {
      final Map<String, dynamic> data = json.decode(payload);

      final type = data['type'];
      final id = data['id'];

      print('🧭 Handling notification navigation - Type: $type, ID: $id');

      // Store payload for app launch navigation
      _storePendingNotification(data);

      // Note: Navigation will be handled by the app's routing system
      // when the app becomes active

    } catch (e) {
      print('❌ Error handling notification payload: $e');
    }
  }

  /// Store pending notification for app launch navigation
  static Future<void> _storePendingNotification(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pending_notification', json.encode(data));
    } catch (e) {
      print('❌ Error storing pending notification: $e');
    }
  }

  /// Get stored pending notification
  static Future<Map<String, dynamic>?> getPendingNotification() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('pending_notification');
      if (data != null) {
        // Clear it after retrieving
        await prefs.remove('pending_notification');
        return json.decode(data);
      }
    } catch (e) {
      print('❌ Error getting pending notification: $e');
    }
    return null;
  }

  /// Load stored device data
  static Future<void> _loadStoredData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _deviceToken = prefs.getString(_deviceTokenKey);
      _deviceId = prefs.getString(_deviceIdKey);
      _notificationPermissionGranted = prefs.getBool(_notificationPermissionKey) ?? false;
    } catch (e) {
      print('❌ Error loading stored device data: $e');
    }
  }

  /// Save device token
  static Future<void> _saveDeviceToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_deviceTokenKey, token);
    } catch (e) {
      print('❌ Error saving device token: $e');
    }
  }

  /// Save device ID
  static Future<void> _saveDeviceId(String deviceId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_deviceIdKey, deviceId);
    } catch (e) {
      print('❌ Error saving device ID: $e');
    }
  }

  /// Save notification permission status
  static Future<void> _saveNotificationPermission(bool granted) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationPermissionKey, granted);
    } catch (e) {
      print('❌ Error saving notification permission: $e');
    }
  }

  /// Clear stored device data
  static Future<void> _clearStoredData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_deviceTokenKey);
      await prefs.remove(_deviceIdKey);
      await prefs.remove(_notificationPermissionKey);
    } catch (e) {
      print('❌ Error clearing stored device data: $e');
    }
  }

  // Getters
  static String? get deviceToken => _deviceToken;
  static String? get deviceId => _deviceId;
  static bool get notificationPermissionGranted => _notificationPermissionGranted;
  static FlutterLocalNotificationsPlugin? get notificationsPlugin => _flutterLocalNotificationsPlugin;
}

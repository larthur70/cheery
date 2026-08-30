import 'package:cheery/core/constants/app_routes.dart';
import 'package:cheery/core/utils/app_logger.dart';
import 'package:cheery/features/birthday_reminders/domain/notification_failure.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Handles FCM permission, token, and notification presentation (mobile only).
class FcmService {
  FcmService({
    FirebaseMessaging? messaging,
    FlutterLocalNotificationsPlugin? localNotifications,
  })  : _messaging = messaging ?? FirebaseMessaging.instance,
        _localNotifications =
            localNotifications ?? FlutterLocalNotificationsPlugin();

  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications;

  static const _permissionAskedKey = 'cheery_notification_permission_asked';

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'birthday_reminders',
    'Lembretes de aniversário',
    description: 'Avisos diários quando há aniversariantes.',
    importance: Importance.high,
  );

  bool get isSupported {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android;
  }

  String? get platformName {
    if (!isSupported) return null;
    if (defaultTargetPlatform == TargetPlatform.iOS) return 'ios';
    if (defaultTargetPlatform == TargetPlatform.android) return 'android';
    return null;
  }

  /// Deep-link route carried in FCM `data.route` (defaults to home).
  static String routeFromMessage(RemoteMessage message) {
    final route = message.data['route'];
    if (route is String && route.startsWith('/')) return route;
    return AppRoutes.home;
  }

  Future<void> initializeLocalNotifications({
    void Function(String route)? onNotificationTap,
  }) async {
    if (!isSupported) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    // Do not request OS permission here — iOS defaults would show the
    // system alert before our in-app rationale dialog.
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null && payload.startsWith('/')) {
          onNotificationTap?.call(payload);
        } else {
          onNotificationTap?.call(AppRoutes.home);
        }
      },
    );

    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin =
          _localNotifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(_channel);
    }
  }

  Future<bool> isPermissionGranted() async {
    if (!isSupported) return false;
    final settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  Future<bool> requestPermission() async {
    if (!isSupported) {
      throw const NotificationUnsupportedFailure();
    }

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final status = settings.authorizationStatus;
    final granted = status == AuthorizationStatus.authorized ||
        status == AuthorizationStatus.provisional;

    if (!granted) {
      AppLogger.w('FCM permission denied: $status');
    }
    return granted;
  }

  /// Whether the in-app / OS permission flow was already presented.
  Future<bool> hasAskedPermission() async {
    if (!isSupported) return true;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_permissionAskedKey) == true;
  }

  /// Asks once on the first app open (install). Later opens skip the dialog.
  Future<bool?> requestPermissionOnFirstLaunch() async {
    if (!isSupported) return null;

    if (await hasAskedPermission()) {
      return isPermissionGranted();
    }

    final granted = await requestPermission();
    await markPermissionPromptShown();
    return granted;
  }

  /// Marks the OS permission prompt as already handled (e.g. after onboarding).
  Future<void> markPermissionPromptShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_permissionAskedKey, true);
  }

  Future<String?> getToken({int maxAttempts = 12}) async {
    if (!isSupported) return null;

    // iOS: FCM token requires APNs token first; it often arrives a few
    // seconds after registerForRemoteNotifications + permission.
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      String? apns;
      for (var attempt = 0; attempt < maxAttempts; attempt++) {
        apns = await _messaging.getAPNSToken();
        if (apns != null) break;
        await Future<void>.delayed(const Duration(milliseconds: 500));
      }
      if (apns == null) {
        AppLogger.w(
          'APNs token unavailable after ${maxAttempts * 500}ms. '
          'Use a real device, enable Push Notifications capability, '
          'and upload an APNs key in Firebase.',
        );
        return null;
      }
    }

    try {
      return await _messaging.getToken();
    } catch (error, stackTrace) {
      AppLogger.e('getToken failed', error: error, stackTrace: stackTrace);
      return null;
    }
  }

  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  Stream<RemoteMessage> get onMessage => FirebaseMessaging.onMessage;

  Stream<RemoteMessage> get onMessageOpenedApp =>
      FirebaseMessaging.onMessageOpenedApp;

  Future<RemoteMessage?> getInitialMessage() =>
      _messaging.getInitialMessage();

  Future<void> showForegroundNotification(RemoteMessage message) async {
    if (!isSupported) return;

    final notification = message.notification;
    final title = notification?.title ?? '🎉 Aniversariantes hoje!';
    final body = notification?.body ??
        'Abra o Cheery e envie os parabéns aos seus clientes.';
    final route = routeFromMessage(message);

    await _localNotifications.show(
      id: message.hashCode,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: route,
    );
  }
}

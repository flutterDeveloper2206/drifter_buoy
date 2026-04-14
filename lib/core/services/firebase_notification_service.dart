import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:drifter_buoy/firebase_options.dart';
import 'package:drifter_buoy/core/constants/app_routes.dart';
import 'package:drifter_buoy/core/utils/app_logger.dart';
import 'package:drifter_buoy/core/utils/app_router.dart';
import 'package:drifter_buoy/core/utils/navigation_service.dart';

const String _notificationPayloadRouteKey = 'route';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  AppLogger.i('FCM background message: ${message.messageId}');
}

@pragma('vm:entry-point')
void notificationTapBackgroundHandler(NotificationResponse response) {
  FirebaseNotificationService.handleLocalNotificationTap(response);
}

class FirebaseNotificationService {
  FirebaseNotificationService._();

  static final FirebaseNotificationService instance =
      FirebaseNotificationService._();

  /// Must not be read until after [Firebase.initializeApp] — avoid a field
  /// initializer so constructing [instance] does not touch Firebase early.
  FirebaseMessaging get _messaging => FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
        'drifter_buoy_alerts',
        'Drifter Buoy Alerts',
        description: 'Important notifications for drifter buoy updates',
        importance: Importance.high,
      );

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await _requestPermission();
    await _initializeLocalNotifications();

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageTap(initialMessage);
    }

    final token = await _messaging.getToken();
    AppLogger.i('FCM token: $token');

    _isInitialized = true;
  }

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    AppLogger.i('FCM permission: ${settings.authorizationStatus.name}');
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: handleLocalNotificationTap,
      onDidReceiveBackgroundNotificationResponse:
          notificationTapBackgroundHandler,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_androidChannel);
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) {
      return;
    }

    final payload = jsonEncode(<String, String>{
      _notificationPayloadRouteKey: AppRoutes.alertsPath,
    });

    await _localNotifications.show(
      id: message.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: payload,
    );
  }

  void _handleMessageTap(RemoteMessage message) {
    _goToAlertsPage();
  }

  static void handleLocalNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) {
      return;
    }

    try {
      final data = jsonDecode(payload);
      if (data is Map<String, dynamic> &&
          data[_notificationPayloadRouteKey] == AppRoutes.alertsPath) {
        _goToAlertsPage();
      }
    } catch (error, stackTrace) {
      AppLogger.w(
        'Failed to parse notification payload',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  static void _goToAlertsPage() {
    final context = NavigationService.currentContext;
    if (context == null) {
      Future<void>.delayed(const Duration(milliseconds: 300), _goToAlertsPage);
      return;
    }
    AppRouter.router.go(AppRoutes.alertsPath);
  }
}

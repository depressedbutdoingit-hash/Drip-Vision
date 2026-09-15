import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('BG message: ${message.messageId}');
}

class PushNotificationService {
  static final _messaging = FirebaseMessaging.instance;
  static final _localNotifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    final settings = await _messaging.requestPermission(
      alert: true, badge: true, sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    FirebaseMessaging.onMessage.listen((msg) {
      showAlert(
        title: msg.notification?.title ?? 'DripVision',
        body: msg.notification?.body ?? 'Your render is complete',
      );
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<void> showAlert({required String title, required String body}) async {
    const androidDetails = AndroidNotificationDetails(
      'drip_renders',
      'Render Status',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    await _localNotifications.show(
      0, title, body,
      const NotificationDetails(android: androidDetails),
    );
  }

  static Future<String?> getToken() => _messaging.getToken();
}

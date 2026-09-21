import 'package:docxan/core/logging/app_logger.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  AppLogger.debug('FCM en segundo plano: ${message.messageId}');
}

abstract final class PushNotifications {
  static bool isReady = false;
  static String? token;

  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission();
      AppLogger.debug('FCM permiso: ${settings.authorizationStatus}');

      token = await messaging.getToken();
      if (token != null) {
        AppLogger.debug('FCM token: $token');
      }

      messaging.onTokenRefresh.listen((value) {
        token = value;
        AppLogger.debug('FCM token actualizado');
      });

      FirebaseMessaging.onMessage.listen((message) {
        AppLogger.debug(
          'FCM en primer plano: ${message.notification?.title ?? message.messageId}',
        );
      });

      isReady = true;
      AppLogger.debug('FCM listo');
    } catch (error) {
      isReady = false;
      AppLogger.debug('FCM omitido: $error');
    }
  }
}

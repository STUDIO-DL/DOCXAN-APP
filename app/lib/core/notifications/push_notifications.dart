import 'dart:async';

import 'package:docxan/core/logging/app_logger.dart';
import 'package:docxan/core/network/docxan_supabase.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  AppLogger.debug('FCM en segundo plano: ${message.messageId}');
}

abstract final class PushNotifications {
  static bool isReady = false;
  static String? token;

  /// Debe coincidir con `default_notification_channel_id` del AndroidManifest.
  static const _channel = AndroidNotificationChannel(
    'docxan_default',
    'Docxan',
    importance: Importance.high,
  );

  static final _local = FlutterLocalNotificationsPlugin();
  static String? _registeredUserId;

  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      await _local.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
      );
      await _local
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(_channel);

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
        final userId = _registeredUserId;
        if (userId != null) {
          _registeredUserId = null;
          unawaited(registerForUser(userId));
        }
      });

      FirebaseMessaging.onMessage.listen(_showForeground);

      isReady = true;
      AppLogger.debug('FCM listo');
    } catch (error) {
      isReady = false;
      AppLogger.debug('FCM omitido: $error');
    }
  }

  /// Guarda el token en Supabase para que `push-send` pueda llegar a este móvil.
  static Future<void> registerForUser(String userId) async {
    final value = token;
    if (!isReady || value == null || !DocxanSupabase.isReady) return;
    if (_registeredUserId == userId) return;
    try {
      await DocxanSupabase.client.rpc(
        'register_device_token',
        params: {'p_token': value, 'p_platform': 'android'},
      );
      _registeredUserId = userId;
      AppLogger.debug('FCM token registrado en Supabase');
    } catch (error) {
      AppLogger.debug('FCM token no registrado: $error');
    }
  }

  /// Llamar antes de cerrar sesión: después RLS ya no deja borrar la fila.
  static Future<void> unregister() async {
    final value = token;
    _registeredUserId = null;
    if (value == null || !DocxanSupabase.isReady) return;
    try {
      await DocxanSupabase.client
          .from('device_tokens')
          .delete()
          .eq('token', value);
    } catch (error) {
      AppLogger.debug('FCM token no borrado: $error');
    }
  }

  /// Pide a `push-send` que avise a todos los dispositivos del usuario.
  static Future<void> sendToMyDevices({
    required String title,
    required String body,
  }) async {
    if (!DocxanSupabase.isReady) return;
    try {
      await DocxanSupabase.client.functions.invoke(
        'push-send',
        body: {'title': title, 'body': body},
      );
    } catch (error) {
      AppLogger.debug('push-send omitido: $error');
    }
  }

  static Future<void> _showForeground(RemoteMessage message) async {
    final notification = message.notification;
    AppLogger.debug(
      'FCM en primer plano: ${notification?.title ?? message.messageId}',
    );
    if (notification == null) return;
    await _local.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }
}

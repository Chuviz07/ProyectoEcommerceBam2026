import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'notification_config.dart';
import '../navigation/notification_navigation.dart';

import 'platform/web_notification_selector.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedSubscription;
  StreamSubscription<String>? _tokenSubscription;

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('ic_launcher');

    const appleSettings = DarwinInitializationSettings();

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: appleSettings,
      macOS: appleSettings,
    );

    if (!kIsWeb) {
      await _localNotifications.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: _onLocalNotificationPressed,
      );

      const purchaseChannel = AndroidNotificationChannel(
        'purchase_notifications',
        'Notificaciones de compras',
        description: 'Confirmaciones y actualizaciones de compras',
        importance: Importance.max,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(purchaseChannel);
    }

    // Mensajes recibidos mientras la aplicación está abierta.
    _foregroundSubscription =
        FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // El usuario presionó una notificación mientras la aplicación
    // estaba en segundo plano.
    _openedSubscription =
        FirebaseMessaging.onMessageOpenedApp.listen(_onRemoteNotificationPressed);

    // Detecta si una notificación abrió la aplicación desde estado cerrado.
    final initialMessage = await _firebaseMessaging.getInitialMessage();

    if (initialMessage != null) {
      _onRemoteNotificationPressed(initialMessage);
    }

    // Firebase puede cambiar el token del navegador o dispositivo.
    _tokenSubscription =
        _firebaseMessaging.onTokenRefresh.listen((String newToken) {
      debugPrint('Nuevo token FCM: $newToken');
      _saveTokenForCurrentUser(newToken);
    });
  }

  Future<String?> requestPermissionAndGetToken() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    final isAuthorized =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;

    if (!isAuthorized) {
      debugPrint('El usuario no autorizó las notificaciones.');
      return null;
    }

    final token = await _firebaseMessaging.getToken(
      vapidKey: kIsWeb ? NotificationConfig.webVapidKey : null,
    );

    debugPrint('TOKEN FCM: $token');

    if (token != null && token.isNotEmpty) {
      await _saveTokenForCurrentUser(token);
    }

    return token;
  }

  /// Garantiza que el token actual esté guardado antes de crear la compra.
  /// Si el usuario no concede permiso, la compra puede continuar sin FCM.
  Future<bool> prepareForPurchaseNotification() async {
    try {
      final token = await requestPermissionAndGetToken();
      return token != null && token.isNotEmpty;
    } catch (error, stackTrace) {
      debugPrint('No se pudo preparar el token FCM: $error');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    }
  }

  Future<void> _saveTokenForCurrentUser(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('No se guardó el token porque no hay usuario autenticado.');
      return;
    }

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'fcmTokens': FieldValue.arrayUnion([token]),
    });
  }

  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (kIsWeb) {
      await showWebNotification(
        title: title,
        body: body,
        payload: payload,
      );

      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'purchase_notifications',
      'Notificaciones de compras',
      channelDescription: 'Confirmaciones y actualizaciones de compras',
      importance: Importance.max,
      priority: Priority.high,
    );

    const appleDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: appleDetails,
      macOS: appleDetails,
    );

    await _localNotifications.show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: payload,
    );
  }

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    debugPrint(
      'Mensaje FCM recibido en primer plano: ${message.messageId}',
    );

    final notification = message.notification;

    if (notification == null) {
      debugPrint(
        'El mensaje recibido no contiene notification.title ni notification.body',
      );

      return;
    }

    debugPrint('Título: ${notification.title}');
    debugPrint('Contenido: ${notification.body}');

    await showLocalNotification(
      title: notification.title ?? 'Nueva notificación',
      body: notification.body ?? '',
      payload: jsonEncode(message.data),
    );
  }

  void _onRemoteNotificationPressed(RemoteMessage message) {
    debugPrint(
      'Notificación push presionada: ${message.messageId}',
    );

    debugPrint(
      'Datos recibidos: ${message.data}',
    );

    NotificationNavigation.openFromData(message.data);
  }

  void _onLocalNotificationPressed(NotificationResponse response) {
    debugPrint(
      'Notificación local presionada. Payload: ${response.payload}',
    );

    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;

    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map) {
        NotificationNavigation.openFromData(
          Map<String, dynamic>.from(decoded),
        );
      }
    } catch (error) {
      debugPrint('El payload de la notificación no es JSON válido: $error');
    }
  }

  Future<void> dispose() async {
    await _foregroundSubscription?.cancel();
    await _openedSubscription?.cancel();
    await _tokenSubscription?.cancel();
  }
}

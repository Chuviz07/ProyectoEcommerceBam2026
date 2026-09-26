import 'dart:js_interop';
import 'dart:convert';

import 'package:web/web.dart' as web;

import '../../navigation/notification_navigation.dart';

Future<void> showWebNotification({
  required String title,
  required String body,
  String? payload,
}) async {
  if (web.Notification.permission != 'granted') {
    return;
  }

  final options = web.NotificationOptions(
    body: body,
    icon: 'icons/Icon-192.png',
  );

  final notification = web.Notification(
    title,
    options,
  );

  notification.onclick = ((web.Event event) {
    web.window.focus();
    notification.close();

    if (payload == null || payload.isEmpty) return;
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map) {
        NotificationNavigation.openFromData(
          Map<String, dynamic>.from(decoded),
        );
      }
    } catch (_) {
      // Una notificación general puede tener un payload que no sea JSON.
    }
  }).toJS;
}

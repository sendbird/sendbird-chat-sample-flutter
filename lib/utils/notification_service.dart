import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static showNotification(String title, String body, {String? payload}) async {
    FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    var initializationSettingsAndroid =
        AndroidInitializationSettings('ic_notification');
    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: selectNotification,
    );

    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        '0', 'Sendbird Example', 'Sendbird Push Example',
        importance: Importance.max,
        priority: Priority.high,
        color: Colors.green);

    var platformChannelSpecifics =
        new NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }
}

// TODO: incomplete, not found a way to handle event from isolate
Future selectNotification(String? payload) async {
  if (payload == null) return;

  debugPrint('notification payload: $payload');
  final channel = jsonDecode(payload);
  print('channel: ${channel['channel_url']}');
}

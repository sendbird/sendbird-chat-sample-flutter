// Copyright (c) 2023 Sendbird, Inc. All rights reserved.

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
void _notificationTapOnBackground(NotificationResponse notificationResponse) {
  debugPrint('[LocalNotificationsManager][_notificationTapOnBackground()]');
}

class LocalNotificationsManager {
  static int id = 0;

  static Future<bool?> initialize() async {
    debugPrint('[LocalNotificationsManager][initialize()]');

    final initializationSettings = InitializationSettings(
      android: const AndroidInitializationSettings('mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification: (
          int id,
          String? title,
          String? body,
          String? payload,
        ) {
          debugPrint(
              '[LocalNotificationsManager][iOS][onDidReceiveLocalNotification()]');
        },
      ),
    );

    bool? result = await FlutterLocalNotificationsPlugin().initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _notificationTapOnForeground,
      onDidReceiveBackgroundNotificationResponse: _notificationTapOnBackground,
    );
    return result;
  }

  static void _notificationTapOnForeground(
    NotificationResponse notificationResponse,
  ) async {
    debugPrint('[LocalNotificationsManager][_notificationTapOnForeground()]');
  }

  static Future<void> showNotification({
    required String? title,
    required String? body,
    required String? payload,
  }) async {
    debugPrint('[LocalNotificationsManager][showNotification()]');

    const notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          'channelId',
          'channelName',
          channelDescription: 'channelDescription',
          importance: Importance.max,
          priority: Priority.max,
          showWhen: false,
        ),
        iOS: DarwinNotificationDetails(
          badgeNumber: 1,
        ));

    await FlutterLocalNotificationsPlugin().show(
      id++,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }
}

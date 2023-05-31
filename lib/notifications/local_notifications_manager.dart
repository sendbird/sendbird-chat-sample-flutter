// Copyright (c) 2023 Sendbird, Inc. All rights reserved.

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  debugPrint('[notificationTapBackground()]');
}

class LocalNotificationsManager {
  LocalNotificationsManager._();

  static int id = 0;

  static Future<bool?> initialize() async {
    debugPrint('[LocalNotificationsManager.initialize()]');

    final notificationCategories = [
      DarwinNotificationCategory(
        'demoCategory',
        actions: <DarwinNotificationAction>[
          DarwinNotificationAction.plain('id_1', 'Action 1'),
          DarwinNotificationAction.plain(
            'id_2',
            'Action 2',
            options: <DarwinNotificationActionOption>{
              DarwinNotificationActionOption.destructive,
            },
          ),
          DarwinNotificationAction.plain(
            'id_3',
            'Action 3',
            options: <DarwinNotificationActionOption>{
              DarwinNotificationActionOption.foreground,
            },
          ),
        ],
        options: <DarwinNotificationCategoryOption>{
          DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
        },
      )
    ];

    final initializationSettings = InitializationSettings(
      android: const AndroidInitializationSettings('mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: false,
        requestSoundPermission: true,
        onDidReceiveLocalNotification: (
          int id,
          String? title,
          String? body,
          String? payload,
        ) {
          debugPrint('[onDidReceiveLocalNotification()]');
        },
        notificationCategories: notificationCategories,
      ),
    );

    bool? result = await FlutterLocalNotificationsPlugin().initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (final notificationResponse) async {
        debugPrint('[onDidReceiveNotificationResponse]');
        if (notificationResponse.payload != null) {
          debugPrint('notification payload: ${notificationResponse.payload}');
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
    return result;
  }

  static Future<void> showNotification({
    required String? title,
    required String? body,
  }) async {
    debugPrint('[showNotification()]');
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
      payload: 'payload',
    );
  }
}

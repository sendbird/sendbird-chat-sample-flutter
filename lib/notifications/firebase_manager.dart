// Copyright (c) 2023 Sendbird, Inc. All rights reserved.

import 'dart:convert';
import 'dart:io';

// ignore: depend_on_referenced_packages
// import 'package:firebase_core/firebase_core.dart'; // for PushNotifications
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
// import 'package:sendbird_chat_sample/notifications/firebase_options.dart'; // for PushNotifications
import 'package:sendbird_chat_sample/notifications/local_notifications_manager.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[_firebaseMessagingBackgroundHandler()]');
  await _firebaseMessagingProcessRemoteMessage(
    message,
    isBackgroundMessage: true,
  );
}

Future<void> _firebaseMessagingProcessRemoteMessage(
  RemoteMessage message, {
  required bool isBackgroundMessage,
}) async {
  debugPrint('[_firebaseMessagingProcessRemoteMessage()]');
  final sendbird = jsonDecode(message.data['sendbird']);
  if (sendbird != null) {
    await LocalNotificationsManager.showNotification(
        title: null, body: '${message.data['message']}');
  }
}

class FirebaseManager {
  FirebaseManager._();

  static Future<void> initialize() async {
    if (kIsWeb) return;

    /* // for PushNotifications
    await Firebase.initializeApp(
      name: 'SendbirdChat',
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      throw Exception('${settings.authorizationStatus}');
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      if (SendbirdChat.currentUser != null) {
        await _registerPushToken(token);
      }
    }).onError((err) {
      throw Exception(err.toString());
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    */
  }

  static void listenOnForegroundMessage() {
    if (kIsWeb) return;

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _firebaseMessagingProcessRemoteMessage(message,
          isBackgroundMessage: false);
    });
  }

  static Future<bool> registerPushToken() async {
    if (kIsWeb) return false;

    final token = await _getToken();
    if (token != null) {
      PushTokenRegistrationStatus status = await _registerPushToken(token);
      switch (status) {
        case PushTokenRegistrationStatus.success:
          return true;
        case PushTokenRegistrationStatus.pending:
        case PushTokenRegistrationStatus.error:
          return false;
      }
    }
    return false;
  }

  static Future<bool> unregisterPushToken() async {
    if (kIsWeb) return false;

    final pushTokenType = _getPushTokenType();
    if (pushTokenType != null) {
      final token = await _getToken();
      if (token != null) {
        await SendbirdChat.unregisterPushToken(
          type: pushTokenType,
          token: token,
        );
        return true;
      }
    }
    return false;
  }

  static Future<bool> unregisterPushTokenAll() async {
    if (kIsWeb) false;

    await SendbirdChat.unregisterPushTokenAll();
    return true;
  }

  static Future<PushTokenRegistrationStatus> _registerPushToken(
      String token) async {
    final pushTokenType = _getPushTokenType();
    if (pushTokenType != null) {
      return await SendbirdChat.registerPushToken(
        type: pushTokenType,
        token: token,
        unique: true,
      );
    }
    return PushTokenRegistrationStatus.error;
  }

  static Future<String?> _getToken() async {
    String? token;
    if (Platform.isAndroid) {
      token = await FirebaseMessaging.instance.getToken();
    } else if (Platform.isIOS) {
      token = await FirebaseMessaging.instance.getAPNSToken();
    }
    return token;
  }

  static PushTokenType? _getPushTokenType() {
    PushTokenType? pushTokenType;
    if (Platform.isAndroid) {
      pushTokenType = PushTokenType.fcm;
    } else if (Platform.isIOS) {
      pushTokenType = PushTokenType.apns;
    }
    return pushTokenType;
  }
}

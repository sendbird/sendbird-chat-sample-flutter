// Copyright (c) 2023 Sendbird, Inc. All rights reserved.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:push/push.dart';
import 'package:sendbird_chat_sample/notifications/local_notifications_manager.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';

class PushManager {
  static Future<void> initialize() async {
    if (kIsWeb) return;

    debugPrint('[PushManager][initialize()]');

    Push.instance.onNewToken.listen((token) async {
      if (SendbirdChat.currentUser != null) {
        await _registerPushToken(token);
      }
    });

    Push.instance.onMessage.listen((message) async {
      // Foreground
      await _showNotification(message.data, isBackgroundMessage: false);
    });

    Push.instance.onBackgroundMessage.listen((message) async {
      // Background
      await _showNotification(message.data, isBackgroundMessage: true);
    });

    Push.instance.onNotificationTap.listen((data) {
      if (data['payload'] != null) {
        // Foreground
        moveToPageRelatedToPush(data['payload'].toString());
      } else {
        // Background
        moveToPageRelatedToPush(jsonEncode(data['sendbird']));
      }
    });
  }

  static Future<void> _showNotification(
    Map<String?, Object?>? data, {
    required bool isBackgroundMessage,
  }) async {
    if (kIsWeb) return;

    if (data != null) {
      if (Platform.isAndroid) {
        debugPrint(
            '[PushManager][${isBackgroundMessage ? 'Background' : 'Foreground'}]\n'
            '- [message] ${const JsonEncoder.withIndent('  ').convert(data['message'])}\n'
            '- [sendbird] ${const JsonEncoder.withIndent('  ').convert(jsonDecode(data['sendbird'] as String))}');

        final sendbird = jsonDecode(data['sendbird'] as String);
        if (sendbird != null) {
          await LocalNotificationsManager.showNotification(
            title: data['message'] as String,
            body: null,
            payload: data['sendbird'] as String,
          );
        }
      } else if (Platform.isIOS) {
        debugPrint(
            '[PushManager][${isBackgroundMessage ? 'Background' : 'Foreground'}]\n'
            '- [aps] ${const JsonEncoder.withIndent('  ').convert(data['aps'])}\n'
            '- [sendbird] ${const JsonEncoder.withIndent('  ').convert(data['sendbird'])}');

        final sendbird = data['sendbird'] as Map<Object?, Object?>?;
        if (sendbird != null) {
          final aps = data['aps'] as Map<Object?, Object?>?;

          await LocalNotificationsManager.showNotification(
            title: aps?['alert'] as String?,
            body: null,
            payload: jsonEncode(sendbird),
          );
        }
      }
    }
  }

  static Future<bool> requestPermission() async {
    if (kIsWeb) return true;

    final isGranted = await Push.instance.requestPermission();
    return isGranted;
  }

  static void removeBadge() {
    if (kIsWeb) return;

    FlutterAppBadger.removeBadge();
  }

  static Future<bool> checkPushNotification() async {
    if (kIsWeb) return false;

    bool result = false;
    final data =
        await Push.instance.notificationTapWhichLaunchedAppFromTerminated;
    if (data != null) {
      result = true;

      if (data['payload'] != null) {
        // Foreground
        PushManager.moveToPageRelatedToPush(
          data['payload'].toString(),
          offCurrentPage: true,
        );
      } else {
        // Background
        PushManager.moveToPageRelatedToPush(
          jsonEncode(data['sendbird']),
          offCurrentPage: true,
        );
      }
    }
    return result;
  }

  static bool moveToPageRelatedToPush(String? payload, {bool? offCurrentPage}) {
    if (kIsWeb) false;

    debugPrint('[LocalNotificationsManager][moveToPayloadPage()] $payload');
    bool result = false;

    removeBadge();

    if (payload != null) {
      final sendbird = jsonDecode(payload);
      final channelUrl = sendbird?['channel']?['channel_url'];
      if (channelUrl != null) {
        if (SendbirdChat.currentUser != null &&
            SendbirdChat.currentUser!.userId == sendbird['recipient']['id']) {
          if (sendbird['channel_type'] == 'group_messaging') {
            if (offCurrentPage != null && offCurrentPage) {
              Get.offAndToNamed('/group_channel/$channelUrl');
            } else {
              Get.toNamed('/group_channel/$channelUrl');
            }
          } else if (sendbird['channel_type'] == 'notification_feed') {
            if (offCurrentPage != null && offCurrentPage) {
              Get.offAndToNamed('/feed_channel/$channelUrl');
            } else {
              Get.toNamed('/feed_channel/$channelUrl');
            }
          }
          result = true;
        }
      }
    }
    return result;
  }

  static Future<bool> registerPushToken() async {
    if (kIsWeb) return false;

    try {
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
    } catch (_) {
      Fluttertoast.showToast(
        msg: 'Replace \'google-service.json\' in \'android/app\' with your file.',
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_LONG,
      );
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
    if (kIsWeb) return null;

    String? token = await Push.instance.token;
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

import 'package:sendbird_chat/sendbird_chat.dart';
import 'package:universal_io/io.dart';

import 'package:app/main.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

abstract class BaseAuth {
  Future<User> login({
    required String userId,
    String? nickName,
    String? accessToken,
    String? apiHost,
    String? wsHost,
  });
  Future<void> logout();
  User? get currentUser;
  bool get isSigned;
  Future<void> dispose();
  SendbirdChat get sendbirdSdk;
  Future<void> updateCurrentInfo({
    String? nickName,
    FileInfo? file,
    List<String>? preferredLanguage,
  });
}

class AuthenticationController extends GetxController implements BaseAuth {
  // ----> Replace Sendbird Dashboard appId <----
  late SendbirdChat _sendbird;

  Future<void> initialize() async {
    SendbirdChat.init(appId: 'FF6E181B-6325-4A32-AA6D-B1ADA6BAEE95');
  }

  @override
  Future<void> dispose() async {
    logout();
    super.dispose();
  }

  @override
  User? get currentUser => SendbirdChat.currentUser;

  @override
  bool get isSigned => SendbirdChat.currentUser != null;

  @override
  Future<User> login({
    required String userId,
    String? nickName,
    String? accessToken,
    String? apiHost,
    String? wsHost,
  }) async {
    try {
      final user = await SendbirdChat.connect(
        userId,
        nickname: nickName,
        accessToken: accessToken,
        apiHost: apiHost,
        wsHost: wsHost,
      );
      final token = appState.token;

      // [Push Notification Set Up]
      // register push notification token for sendbird notification
      if (token != null) {
        print('registering push token through sendbird server...');
        var result = await SendbirdChat.registerPushToken(
          type: kIsWeb
              ? PushTokenType.none
              : Platform.isIOS
                  ? PushTokenType.apns
                  : PushTokenType.fcm,
          token: token,
        );
        // Result for register Push Token
        // [success, pending, error]
        print(result);
      }

      return user;
    } catch (e) {
      throw Exception([e, 'Connecting with Sendbird Server has failed']);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await SendbirdChat.disconnect();
    } catch (e) {
      throw Exception([e, 'Disconnectin with Sendbird Server has failed']);
    }
  }

  @override
  SendbirdChat get sendbirdSdk => _sendbird;

  @override
  Future<void> updateCurrentInfo({
    String? nickName,
    FileInfo? file,
    List<String>? preferredLanguage,
  }) async {
    try {
      await SendbirdChat.updateCurrentUserInfo(
        nickname: nickName,
        profileFileInfo: file,
        preferredLanguages: preferredLanguage,
      );
    } catch (e) {
      throw Exception([e, 'Failed to update current user info.']);
    }
  }
}

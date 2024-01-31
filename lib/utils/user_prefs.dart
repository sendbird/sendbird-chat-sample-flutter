// Copyright (c) 2023 Sendbird, Inc. All rights reserved.

import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPrefs {
  static const String prefLoginUserId = 'prefLoginUserId';

  static Future<bool> setLoginUserId() async {
    bool result = false;
    final prefs = await SharedPreferences.getInstance();
    final currentUser = SendbirdChat.currentUser;
    if (currentUser != null) {
      result = await prefs.setString(prefLoginUserId, currentUser.userId);
    }
    return result;
  }

  static Future<String?> getLoginUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(prefLoginUserId);
  }

  static Future<bool> removeLoginUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove(prefLoginUserId);
  }

  static Future<bool> setUserPushOn(bool isPushOn) async {
    bool result = false;
    final prefs = await SharedPreferences.getInstance();
    final currentUser = SendbirdChat.currentUser;
    if (currentUser != null) {
      result = await prefs.setBool('${currentUser.userId}_pushOn', isPushOn);
    }
    return result;
  }

  static Future<bool?> getUserPushOn() async {
    bool? result;
    final prefs = await SharedPreferences.getInstance();
    final currentUser = SendbirdChat.currentUser;
    if (currentUser != null) {
      result = prefs.getBool('${currentUser.userId}_pushOn');
    }
    return result;
  }

  static Future<bool> removeUserPushOn() async {
    bool result = false;
    final prefs = await SharedPreferences.getInstance();
    final currentUser = SendbirdChat.currentUser;
    if (currentUser != null) {
      result = await prefs.remove('${currentUser.userId}_pushOn');
    }
    return result;
  }
}

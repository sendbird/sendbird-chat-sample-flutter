// Copyright (c) 2023 Sendbird, Inc. All rights reserved.

import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPrefs {
  static const String prefUseCollectionCaching = 'prefUseCollectionCaching';
  static const String prefCollectionResultSize = 'prefCollectionResultSize';
  static const String prefMessageCollectionReverse =
      'prefMessageCollectionReverse';

  static const bool defaultUseCollectionCaching =
      SendbirdChatOptions.defaultUseCollectionCaching;
  static const int defaultCollectionResultSize = 20;
  static const bool defaultMessageCollectionReverse = false;

  AppPrefs._();

  static final AppPrefs _instance = AppPrefs._();

  factory AppPrefs() {
    return _instance;
  }

  late SharedPreferences prefs;

  Future<void> initialize() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<bool> setUseCollectionCaching(bool value) async {
    return await prefs.setBool(prefUseCollectionCaching, value);
  }

  bool getUseCollectionCaching() {
    return prefs.getBool(prefUseCollectionCaching) ??
        defaultUseCollectionCaching;
  }

  Future<bool> removeUseCollectionCaching() async {
    return await prefs.remove(prefUseCollectionCaching);
  }

  Future<bool> setCollectionResultSize(int value) async {
    return await prefs.setInt(prefCollectionResultSize, value);
  }

  int getCollectionResultSize() {
    return prefs.getInt(prefCollectionResultSize) ??
        defaultCollectionResultSize;
  }

  Future<bool> removeCollectionResultSize() async {
    return await prefs.remove(prefCollectionResultSize);
  }

  Future<bool> setMessageCollectionReverse(bool value) async {
    return await prefs.setBool(prefMessageCollectionReverse, value);
  }

  bool getMessageCollectionReverse() {
    return prefs.getBool(prefMessageCollectionReverse) ??
        defaultMessageCollectionReverse;
  }

  Future<bool> removeMessageCollectionReverse() async {
    return await prefs.remove(prefMessageCollectionReverse);
  }
}

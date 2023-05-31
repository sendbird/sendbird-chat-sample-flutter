// Copyright (c) 2023 Sendbird, Inc. All rights reserved.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';
import 'package:sendbird_chat_sample/component/widgets.dart';
import 'package:sendbird_chat_sample/notifications/firebase_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final String userId = SendbirdChat.currentUser?.userId ?? '';

  String profileUrl = SendbirdChat.currentUser?.profileUrl ?? '';
  String nickname = SendbirdChat.currentUser?.nickname ?? '';
  bool? isPushOn;

  @override
  void initState() {
    super.initState();
    _getPushPrefs().then((result) => setState(() => isPushOn = result));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Widgets.pageTitle('User'),
        actions: const [],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _profileBox(),
            const SizedBox(height: 16.0),
            _userIdBox(),
            const SizedBox(height: 16.0),
            _nicknameBox(),
            if (!kIsWeb) const SizedBox(height: 16.0),
            if (!kIsWeb) _pushNotificationBox(),
          ],
        ),
      ),
    );
  }

  Widget _profileBox() {
    return GestureDetector(
      onTap: () {
        Get.toNamed('/user/update/profile')?.then((_) {
          setState(() {
            profileUrl = SendbirdChat.currentUser?.profileUrl ?? '';
          });
        });
      },
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Widgets.imageNetwork(profileUrl, 48.0, Icons.account_circle),
      ),
    );
  }

  Widget _userIdBox() {
    return Row(
      children: [
        const SizedBox(
          width: 80.0,
          child: Text(
            'User ID:',
            style: TextStyle(fontSize: 12.0),
            textAlign: TextAlign.right,
          ),
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: Text(
            userId,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _nicknameBox() {
    return GestureDetector(
      onTap: () {
        Get.toNamed('/user/update/nickname')?.then((_) {
          setState(() {
            nickname = SendbirdChat.currentUser?.nickname ?? '';
          });
        });
      },
      child: Row(
        children: [
          const SizedBox(
            width: 80.0,
            child: Text(
              'Nickname:',
              style: TextStyle(fontSize: 12.0),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(
              nickname,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pushNotificationBox() {
    return Row(
      children: [
        const SizedBox(
          width: 80.0,
          child: Text(
            'Push\nNotifications:',
            style: TextStyle(fontSize: 12.0),
            textAlign: TextAlign.right,
          ),
        ),
        const SizedBox(width: 12.0),
        ToggleButtons(
          isSelected: [
            isPushOn != null ? !isPushOn! : false,
            isPushOn != null ? isPushOn! : false,
          ],
          onPressed: (index) async {
            switch (index) {
              case 0:
                if (await FirebaseManager.unregisterPushTokenAll()) {
                  if (await _setPushPrefs(false)) {
                    setState(() => isPushOn = false);
                  } else {
                    if (await FirebaseManager.registerPushToken()) {
                      setState(() => isPushOn = true);
                    }
                  }
                }
                break;
              case 1:
                if (await FirebaseManager.registerPushToken()) {
                  if (await _setPushPrefs(true)) {
                    setState(() => isPushOn = true);
                  } else {
                    if (await FirebaseManager.unregisterPushTokenAll()) {
                      setState(() => isPushOn = false);
                    }
                  }
                }
                break;
            }
          },
          children: const [
            Text(
              'OFF',
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'ON',
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<bool> _setPushPrefs(bool isPushOn) async {
    bool result = false;
    final prefs = await SharedPreferences.getInstance();
    final currentUser = SendbirdChat.currentUser;
    if (currentUser != null) {
      result = await prefs.setBool('${currentUser.userId}_isPushOn', isPushOn);
    }
    return result;
  }

  Future<bool?> _getPushPrefs() async {
    bool? result;
    final prefs = await SharedPreferences.getInstance();
    final currentUser = SendbirdChat.currentUser;
    if (currentUser != null) {
      result = prefs.getBool('${currentUser.userId}_isPushOn');
    }
    return result;
  }
}

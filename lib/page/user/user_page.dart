// Copyright (c) 2023 Sendbird, Inc. All rights reserved.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sendbird_chat_sample/component/widgets.dart';
import 'package:sendbird_chat_sample/main.dart';
import 'package:sendbird_chat_sample/notifications/push_manager.dart';
import 'package:sendbird_chat_sample/page/login_page.dart';
import 'package:sendbird_chat_sample/utils/user_prefs.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';
import 'package:sendbird_chat_widget/sendbird_chat_widget.dart';

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
    UserPrefs.getUserPushOn()
        .then((result) => setState(() => isPushOn = result));
  }

  Future<void> _logout() async {
    await PushManager.unregisterPushTokenAll();
    await UserPrefs.removeUserPushOn();
    await UserPrefs.removeLoginUserId();
    await SendbirdChat.disconnect();
    await SendbirdChatWidget.clearCachedNotificationInfo();

    Get.offAll(() => const LoginPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Widgets.pageTitle('User'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              _logout();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
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
              const SizedBox(height: 32.0),
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                child: Container(
                  padding:
                      const EdgeInsets.only(top: 16, right: 16, bottom: 16),
                  color: Colors.black12,
                  child: Column(
                    children: [
                      _appIdBox(),
                      const SizedBox(height: 16.0),
                      _sampleVersionBox(),
                      const SizedBox(height: 16.0),
                      _chatSdkVersionBox(),
                      const SizedBox(height: 16.0),
                      _widgetSdkVersionBox(),
                    ],
                  ),
                ),
              )
            ],
          ),
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
                if (await PushManager.unregisterPushTokenAll()) {
                  if (await UserPrefs.setUserPushOn(false)) {
                    setState(() => isPushOn = false);
                  } else {
                    if (await PushManager.registerPushToken()) {
                      setState(() => isPushOn = true);
                    }
                  }
                }
                break;
              case 1:
                if (await PushManager.registerPushToken()) {
                  if (await UserPrefs.setUserPushOn(true)) {
                    setState(() => isPushOn = true);
                  } else {
                    if (await PushManager.unregisterPushTokenAll()) {
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

  Widget _appIdBox() {
    return Row(
      children: const [
        SizedBox(
          width: 80.0,
          child: Text(
            'App ID:',
            style: TextStyle(fontSize: 12.0),
            textAlign: TextAlign.right,
          ),
        ),
        SizedBox(width: 12.0),
        Expanded(
          child: Text(
            yourAppId,
            style: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _sampleVersionBox() {
    return Row(
      children: const [
        SizedBox(
          width: 80.0,
          child: Text(
            'Sample:',
            style: TextStyle(fontSize: 12.0),
            textAlign: TextAlign.right,
          ),
        ),
        SizedBox(width: 12.0),
        Expanded(
          child: Text(
            'v$sampleVersion',
            style: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _chatSdkVersionBox() {
    return Row(
      children: [
        const SizedBox(
          width: 80.0,
          child: Text(
            'Chat SDK:',
            style: TextStyle(fontSize: 12.0),
            textAlign: TextAlign.right,
          ),
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: Text(
            'v${SendbirdChat.getSdkVersion()}',
            style: const TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _widgetSdkVersionBox() {
    return Row(
      children: const [
        SizedBox(
          width: 80.0,
          child: Text(
            'Widget SDK:',
            style: TextStyle(fontSize: 12.0),
            textAlign: TextAlign.right,
          ),
        ),
        SizedBox(width: 12.0),
        Expanded(
          child: Text(
            'v${SendbirdChatWidget.sdkVersion}',
            style: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

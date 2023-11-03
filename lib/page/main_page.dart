// Copyright (c) 2023 Sendbird, Inc. All rights reserved.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sendbird_chat_sample/component/widgets.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Widgets.pageTitle('Main'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Get.toNamed('/user');
            },
          ),
        ],
      ),
      body: _mainBox(),
    );
  }

  Widget _mainBox() {
    final isNotificationEnabled =
        SendbirdChat.getAppInfo()?.notificationInfo?.isEnabled ?? false;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () {
                Get.toNamed('/group_channel/list');
              },
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text('GroupChannel'),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                Get.toNamed('/open_channel/list');
              },
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text('OpenChannel'),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: isNotificationEnabled
                  ? () async {
                      Get.toNamed('/feed_channel/list');
                    }
                  : null,
              child: isNotificationEnabled
                  ? const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text('FeedChannel'),
                    )
                  : const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text('FeedChannel (Disabled)'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

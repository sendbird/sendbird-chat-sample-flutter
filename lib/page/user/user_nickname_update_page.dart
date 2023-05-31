// Copyright (c) 2023 Sendbird, Inc. All rights reserved.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';
import 'package:sendbird_chat_sample/component/widgets.dart';

class UserNicknameUpdatePage extends StatefulWidget {
  const UserNicknameUpdatePage({Key? key}) : super(key: key);

  @override
  State<UserNicknameUpdatePage> createState() => _UserNicknameUpdatePageState();
}

class _UserNicknameUpdatePageState extends State<UserNicknameUpdatePage> {
  final textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    textEditingController.text = SendbirdChat.currentUser?.nickname ?? '';
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Widgets.pageTitle('Update Nickname'),
        actions: const [],
      ),
      body: Column(
        children: [
          _nicknameUpdateBox(),
        ],
      ),
    );
  }

  Widget _nicknameUpdateBox() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: Widgets.textField(textEditingController, 'Nickname'),
          ),
          const SizedBox(width: 8.0),
          ElevatedButton(
            onPressed: () async {
              await SendbirdChat.updateCurrentUserInfo(
                nickname: textEditingController.text,
              );
              Get.back();
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}

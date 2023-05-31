// Copyright (c) 2023 Sendbird, Inc. All rights reserved.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';
import 'package:sendbird_chat_sample/component/widgets.dart';

class UserProfileUpdatePage extends StatefulWidget {
  const UserProfileUpdatePage({Key? key}) : super(key: key);

  @override
  State<UserProfileUpdatePage> createState() => _UserProfileUpdatePageState();
}

class _UserProfileUpdatePageState extends State<UserProfileUpdatePage> {
  final textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    textEditingController.text = SendbirdChat.currentUser?.profileUrl ?? '';
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
        title: Widgets.pageTitle('Update Profile'),
        actions: const [],
      ),
      body: Column(
        children: [
          _profileUpdateBox(),
        ],
      ),
    );
  }

  Widget _profileUpdateBox() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: Widgets.textField(
              textEditingController,
              'Profile URL',
              maxLines: 3,
            ),
          ),
          const SizedBox(width: 8.0),
          ElevatedButton(
            onPressed: () async {
              await SendbirdChat.updateCurrentUserInfo(
                profileFileInfo: FileInfo(
                  fileUrl: textEditingController.text,
                ),
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

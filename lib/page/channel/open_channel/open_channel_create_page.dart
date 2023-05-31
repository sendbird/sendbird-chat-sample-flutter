// Copyright (c) 2023 Sendbird, Inc. All rights reserved.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';
import 'package:sendbird_chat_sample/component/widgets.dart';

class OpenChannelCreatePage extends StatefulWidget {
  const OpenChannelCreatePage({Key? key}) : super(key: key);

  @override
  State<OpenChannelCreatePage> createState() => _OpenChannelCreatePageState();
}

class _OpenChannelCreatePageState extends State<OpenChannelCreatePage> {
  final textEditingController = TextEditingController();

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Widgets.pageTitle('Create OpenChannel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done),
            onPressed: () async {
              final openChannel = await OpenChannel.createChannel(
                OpenChannelCreateParams()
                  ..name = textEditingController.text
                  ..operatorUserIds = [SendbirdChat.currentUser!.userId],
              );
              Get.back(result: openChannel);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Widgets.textField(textEditingController, 'OpenChannel Name'),
      ),
    );
  }
}

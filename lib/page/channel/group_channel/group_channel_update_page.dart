// Copyright (c) 2023 Sendbird, Inc. All rights reserved.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';
import 'package:sendbird_chat_sample/component/widgets.dart';

class GroupChannelUpdatePage extends StatefulWidget {
  const GroupChannelUpdatePage({Key? key}) : super(key: key);

  @override
  State<GroupChannelUpdatePage> createState() => _GroupChannelUpdatePageState();
}

class _GroupChannelUpdatePageState extends State<GroupChannelUpdatePage> {
  final channelUrl = Get.parameters['channel_url']!;
  final textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    GroupChannel.getChannel(channelUrl)
        .then((channel) => textEditingController.text = channel.name);
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
        title: Widgets.pageTitle('Update GroupChannel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done),
            onPressed: () async {
              final groupChannel = await GroupChannel.getChannel(channelUrl);
              await groupChannel.updateChannel(GroupChannelUpdateParams()
                ..name = textEditingController.text);
              Get.back(result: groupChannel);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Widgets.textField(textEditingController, 'GroupChannel Name'),
      ),
    );
  }
}

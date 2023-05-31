// Copyright (c) 2023 Sendbird, Inc. All rights reserved.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';
import 'package:sendbird_chat_sample/component/widgets.dart';

class OpenChannelUpdatePage extends StatefulWidget {
  const OpenChannelUpdatePage({Key? key}) : super(key: key);

  @override
  State<OpenChannelUpdatePage> createState() => _OpenChannelUpdatePageState();
}

class _OpenChannelUpdatePageState extends State<OpenChannelUpdatePage> {
  final channelUrl = Get.parameters['channel_url']!;
  final textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    OpenChannel.getChannel(channelUrl)
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
        title: Widgets.pageTitle('Update OpenChannel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done),
            onPressed: () async {
              final openChannel = await OpenChannel.getChannel(channelUrl);
              await openChannel.updateChannel(
                  OpenChannelUpdateParams()..name = textEditingController.text);
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

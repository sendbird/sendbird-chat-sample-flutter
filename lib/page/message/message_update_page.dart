// Copyright (c) 2023 Sendbird, Inc. All rights reserved.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';
import 'package:sendbird_chat_sample/component/widgets.dart';

class MessageUpdatePage extends StatefulWidget {
  const MessageUpdatePage({Key? key}) : super(key: key);

  @override
  State<MessageUpdatePage> createState() => _MessageUpdatePageState();
}

class _MessageUpdatePageState extends State<MessageUpdatePage> {
  final channelType = Get.parameters['channel_type']!;
  final channelUrl = Get.parameters['channel_url']!;
  final messageId = int.parse(Get.parameters['message_id']!);
  final textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();

    BaseChannel.getBaseChannel(
      ChannelType.group.toString() == channelType
          ? ChannelType.group
          : ChannelType.open,
      channelUrl,
    ).then((channel) {
      final params = MessageListParams()
        ..inclusive = true
        ..previousResultSize = 0
        ..nextResultSize = 0;
      channel.getMessagesByMessageId(messageId, params).then((messages) {
        if (messages.isNotEmpty) {
          textEditingController.text = messages[0].message;
        }
      });
    });
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
        title: Widgets.pageTitle('Update Message'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done),
            onPressed: () async {
              final channel = await BaseChannel.getBaseChannel(
                ChannelType.group.toString() == channelType
                    ? ChannelType.group
                    : ChannelType.open,
                channelUrl,
              );
              final message = await channel.updateUserMessage(
                messageId,
                UserMessageUpdateParams()..message = textEditingController.text,
              );
              Get.back(result: message);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          channelNameTextField(),
        ],
      ),
    );
  }

  Widget channelNameTextField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: Widgets.textField(textEditingController, 'Message'),
          ),
        ],
      ),
    );
  }
}

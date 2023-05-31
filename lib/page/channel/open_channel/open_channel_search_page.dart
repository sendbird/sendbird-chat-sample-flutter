// Copyright (c) 2023 Sendbird, Inc. All rights reserved.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';
import 'package:sendbird_chat_sample/component/widgets.dart';

class OpenChannelSearchPage extends StatefulWidget {
  const OpenChannelSearchPage({Key? key}) : super(key: key);

  @override
  State<OpenChannelSearchPage> createState() => _OpenChannelSearchPageState();
}

class _OpenChannelSearchPageState extends State<OpenChannelSearchPage> {
  final textEditingController = TextEditingController();

  String title = 'Search OpenChannel';
  List<OpenChannel> openChannelList = [];

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Widgets.pageTitle(title),
        actions: const [],
      ),
      body: Column(
        children: [
          _openChannelSearchBox(),
          Expanded(child: openChannelList.isNotEmpty ? _list() : Container()),
        ],
      ),
    );
  }

  Widget _openChannelSearchBox() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: Widgets.textField(textEditingController, 'OpenChannel Name'),
          ),
          const SizedBox(width: 8.0),
          ElevatedButton(
            onPressed: () async {
              final query = OpenChannelListQuery()
                ..nameKeyword = textEditingController.value.text;
              final openChannels = await query.next();

              setState(() {
                openChannelList = openChannels;
              });
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  Widget _list() {
    return ListView.builder(
      itemCount: openChannelList.length,
      itemBuilder: (BuildContext context, int index) {
        final openChannel = openChannelList[index];

        return GestureDetector(
          child: Column(
            children: [
              ListTile(
                title: Text(openChannel.name),
                subtitle: Text(
                  openChannel.channelUrl,
                  style: const TextStyle(fontSize: 12.0),
                ),
                onTap: () {
                  Get.toNamed('/open_channel/${openChannel.channelUrl}');
                },
              ),
              const Divider(height: 1),
            ],
          ),
        );
      },
    );
  }
}

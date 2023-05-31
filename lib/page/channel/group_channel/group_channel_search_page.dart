// Copyright (c) 2023 Sendbird, Inc. All rights reserved.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';
import 'package:sendbird_chat_sample/component/widgets.dart';

class GroupChannelSearchPage extends StatefulWidget {
  const GroupChannelSearchPage({Key? key}) : super(key: key);

  @override
  State<GroupChannelSearchPage> createState() => _GroupChannelSearchPageState();
}

class _GroupChannelSearchPageState extends State<GroupChannelSearchPage> {
  final textEditingController = TextEditingController();

  String title = 'Search GroupChannel';
  List<GroupChannel> groupChannelList = [];
  String errorText = '';

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
          _groupChannelSearchBox(),
          Expanded(child: groupChannelList.isNotEmpty ? _list() : Container()),
        ],
      ),
    );
  }

  Widget _groupChannelSearchBox() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child:
                Widgets.textField(textEditingController, 'GroupChannel Name'),
          ),
          const SizedBox(width: 8.0),
          ElevatedButton(
            onPressed: () async {
              final query = GroupChannelListQuery()
                ..channelNameContainsFilter = textEditingController.value.text;
              final groupChannels = await query.next();

              setState(() {
                groupChannelList = groupChannels;
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
      itemCount: groupChannelList.length,
      itemBuilder: (BuildContext context, int index) {
        final groupChannel = groupChannelList[index];

        return GestureDetector(
          child: Column(
            children: [
              ListTile(
                title: Text(groupChannel.name),
                subtitle: Text(
                  groupChannel.channelUrl,
                  style: const TextStyle(fontSize: 12.0),
                ),
                onTap: () {
                  Get.toNamed('/group_channel/${groupChannel.channelUrl}');
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

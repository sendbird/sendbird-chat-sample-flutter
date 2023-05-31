// Copyright (c) 2023 Sendbird, Inc. All rights reserved.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';
import 'package:sendbird_chat_sample/component/widgets.dart';

class GroupChannelListPage extends StatefulWidget {
  const GroupChannelListPage({Key? key}) : super(key: key);

  @override
  State<GroupChannelListPage> createState() => GroupChannelListPageState();
}

class GroupChannelListPageState extends State<GroupChannelListPage> {
  late GroupChannelCollection collection;

  String title = 'GroupChannels';
  bool hasMore = false;
  List<GroupChannel> channelList = [];

  @override
  void initState() {
    super.initState();
    collection = GroupChannelCollection(
      query: GroupChannelListQuery()
        ..order = GroupChannelListQueryOrder.latestLastMessage,
      handler: MyGroupChannelCollectionHandler(this),
    )..loadMore();
  }

  @override
  void dispose() {
    collection.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Widgets.pageTitle(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Get.toNamed('/group_channel/search'),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Get.toNamed('/group_channel/create')?.then((_) => _refresh());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
              child: collection.channelList.isNotEmpty ? _list() : Container()),
          hasMore ? _moreButton() : Container(),
        ],
      ),
    );
  }

  Widget _list() {
    return ListView.builder(
      itemCount: channelList.length,
      itemBuilder: (BuildContext context, int index) {
        final groupChannel = channelList[index];
        final userIds = groupChannel.members.map((e) => e.userId).toList();
        userIds.sort((a, b) => a.compareTo(b));
        final senderId = groupChannel.lastMessage?.sender?.userId ?? '';
        final profileUrl = groupChannel.lastMessage?.sender?.profileUrl ?? '';

        String? lastMessage;
        if (groupChannel.lastMessage != null) {
          if (groupChannel.lastMessage is FileMessage) {
            lastMessage = (groupChannel.lastMessage! as FileMessage).name ?? '';
          } else {
            lastMessage = groupChannel.lastMessage!.message;
          }
        }

        return GestureDetector(
          onDoubleTap: () {
            Get.toNamed('/group_channel/update/${groupChannel.channelUrl}')
                ?.then((groupChannel) {
              if (groupChannel != null) {
                for (int index = 0; index < channelList.length; index++) {
                  if (channelList[index].channelUrl ==
                      groupChannel.channelUrl) {
                    setState(() => channelList[index] = groupChannel);
                    break;
                  }
                }
              }
            });
          },
          onLongPress: () async {
            await groupChannel.deleteChannel();
          },
          child: Column(
            children: [
              ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        groupChannel.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Text(
                          userIds.toString(),
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 12.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: (lastMessage != null)
                          ? Row(
                              children: [
                                Widgets.imageNetwork(
                                    profileUrl, 16.0, Icons.account_circle),
                                Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 4.0),
                                    child: Text(
                                      '$senderId: $lastMessage',
                                      style: const TextStyle(fontSize: 12.0),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Container(),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 16),
                      alignment: Alignment.centerRight,
                      child: Text(
                        DateTime.fromMillisecondsSinceEpoch(
                          groupChannel.createdAt! * 1000,
                        ).toString(),
                        style: const TextStyle(fontSize: 12.0),
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  Get.toNamed('/group_channel/${groupChannel.channelUrl}')
                      ?.then((_) => _refresh());
                },
              ),
              const Divider(height: 1),
            ],
          ),
        );
      },
    );
  }

  Widget _moreButton() {
    return Container(
      width: double.maxFinite,
      height: 32.0,
      color: Colors.purple[200],
      child: IconButton(
        icon: const Icon(Icons.expand_more, size: 16.0),
        color: Colors.white,
        onPressed: () {
          if (collection.hasMore && !collection.isLoading) {
            collection.loadMore();
          }
        },
      ),
    );
  }

  void _refresh() {
    setState(() {
      channelList = collection.channelList;
      title = channelList.isEmpty
          ? 'GroupChannels'
          : 'GroupChannels (${channelList.length})';
      hasMore = collection.hasMore;
    });
  }
}

class MyGroupChannelCollectionHandler extends GroupChannelCollectionHandler {
  final GroupChannelListPageState state;

  MyGroupChannelCollectionHandler(this.state);

  @override
  void onChannelsAdded(GroupChannelContext context, List<GroupChannel> channels) {
    state._refresh();
  }

  @override
  void onChannelsUpdated(GroupChannelContext context, List<GroupChannel> channels) {
    state._refresh();
  }

  @override
  void onChannelsDeleted(
      GroupChannelContext context, List<String> deletedChannelUrls) {
    state._refresh();
  }
}

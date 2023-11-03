// Copyright (c) 2023 Sendbird, Inc. All rights reserved.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sendbird_chat_sample/component/widgets.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';

class FeedChannelListPage extends StatefulWidget {
  const FeedChannelListPage({Key? key}) : super(key: key);

  @override
  State<FeedChannelListPage> createState() => FeedChannelListPageState();
}

class FeedChannelListPageState extends State<FeedChannelListPage> {
  late FeedChannelListQuery query;

  String title = 'FeedChannels';
  bool hasNext = false;
  List<FeedChannel> channelList = [];

  @override
  void initState() {
    super.initState();
    SendbirdChat.addConnectionHandler(
        'FeedChannelList', MyConnectionHandler(this));
    SendbirdChat.addUserEventHandler(
        'FeedChannelList', MyUserEventHandler(this));

    _initialize();
  }

  void _initialize() {
    query = FeedChannelListQuery()
      ..next().then((value) {
        setState(() {
          channelList.clear();
          channelList.addAll(value);
          title = _getTitle();
          hasNext = query.hasNext;
        });
      });
  }

  @override
  void dispose() {
    SendbirdChat.removeConnectionHandler('FeedChannelList');
    SendbirdChat.removeUserEventHandler('FeedChannelList');
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
          Expanded(child: channelList.isNotEmpty ? _list() : Container()),
          hasNext ? _nextButton() : Container(),
        ],
      ),
    );
  }

  Widget _list() {
    return ListView.builder(
      itemCount: channelList.length,
      itemBuilder: (BuildContext context, int index) {
        final feedChannel = channelList[index];

        return GestureDetector(
          onDoubleTap: () async {},
          onLongPress: () async {},
          child: Column(
            children: [
              ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        feedChannel.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Text(
                          '${feedChannel.unreadMessageCount}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 12.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Container(
                  margin: const EdgeInsets.only(left: 16),
                  alignment: Alignment.centerRight,
                  child: Text(
                    DateTime.fromMillisecondsSinceEpoch(
                      feedChannel.createdAt! * 1000,
                    ).toString(),
                    style: const TextStyle(fontSize: 12.0),
                  ),
                ),
                onTap: () async {
                  Get.toNamed('/feed_channel/${feedChannel.channelUrl}')
                      ?.then((value) => _initialize());
                },
              ),
              const Divider(height: 1),
            ],
          ),
        );
      },
    );
  }

  Widget _nextButton() {
    return Container(
      width: double.maxFinite,
      height: 32.0,
      color: Colors.purple[200],
      child: IconButton(
        icon: const Icon(Icons.expand_more, size: 16.0),
        color: Colors.white,
        onPressed: () async {
          if (query.hasNext && !query.isLoading) {
            final channels = await query.next();
            setState(() {
              channelList.addAll(channels);
              title = _getTitle();
              hasNext = query.hasNext;
            });
          }
        },
      ),
    );
  }

  String _getTitle() {
    return channelList.isEmpty
        ? 'FeedChannels'
        : 'FeedChannels (${channelList.length})';
  }

  void _updateFeedChannelChangeLogs() async {
    final changeLogs = await SendbirdChat.getMyFeedChannelChangeLogs(
        FeedChannelChangeLogsParams());

    if (changeLogs.updatedChannels.isNotEmpty) {
      for (final updatedChannel in changeLogs.updatedChannels) {
        bool isFoundUpdatedChannel = false;

        for (int index = 0; index < channelList.length; index++) {
          final channel = channelList[index];

          if (updatedChannel.channelUrl == channel.channelUrl) {
            channelList.insert(index, updatedChannel);
            isFoundUpdatedChannel = true;
            break;
          }
        }

        if (!isFoundUpdatedChannel) {
          channelList.add(updatedChannel);
        }
      }
    }

    if (changeLogs.deletedChannelUrls.isNotEmpty) {
      for (final channelUrl in changeLogs.deletedChannelUrls) {
        channelList.removeWhere((e) => e.channelUrl == channelUrl);
      }
    }
  }
}

class MyConnectionHandler extends ConnectionHandler {
  final FeedChannelListPageState _state;

  MyConnectionHandler(this._state);

  @override
  void onConnected(String userId) {}

  @override
  void onDisconnected(String userId) {}

  @override
  void onReconnectStarted() {}

  @override
  void onReconnectSucceeded() {
    _state._updateFeedChannelChangeLogs();
  }

  @override
  void onReconnectFailed() {}
}

class MyUserEventHandler extends UserEventHandler {
  final FeedChannelListPageState _state;

  MyUserEventHandler(this._state);

  @override
  void onFriendsDiscovered(List<User> friends) {}

  @override
  void onTotalUnreadMessageCountChanged(UnreadMessageCount unreadMessageCount) {
    debugPrint(
        '[Notifications][onTotalUnreadMessageCountChanged] ${unreadMessageCount.totalCountForFeedChannels}');
    _state._initialize();
  }
}

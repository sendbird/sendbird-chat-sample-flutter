import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sendbird_flutter/main.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';

class ChannelListViewModel with ChangeNotifier, ChannelEventHandler {
  GroupChannelListQuery query = GroupChannelListQuery()..limit = 10;
  User? currentUser = sendbird.currentUser;
  List<GroupChannel> groupChannels = [];

  bool isLoading = false;
  String? destChannelUrl;
  bool isVisible = true;
  final ScrollController lstController = ScrollController();

  int get itemCount =>
      query.hasNext ? groupChannels.length + 1 : groupChannels.length;

  bool get hasNext => query.hasNext;

  ChannelListViewModel({this.destChannelUrl}) {
    sendbird.addChannelEventHandler('channel_list_view', this);
    lstController.addListener(_scrollListener);
    _registerTokenIfNeeded();
  }

  @override
  void dispose() {
    super.dispose();
    sendbird.removeChannelEventHandler('channel_list_view');
  }

  Future<void> loadChannelList({bool reload = false}) async {
    isLoading = true;
    print('loading channels...');
    if (destChannelUrl != null) {
      navigatorKey.currentState
          ?.pushNamed('/channel', arguments: destChannelUrl);
      destChannelUrl = null;
    }

    try {
      if (reload)
        query = GroupChannelListQuery()
          ..limit = 10
          ..order = GroupChannelListOrder.latestLastMessage;
      final res = await query.loadNext();
      isLoading = false;
      if (reload)
        groupChannels = res;
      else {
        groupChannels = [...groupChannels] + res;
      }
      //go to channel if exist
      notifyListeners();
    } catch (e) {
      isLoading = false;
      print('channel_list_view: getGroupChannel: ERROR: $e');
    }
  }

  void logout() async {
    appState.didRegisterToken = false;
    final token = appState.token;
    if (token != null)
      await sendbird.unregisterPushToken(type: PushTokenType.fcm, token: token);
    sendbird.disconnect();
  }

  _registerTokenIfNeeded() async {
    final token = appState.token;
    if (token != null)
      await sendbird.registerPushToken(
        type: Platform.isIOS ? PushTokenType.apns : PushTokenType.fcm,
        token: token,
      );
  }

  _scrollListener() {
    if (lstController.offset >= lstController.position.maxScrollExtent &&
        !lstController.position.outOfRange &&
        !isLoading &&
        query.hasNext) {
      loadChannelList();
    }
  }

  @override
  void onChannelChanged(BaseChannel channel) {
    if (channel is! GroupChannel) return;

    groupChannels = [...groupChannels];

    final index = groupChannels
        .indexWhere((element) => element.channelUrl == channel.channelUrl);

    if (index != -1) {
      groupChannels[index] = channel;
    } else {
      groupChannels.insert(0, channel);
    }

    notifyListeners();
  }

  @override
  void onReadReceiptUpdated(GroupChannel channel) {
    groupChannels = [...groupChannels];
    notifyListeners();
  }

  @override
  void onMessageReceived(BaseChannel channel, BaseMessage message) {
    if (channel is! GroupChannel) return;

    groupChannels = [...groupChannels];
    final index = groupChannels
        .indexWhere((element) => element.channelUrl == channel.channelUrl);

    if (index != -1) {
      groupChannels[index] = channel;
    } else {
      groupChannels.insert(0, channel);
    }

    notifyListeners();
  }

  @override
  void onUserLeaved(GroupChannel channel, User user) {
    groupChannels = [...groupChannels];

    if (user.userId == currentUser?.userId) {
      final index = groupChannels
          .indexWhere((element) => element.channelUrl == channel.channelUrl);
      if (index != -1) {
        groupChannels.removeAt(index);
      }

      notifyListeners();
    }
  }
}

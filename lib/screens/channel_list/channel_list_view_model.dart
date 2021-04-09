import 'package:flutter/material.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';

class ChannelListViewModel with ChangeNotifier, ChannelEventHandler {
  SendbirdSdk sdk = SendbirdSdk();

  GroupChannelListQuery query = GroupChannelListQuery()..limit = 10;
  User currentUser = SendbirdSdk().getCurrentUser();
  List<GroupChannel> groupChannels = [];

  bool isLoading = false;

  final ScrollController lstController = ScrollController();

  int get itemCount =>
      query.hasNext ? groupChannels.length + 1 : groupChannels.length;

  bool get hasNext => query.hasNext;

  ChannelListViewModel() {
    sdk.addChannelHandler('channel_list_view', this);
    lstController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> loadChannelList({bool reload = false}) async {
    isLoading = true;

    try {
      if (reload) query = GroupChannelListQuery()..limit = 10;
      final res = await query.loadNext();
      isLoading = false;
      if (reload)
        groupChannels = res;
      else
        groupChannels.addAll(res);
      notifyListeners();
    } catch (e) {
      isLoading = false;
      print('channel_list_view: getGroupChannel: ERROR: $e');
    }
  }

  _scrollListener() {
    if (lstController.offset >= lstController.position.maxScrollExtent &&
        !lstController.position.outOfRange &&
        !isLoading) {
      loadChannelList();
    }
  }

  @override
  void onChannelChanged(BaseChannel channel) {
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

    if (user.userId == currentUser.userId) {
      final index = groupChannels
          .indexWhere((element) => element.channelUrl == channel.channelUrl);
      if (index != -1) {
        groupChannels.removeAt(index);
      }

      notifyListeners();
    }
  }
}

import 'package:flutter/material.dart';
import 'package:sendbirdsdk/sendbirdsdk.dart';

class ChannelListViewModel with ChannelEventHandler, ChangeNotifier {
  SendbirdSdk sdk = SendbirdSdk();

  GroupChannelListQuery query = GroupChannelListQuery()..limit = 15;
  User currentUser = SendbirdSdk().getCurrentUser();
  List<GroupChannel> groupChannels = [];
  bool isLoading = false;

  @override
  void onMessageReceived(BaseChannel channel, BaseMessage message) {
    final index = groupChannels
        .indexWhere((element) => element.channelUrl == channel.channelUrl);

    if (index != -1) {
      groupChannels[index] = channel;
    } else {
      groupChannels.insert(0, channel);
    }

    notifyListeners();
  }

  Future<void> loadChannelList({bool reload = false}) async {
    try {
      if (reload) query = GroupChannelListQuery()..limit = 15;
      final res = await query.loadNext();
      isLoading = false;
      if (reload)
        groupChannels = res;
      else
        groupChannels.addAll(res);
      notifyListeners();
    } catch (e) {
      print('channel_list_view: getGroupChannel: ERROR: $e');
    }
  }
}

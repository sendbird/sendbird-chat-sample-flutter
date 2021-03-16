import 'package:flutter/material.dart';
import 'package:sendbirdsdk/sendbirdsdk.dart';

class ChannelInfoViewModel extends ChangeNotifier {
  final sdk = SendbirdSdk();

  GroupChannel channel;

  ChannelInfoViewModel(this.channel);

  bool get isNotificationOn =>
      channel.myPushTriggerOption != GroupChannelPushTriggerOption.off;

  void loadChannel() async {
    try {
      final updated = await GroupChannel.refreshChannel(channel.channelUrl);
      channel = updated;
    } catch (e) {
      //pop?
    }

    notifyListeners();
  }

  Future<void> setNotification(bool value) async {
    try {
      final option = value
          ? GroupChannelPushTriggerOption.all
          : GroupChannelPushTriggerOption.off;
      await channel.setMyPushTriggerOption(option);
      notifyListeners();
    } catch (e) {
      //e
    }
  }

  Future<bool> leave() async {
    try {
      await channel.leave();
      return true;
    } catch (e) {
      return false;
    }
  }
}

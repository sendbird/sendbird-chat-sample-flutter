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
    notifyListeners();
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

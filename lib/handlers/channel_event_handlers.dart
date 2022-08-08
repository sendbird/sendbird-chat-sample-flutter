import 'package:app/controllers/authentication_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';

class ChannelEventHandlers with ChannelEventHandler {
  final BaseAuth _authentication = Get.find<AuthenticationController>();
  late VoidCallback? callback;
  List<BaseMessage> messages = RxList.empty(growable: true);
  String channelUrl;
  late BaseChannel channel;
  late PreviousMessageListQuery _messageListQuery;
  ChannelType channelType;

  ChannelEventHandlers({
    VoidCallback? refresh,
    required this.channelUrl,
    required this.channelType,
  }) {
    _messageListQuery = PreviousMessageListQuery(
        channelType: channelType, channelUrl: channelUrl)
      ..limit = 5;
    callback = refresh;
    _authentication.sendbirdSdk
        .addChannelEventHandler('ChannelEventHandler', this);
    getChannel(channelUrl, channelType: channelType);
  }

  Future<BaseChannel> getChannel(String channelUrl,
      {required ChannelType channelType}) async {
    switch (channelType) {
      case ChannelType.group:
        channel = await GroupChannel.getChannel(channelUrl);
        //TODO
        // (channel as GroupChannel).markAsRead();
        break;
      case ChannelType.open:
        channel = await OpenChannel.getChannel(channelUrl);
        break;
    }
    return channel;
  }

  void dispose() {
    _authentication.sendbirdSdk
        .removeChannelEventHandler('ChannelEventHandler');
  }

  @override
  void onReadReceiptUpdated(GroupChannel channel) {
    print('on Read');
    if (callback != null) {
      callback!();
    }
  }

  @override
  void onMessageReceived(BaseChannel channel, BaseMessage message) {
    print('on Recieve');
    if (callback != null) {
      callback!();
    }
  }

  @override
  void onMessageUpdated(BaseChannel channel, BaseMessage message) {
    for (int i = 0; i < messages.length; i++) {
      if (messages[i].messageId == message.messageId) {
        messages[i] = message;
      }
    }

    if (callback != null) {
      callback!();
    }
  }

  @override
  void onMessageDeleted(BaseChannel channel, int messageId) {
    for (int i = 0; i < messages.length; i++) {
      if (messages[i].messageId == messageId) {
        messages.removeAt(i);
      }
    }

    if (callback != null) {
      callback!();
    }
  }

  Future<List<BaseMessage>> loadMessages({bool isForce = false}) async {
    if (isForce) {
      messages = RxList.empty(growable: true);
      _messageListQuery = PreviousMessageListQuery(
        channelType: channelType,
        channelUrl: channelUrl,
      )..limit = 5;
    }

    List<BaseMessage> messageList = await _messageListQuery.loadNext();

    //TODO refactor
    if (isForce) {
      for (var message in messageList) {
        messages.add(message);
      }
    } else {
      for (int i = messageList.length - 1; i >= 0; i--) {
        messages.insert(0, messageList[i]);
      }
    }

    if (callback != null) {
      callback!();
    }

    return messages;
  }
}

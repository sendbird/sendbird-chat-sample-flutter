import 'package:sendbird_chat/sendbird_chat.dart';

Future<BaseChannel> createChannel(
    {required ChannelType channelType, required dynamic channelParams}) async {
  try {
    switch (channelType) {
      case ChannelType.group:
        final params = channelParams as GroupChannelCreateParams;
        return await GroupChannel.createChannel(params);
      case ChannelType.open:
        final params = channelParams as OpenChannelCreateParams;
        return await OpenChannel.createChannel(params);
    }
  } catch (e) {
    rethrow;
  }
}

Future<void> editChannel({required channel, required params}) async {
  try {
    switch (channel.channelType) {
      case ChannelType.group:
        await (channel as GroupChannel).updateChannel(params);
        break;
      case ChannelType.open:
        await (channel as OpenChannel).updateChannel(params);
        break;
    }
  } catch (e) {
    rethrow;
  }
}

Future<void> deleteChannel({required BaseChannel channel}) async {
  try {
    switch (channel.channelType) {
      case ChannelType.group:
        await (channel as GroupChannel).deleteChannel();
        break;
      case ChannelType.open:
        await (channel as OpenChannel).deleteChannel();
        break;
    }
  } catch (e) {
    rethrow;
  }
}

Future<void> leaveChannel({required BaseChannel channel}) async {
  try {
    switch (channel.channelType) {
      case ChannelType.group:
        await (channel as GroupChannel).leave();
        break;
      case ChannelType.open:
        await (channel as OpenChannel).exit();
        break;
    }
  } catch (e) {
    rethrow;
  }
}

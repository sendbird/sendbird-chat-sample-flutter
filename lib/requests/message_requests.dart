import 'dart:async';
import 'package:sendbird_sdk/sendbird_sdk.dart';

Future<void> loadMessages({
  required channel,
  required int messageId,
}) async {
  try {
    switch (channel.channelType) {
      case ChannelType.group:
        await (channel as GroupChannel).deleteMessage(messageId);
        break;
      case ChannelType.open:
        await (channel as OpenChannel).deleteMessage(messageId);
        break;
    }
  } catch (e) {
    rethrow;
  }
}

Future<void> deleteMessage({
  required channel,
  required int messageId,
}) async {
  try {
    switch (channel.channelType) {
      case ChannelType.group:
        await (channel as GroupChannel).deleteMessage(messageId);
        break;
      case ChannelType.open:
        await (channel as OpenChannel).deleteMessage(messageId);
        break;
    }
  } catch (e) {
    rethrow;
  }
}

Future<void> editUserMessage({
  required channel,
  required int messageId,
  required UserMessageParams params,
}) async {
  try {
    switch (channel.channelType) {
      case ChannelType.group:
        await (channel as GroupChannel).updateUserMessage(messageId, params);
        break;
      case ChannelType.open:
        await (channel as OpenChannel).updateUserMessage(messageId, params);
        break;
    }
  } catch (e) {
    rethrow;
  }
}

Future<FileMessage> sendFileMessage({
  required channel,
  required params,
}) async {
  try {
    final Completer<FileMessage> completer = Completer<FileMessage>();
    switch (channel.channelType) {
      case ChannelType.group:
        (channel as GroupChannel).sendFileMessage(
          params,
          onCompleted: ((message, error) {
            if (error != null) {
              completer.completeError(error);
              throw Exception('Failed sending file message');
            }
            completer.complete(message);
          }),
        );
        break;
      case ChannelType.open:
        (channel as OpenChannel).sendFileMessage(
          params,
          onCompleted: ((message, error) {
            if (error != null) {
              completer.completeError(error);
              throw Exception('Failed sending file message');
            }
            completer.complete(message);
          }),
        );
        break;
    }
    return completer.future;
  } catch (e) {
    rethrow;
  }
}

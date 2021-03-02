import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sendbirdsdk/sendbirdsdk.dart';

class ChannelViewModel with ChangeNotifier {
  List<BaseMessage> messages = [];
  GroupChannel channel;
  File uploadFile;

  SendbirdSdk sdk = SendbirdSdk();

  User currentUser = SendbirdSdk().getCurrentUser();
  StreamSubscription messageSubs;
  bool isLoading = false;

  final ScrollController lstController = ScrollController();
  final TextEditingController inputController = new TextEditingController();
  final picker = ImagePicker();

  ChannelViewModel({this.channel}) {
    messageSubs = sdk
        .messageReceiveStream(channelUrl: channel.channelUrl)
        .listen((message) {
      messages.insert(0, message);
      notifyListeners();
    });

    lstController.addListener(_scrollListener);
  }

  @override
  void dispose() async {
    super.dispose();
    messageSubs.cancel();
  }

  Future<void> loadMessages({
    int timestamp,
    bool reload = false,
  }) async {
    if (isLoading) {
      return;
    }

    isLoading = true;

    final ts = reload ? DateTime.now().millisecondsSinceEpoch : timestamp;
    try {
      final params = MessageListParams()
        ..isInclusive = false
        ..includeThreadInfo = true
        ..reverse = true
        ..previousResultSize = 20;
      final messages = await channel.getMessagesByTimestamp(ts, params);
      this.messages = reload ? messages : this.messages + messages;
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      print('group_channel_view.dart: getMessages: ERROR: $e');
    }
  }

  void onSendUserMessage() async {
    final message = inputController.text;
    if (message == '') {
      return;
    }

    final preMessage = await channel.sendUserMessageWithText(message,
        onCompleted: (msg, error) {
      // messages.repl(0, msg);
      final index =
          messages.indexWhere((element) => element.requestId == msg.requestId);
      if (index != -1) {
        messages[index] = msg;
        notifyListeners();
      }
    });

    messages.insert(0, preMessage);
    inputController.clear();
    lstController.animateTo(
      0.0,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void onSendFileMessage(File file) async {
    if (file == null) return;

    final params = FileMessageParams.withFile(file);
    final preMessage =
        await channel.sendFileMessage(params, onCompleted: (msg, error) {
      final index =
          messages.indexWhere((element) => element.requestId == msg.requestId);
      if (index != -1) {
        messages[index] = msg;
        notifyListeners();
      }
    });

    messages.insert(0, preMessage);
    inputController.clear();
    lstController.animateTo(
      0.0,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future showPicker() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      onSendFileMessage(File(pickedFile.path));
    }
  }

  _scrollListener() {
    if (lstController.offset >= lstController.position.maxScrollExtent &&
        !lstController.position.outOfRange &&
        !isLoading) {
      final offset = lstController.offset;

      loadMessages(
        timestamp: messages.last.createdAt,
      );

      lstController.animateTo(
        offset,
        duration: Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
    if (lstController.offset <= lstController.position.minScrollExtent &&
        !lstController.position.outOfRange) {
      //reach bottom
    }
  }
}

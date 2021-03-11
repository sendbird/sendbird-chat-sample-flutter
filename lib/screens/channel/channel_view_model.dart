import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sendbird_flutter/screens/channel/components/message_item.dart';
import 'package:sendbird_flutter/styles/color.dart';
import 'package:sendbird_flutter/styles/text_style.dart';
import 'package:sendbirdsdk/sendbirdsdk.dart';

enum PopupMenuType { edit, delete, copy }

class ChannelViewModel with ChangeNotifier {
  List<BaseMessage> messages = [];
  GroupChannel channel;
  File uploadFile;

  BaseMessage selectedMessage;

  SendbirdSdk sdk = SendbirdSdk();

  User currentUser = SendbirdSdk().getCurrentUser();

  StreamSubscription messageSubs;
  StreamSubscription messageUpdateSubs;
  StreamSubscription messageDeleteSubs;

  bool hasNext = false;
  bool isLoading = false;
  bool isDisposed = false;
  bool isEditing = false;

  final ScrollController lstController = ScrollController();

  int get itemCount => hasNext ? messages.length + 1 : messages.length;

  ChannelViewModel({this.channel}) {
    messageSubs = sdk
        .messageReceiveStream(channelUrl: channel.channelUrl)
        .listen((message) {
      messages.insert(0, message);
      channel.markAsRead();
      notifyListeners();
    });

    messageUpdateSubs = sdk
        .messageUpdateStream(channelUrl: channel.channelUrl)
        .listen((message) {
      final index =
          messages.indexWhere((e) => e.messageId == message.messageId);
      if (index != -1) messages[index] = message;
      notifyListeners();
    });

    messageDeleteSubs = sdk
        .messageDeleteStream(channelUrl: channel.channelUrl)
        .listen((messageId) {
      messages.removeWhere((e) => e.messageId == messageId);
      notifyListeners();
    });

    lstController.addListener(_scrollListener);
    channel.markAsRead();
  }

  @override
  void dispose() async {
    super.dispose();
    messageDeleteSubs?.cancel();
    messageUpdateSubs?.cancel();
    messageSubs?.cancel();
    isDisposed = true;
  }

  void setEditing(bool value) {
    final prev = isEditing;
    isEditing = value;
    if (value != prev) notifyListeners();
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
      hasNext = messages.length == 20;
      isLoading = false;
      if (!isDisposed) notifyListeners();
    } catch (e) {
      isLoading = false;
      print('group_channel_view.dart: getMessages: ERROR: $e');
    }
  }

  void onSendUserMessage(String message) async {
    if (message == '') {
      return;
    }

    final preMessage = channel.sendUserMessageWithText(message.trim(),
        onCompleted: (msg, error) {
      // messages.repl(0, msg);
      final index =
          messages.indexWhere((element) => element.requestId == msg.requestId);
      if (index != -1) {
        messages[index] = msg;
        channel.markAsRead();
        if (!isDisposed) notifyListeners();
      }
    });

    messages.insert(0, preMessage);
    if (!isDisposed) notifyListeners();

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
        channel.sendFileMessage(params, onCompleted: (msg, error) {
      final index =
          messages.indexWhere((element) => element.requestId == msg.requestId);
      if (index != -1) {
        messages[index] = msg;
        if (!isDisposed) notifyListeners();
      }
    });

    messages.insert(0, preMessage);
    if (!isDisposed) notifyListeners();

    lstController.animateTo(
      0.0,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void onDeleteMessage(int messageId) async {
    try {
      await channel.deleteMessage(messageId);
      notifyListeners();
    } catch (e) {
      //error
    }
  }

  void onUpdateMessage(String updateText) async {
    isEditing = false;

    if (updateText == null) {
      selectedMessage = null;
      notifyListeners();
      return;
    }

    if (selectedMessage == null) return;

    try {
      await channel.updateUserMessage(
          selectedMessage.messageId, UserMessageParams(message: updateText));
      selectedMessage = null;
      notifyListeners();
    } catch (e) {
      selectedMessage = null;
    }
  }

  void onCopyText(String text) {
    Clipboard.setData(new ClipboardData(text: text));
  }

  MessageState getMessageState(BaseMessage message) {
    if (message.sendingStatus != MessageSendingStatus.succeeded)
      return MessageState.none;

    final readAll = channel.getUnreadMembers(message, false).length == 0;
    final deliverAll = channel.getUndeliveredMembers(message).length == 0;

    if (readAll)
      return MessageState.read;
    else if (deliverAll)
      return MessageState.deliver;
    else
      return MessageState.none;
  }

  // ui helpers

  void showBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
              child: Container(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    title: new Text(
                      'Camera',
                      style: TextStyles.sendbirdBody1OnLight1,
                    ),
                    trailing: ImageIcon(
                      AssetImage('assets/iconCamera@3x.png'),
                      color: SBColors.primary_300,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      showPicker(ImageSource.camera);
                    }),
                ListTile(
                    title: new Text(
                      'Photo & Video Library',
                      style: TextStyles.sendbirdBody1OnLight1,
                    ),
                    trailing: ImageIcon(
                      AssetImage('assets/iconPhoto@3x.png'),
                      color: SBColors.primary_300,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      showPicker(ImageSource.gallery);
                    }),
                // ListTile(
                //   title: new Text('Document',
                //       style: TextStyles.sendbirdBody1OnLight1),
                //   trailing: ImageIcon(AssetImage('assets/iconDocument@3x.png')),
                //   onTap: () => {},
                // ),
                ListTile(
                  title: new Text('Cancel'),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ));
        });
  }

  void showPicker(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: source);
    if (pickedFile != null) {
      onSendFileMessage(File(pickedFile.path));
    }
  }

  // void showFilePicker() async {
  //   final pickedFile = await FilePicker.platform.pickFiles();
  //   if (pickedFile != null) {
  //     onSendFileMessage(File(pickedFile.files.single.path));
  //   }
  // }

  void showMessageMenu({
    BuildContext context,
    BaseMessage message,
    Offset pos,
  }) async {
    List<PopupMenuEntry> items = [];
    if (message.isMyMessage) {
      items.add(_buildPopupItem(
        'Edit',
        'assets/iconEdit@3x.png',
        PopupMenuType.edit,
      ));
    }
    items = items +
        [
          PopupMenuDivider(height: 1),
          _buildPopupItem(
            'Copy',
            'assets/iconCopy@3x.png',
            PopupMenuType.copy,
          ),
          PopupMenuDivider(height: 1),
          _buildPopupItem(
            'Delete',
            'assets/iconDelete@3x.png',
            PopupMenuType.delete,
          ),
        ];

    selectedMessage = message;

    double x = pos.dx, y = pos.dy;
    final height = MediaQuery.of(context).size.height;
    if (height - pos.dy <= height / 3) y = pos.dy - 140;

    final selected = await showMenu(
        context: context,
        // initialValue: PopupMenuType.edit,
        position: RelativeRect.fromLTRB(x, y, pos.dx + 1, pos.dy + 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        items: items);

    print(selected);
    switch (selected) {
      case PopupMenuType.edit:
        setEditing(true);
        break;
      case PopupMenuType.copy:
        onCopyText(selectedMessage.message);
        selectedMessage = null;
        break;
      case PopupMenuType.delete:
        onDeleteMessage(selectedMessage.messageId);
        selectedMessage = null;
        break;
      default:
        selectedMessage = null;
        break;
    }
  }

  Widget _buildPopupItem(String text, String imageName, PopupMenuType value) {
    return PopupMenuItem(
        height: 40,
        child: Container(
          constraints: BoxConstraints(minWidth: 180),
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(text),
              SizedBox(width: 8),
              ImageIcon(
                AssetImage(imageName),
                color: SBColors.primary_300,
              )
            ],
          ),
        ),
        value: value);
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

extension Message on BaseMessage {
  bool get isMyMessage =>
      sender?.userId == SendbirdSdk().getCurrentUser().userId;
}

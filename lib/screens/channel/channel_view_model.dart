import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sendbird_flutter/main.dart';

import 'package:sendbird_flutter/screens/channel/components/attachment_modal.dart';
import 'package:sendbird_flutter/screens/channel/components/message_item.dart';
import 'package:sendbird_flutter/screens/channel/components/user_profile.dart';
import 'package:sendbird_flutter/styles/color.dart';
import 'package:sendbird_flutter/utils/debounce.dart';
import 'package:sendbird_flutter/utils/extensions.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';

enum PopupMenuType { edit, delete, copy }
enum UserEngagementState { typing, online, last_seen, none }

class ChannelViewModel
    with ChangeNotifier, ChannelEventHandler, ConnectionEventHandler {
  List<BaseMessage> _messages = [];
  late GroupChannel channel;
  late String channelUrl;
  File? uploadFile;

  BaseMessage? selectedMessage;

  User currentUser = sendbird.currentUser!;

  bool hasNext = false;
  bool isLoading = false;
  bool isDisposed = false;
  bool isEditing = false;

  final ScrollController lstController = ScrollController();
  final readDebouncer = Debouncer(milliseconds: 1000);
  Timer? _typingTimer;

  int get itemCount => hasNext ? _messages.length + 1 : _messages.length;
  bool get displayOnline => channel.members.length == 2;

  UserEngagementState get engagementState {
    return channel.getTypingUsers().length != 0
        ? UserEngagementState.typing
        : UserEngagementState.none;
  }

  String? get lastSeenText {
    if (channel.memberCount != 2) return null;
    final other =
        channel.members.where((e) => e.userId != currentUser.userId).first;
    final readStatus = channel.getReadStatus(false);
    final receipt = readStatus[other.userId] ?? {};
    return (receipt['last_seen_at'] as int).readableLastSeen();
  }

  String get typersText {
    final users = channel.getTypingUsers();
    if (users.length == 1)
      return '${users.first.nickname} is typing...';
    else if (users.length == 2)
      return '${users.first.nickname} and ${users.last.nickname} is typing...';
    else if (users.length > 2)
      return '${users.first.nickname} and ${users.length - 1} more are typing...';
    return '';
  }

  List<BaseMessage> get messages => _messages;

  ChannelViewModel(this.channelUrl) {
    sendbird.addChannelEventHandler('channel_listener', this);
    lstController.addListener(_scrollListener);
    // channel.markAsRead();
  }

  @override
  void dispose() async {
    super.dispose();
    sendbird.removeChannelEventHandler('channel_listener');
    channel.endTyping();
    isDisposed = true;
  }

  void setEditing(bool value) {
    final prev = isEditing;
    isEditing = value;
    if (value != prev) notifyListeners();
  }

  Future<void> loadChannel() async {
    channel = await GroupChannel.getChannel(channelUrl);
    channel.markAsRead();
  }

  Future<void> loadMessages({
    int? timestamp,
    bool reload = false,
  }) async {
    if (isLoading) {
      return;
    }

    isLoading = true;

    final ts = reload
        ? DateTime.now().millisecondsSinceEpoch
        : timestamp ?? DateTime.now().millisecondsSinceEpoch;

    try {
      final params = MessageListParams()
        ..isInclusive = false
        ..includeThreadInfo = true
        ..reverse = true
        ..previousResultSize = 20;
      final messages = await channel.getMessagesByTimestamp(ts, params);
      _messages = reload ? messages : _messages + messages;
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
          _messages.indexWhere((element) => element.requestId == msg.requestId);
      if (index != -1) _messages.removeAt(index);
      _messages = [msg, ..._messages];
      _messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      markAsReadDebounce();
      if (!isDisposed) notifyListeners();
    });

    _messages = [preMessage, ..._messages];
    if (!isDisposed) notifyListeners();

    lstController.animateTo(
      0.0,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void onSendFileMessage(File file) async {
    final params = FileMessageParams.withFile(file);
    final preMessage =
        channel.sendFileMessage(params, onCompleted: (msg, error) {
      final index =
          _messages.indexWhere((element) => element.requestId == msg.requestId);
      if (index != -1) _messages.removeAt(index);
      _messages = [msg, ..._messages];
      _messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      markAsReadDebounce();
      if (!isDisposed) notifyListeners();
    });

    _messages = [preMessage, ..._messages];
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

  void onUpdateMessage(String? updateText) async {
    isEditing = false;

    if (updateText == null) {
      selectedMessage = null;
      notifyListeners();
      return;
    }

    if (selectedMessage == null) return;

    try {
      await channel.updateUserMessage(
          selectedMessage!.messageId, UserMessageParams(message: updateText));
      selectedMessage = null;
      notifyListeners();
    } catch (e) {
      selectedMessage = null;
    }
  }

  void onTyping(bool hasText) {
    if (!hasText) {
      channel.endTyping();
    } else {
      channel.startTyping();
      _typingTimer?.cancel();
      _typingTimer = Timer(Duration(milliseconds: 3000), () {
        channel.endTyping();
      });
    }
  }

  Future<GroupChannel> createChannel(String userId) {
    try {
      final params = GroupChannelParams()
        ..operatorUserIds = [currentUser.userId]
        ..userIds = [userId, currentUser.userId]
        ..isDistinct = true;
      final newChannel = GroupChannel.createChannel(params);
      return newChannel;
    } catch (e) {
      rethrow;
    }
  }

  void onCopyText(String text) {
    Clipboard.setData(new ClipboardData(text: text));
  }

  MessageState getMessageState(BaseMessage message) {
    if (message.sendingStatus != MessageSendingStatus.succeeded)
      return MessageState.none;

    final readAll = channel.getUnreadMembers(message).length == 0;
    final deliverAll = channel.getUndeliveredMembers(message).length == 0;

    if (readAll)
      return MessageState.read;
    else if (deliverAll)
      return MessageState.delivered;
    else
      return MessageState.none;
  }

  // ui helpers

  void showProfile(BuildContext context, Sender? sender) async {
    if (sender == null) return;

    final modal = ProfileModal(ctx: context, user: sender);
    final goToChannel = await modal.show();
    if (goToChannel) {
      final newChannel = await createChannel(sender.userId);
      Navigator.popAndPushNamed(
        context,
        '/channel',
        arguments: newChannel.channelUrl,
      );
    }
  }

  void showPlusMenu(BuildContext context) async {
    final modal = AttachmentModal(context: context);
    final file = await modal.getFile();
    onSendFileMessage(file);
  }

  void showMessageMenu({
    required BuildContext context,
    required BaseMessage message,
    required Offset pos,
  }) async {
    List<PopupMenuEntry> items = [];
    if (message is UserMessage) {
      items.add(_buildPopupItem(
        'Copy',
        'assets/iconCopy@3x.png',
        PopupMenuType.copy,
      ));
    }

    if (message.isMyMessage && message is UserMessage) {
      items.addAll([
        PopupMenuDivider(height: 1),
        _buildPopupItem(
          'Edit',
          'assets/iconEdit@3x.png',
          PopupMenuType.edit,
        )
      ]);
    }

    if (message.isMyMessage)
      items.addAll([
        if (items.length != 0) PopupMenuDivider(height: 1),
        _buildPopupItem(
          'Delete',
          'assets/iconDelete@3x.png',
          PopupMenuType.delete,
        ),
      ]);

    if (items.isEmpty) return;

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

    switch (selected) {
      case PopupMenuType.edit:
        setEditing(true);
        break;
      case PopupMenuType.copy:
        onCopyText(message.message);
        selectedMessage = null;
        break;
      case PopupMenuType.delete:
        await _showDeleteConfirmation(context);
        selectedMessage = null;
        break;
      default:
        selectedMessage = null;
        break;
    }
  }

  Future _showDeleteConfirmation(BuildContext context) async {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: Text(
        "Delete",
        style: TextStyle(color: Colors.red),
      ),
      onPressed: () {
        onDeleteMessage(selectedMessage!.messageId);
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Delete message?"),
      content: Text("Would you like to delete this message permanently?"),
      actions: [cancelButton, continueButton],
    );

    // show the dialog
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  PopupMenuEntry _buildPopupItem(
      String text, String imageName, PopupMenuType value) {
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
        timestamp: _messages.last.createdAt,
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

  // handlers

  void markAsReadDebounce() {
    this.channel.markAsRead();
    // readDebouncer.run(() => this.channel.markAsRead());
  }

  @override
  void onMessageReceived(BaseChannel channel, BaseMessage message) {
    if (channel.channelUrl != this.channel.channelUrl) return;
    final index = _messages.indexWhere((e) => e.messageId == message.messageId);
    _messages = [..._messages];
    if (index != -1 && _messages.length != 0) {
      _messages.removeAt(index);
      _messages[index] = message;
    } else {
      _messages.insert(0, message);
    }

    markAsReadDebounce();
    notifyListeners();
  }

  @override
  void onMessageUpdated(BaseChannel channel, BaseMessage message) {
    if (channel.channelUrl != this.channel.channelUrl) return;
    final index = _messages.indexWhere((e) => e.messageId == message.messageId);
    _messages = [..._messages];
    if (index != -1 && _messages.length != 0) {
      _messages.removeAt(index);
      _messages[index] = message;
    } else {
      _messages.insert(0, message);
    }

    notifyListeners();
  }

  @override
  void onMessageDeleted(BaseChannel channel, int messageId) {
    _messages = [..._messages];
    _messages.removeWhere((e) => e.messageId == messageId);
    notifyListeners();
  }

  @override
  void onReadReceiptUpdated(GroupChannel channel) {
    _messages = [..._messages];
    notifyListeners();
  }

  @override
  void onDeliveryReceiptUpdated(GroupChannel channel) {
    _messages = [..._messages];
    notifyListeners();
  }

  @override
  void onChannelChanged(BaseChannel channel) {
    notifyListeners();
  }

  @override
  void onTypingStatusUpdated(GroupChannel channel) {
    if (channel.channelUrl == this.channel.channelUrl) {
      notifyListeners();
    }
  }

  @override
  void onReconnectionSucceeded() {}
}

extension Message on BaseMessage {
  bool get isMyMessage => sender?.userId == sendbird.currentUser?.userId;
}

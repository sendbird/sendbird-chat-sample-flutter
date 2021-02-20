import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sendbird_flutter/components/avatar_view.dart';
import 'package:sendbird_flutter/components/channel_title_text_view.dart';
import 'package:sendbird_flutter/components/message_item.dart';

import 'package:sendbirdsdk/sendbirdsdk.dart';

class ChannelScreen extends StatefulWidget {
  final GroupChannel channel;

  ChannelScreen({this.channel, Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ChannelScreenState();
}

class _ChannelScreenState extends State<ChannelScreen> {
  final ScrollController lstController = ScrollController();
  final TextEditingController inputController = new TextEditingController();

  List<BaseMessage> messages = [];

  File uploadFile;

  SendbirdSdk sdk = SendbirdSdk();
  User currentUser = SendbirdSdk().getCurrentUser();
  StreamSubscription messageSubs;
  bool isLoading = false;

  final picker = ImagePicker();

  @override
  void initState() {
    _loadMessages(channel: widget.channel, reload: true);
    lstController.addListener(_scrollListener);

    messageSubs = sdk
        .messageReceiveStream(channelUrl: widget.channel.channelUrl)
        .listen((message) {
      setState(() {
        messages.insert(0, message);
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    messageSubs?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildNavigationBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: lstController,
                itemCount: messages.length,
                shrinkWrap: true,
                reverse: true,
                padding: EdgeInsets.only(top: 10, bottom: 10),
                // physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  //bind message into item
                  //this can be streambuilder
                  final message = messages[index];
                  final isMyMessage =
                      message.sender?.userId == currentUser.userId;
                  return MessageItem(
                    message: messages[index],
                    isMyMessage: isMyMessage,
                  );
                },
              ),
            ),
            _buildInputField(),
          ],
        ),
      ),
    );
  }

  // build helpers

  Widget _buildNavigationBar() {
    final currentUser = SendbirdSdk().getCurrentUser();

    return AppBar(
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 65,
      backgroundColor: Colors.white,
      flexibleSpace: SafeArea(
        child: Container(
          padding: EdgeInsets.only(right: 16),
          child: Row(
            children: <Widget>[
              BackButton(color: Theme.of(context).primaryColor),
              SizedBox(width: 2),
              AvatarView(
                channel: widget.channel,
                currentUserId: currentUser.userId,
                width: 25,
                height: 25,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //bind channel and current user data into title view
                    ChannelTitleTextView(widget.channel, currentUser.userId)
                  ],
                ),
              ),
              Icon(Icons.settings, color: Colors.black54),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField() {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Container(
          padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
          height: 60,
          width: double.infinity,
          color: Colors.white,
          child: Row(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  getImage();
                  //show option view for camera or library
                },
                child: Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.purple),
                  ),
                  child: Icon(Icons.add, color: Colors.purple, size: 24),
                ),
              ),
              SizedBox(
                width: 15,
              ),
              Expanded(
                child: TextField(
                  controller: inputController,
                  decoration: InputDecoration(
                    hintText: "Write message...",
                    hintStyle: TextStyle(color: Colors.black54),
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(
                width: 15,
              ),
              FloatingActionButton(
                onPressed: () {
                  _onSendMessage();
                },
                child: Icon(Icons.send, color: Colors.purple, size: 20),
                backgroundColor: Colors.white,
                elevation: 0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // event listener

  _scrollListener() {
    if (lstController.offset >= lstController.position.maxScrollExtent &&
        !lstController.position.outOfRange &&
        !isLoading) {
      final offset = lstController.offset;

      _loadMessages(
        channel: widget.channel,
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

  // picker

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        print('${pickedFile.path}');
      } else {
        print('No image selected.');
      }
    });
  }

  // Sendbird logic

  Future<void> _loadMessages({
    GroupChannel channel,
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

      setState(() {
        isLoading = false;
        this.messages = reload ? messages : this.messages + messages;
      });
    } catch (e) {
      isLoading = false;
      print('group_channel_view.dart: getMessages: ERROR: $e');
    }
  }

  void _onSendMessage() async {
    if (inputController.text == '' && uploadFile == null) {
      return;
    }

    if (uploadFile != null) {
      // send file
    } else if (inputController.text != '') {
      widget.channel.sendUserMessageWithText(inputController.text).then((msg) {
        setState(() {
          messages.insert(0, msg);
        });
      }).catchError((e) {});
      inputController.clear();
      lstController.animateTo(
        0.0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      //ignore
    }
  }
}

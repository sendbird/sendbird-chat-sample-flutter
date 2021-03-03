import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sendbird_flutter/components/avatar_view.dart';
import 'package:sendbird_flutter/components/channel_title_text_view.dart';
import 'package:sendbird_flutter/components/file_message_item.dart';
import 'package:sendbird_flutter/components/message_item.dart';
import 'package:sendbird_flutter/view_models/channel_view_model.dart';

import 'package:sendbirdsdk/sendbirdsdk.dart';

class ChannelScreen extends StatefulWidget {
  final GroupChannel channel;

  ChannelScreen({this.channel, Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ChannelScreenState();
}

class _ChannelScreenState extends State<ChannelScreen> {
  ChannelViewModel model;

  @override
  void initState() {
    // _loadMessages(channel: widget.channel, reload: true);
    // lstController.addListener(_scrollListener);

    model = ChannelViewModel(channel: widget.channel);
    model.loadMessages(reload: true);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    // model.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildNavigationBar(),
      body: ChangeNotifierProvider<ChannelViewModel>(
        builder: (context) => model,
        child: Consumer<ChannelViewModel>(
          builder: (context, value, child) {
            return SafeArea(
              child: Column(
                children: [
                  _buildContent(value),
                  _buildInputField(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // build helpers

  Widget _buildNavigationBar() {
    final currentUser = model.currentUser;

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

  Widget _buildContent(ChannelViewModel model) {
    //FIX: need to figure out not to reload every item in list
    return Expanded(
      child: ListView.builder(
        controller: model.lstController,
        itemCount: model.messages.length,
        shrinkWrap: true,
        reverse: true,
        padding: EdgeInsets.only(top: 10, bottom: 10),
        // physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          //bind message into item
          //this can be streambuilder
          final message = model.messages[index];
          final isMyMessage =
              message.sender?.userId == model.currentUser.userId;
          if (message is FileMessage) {
            return FileMessageItem(
              message: model.messages[index],
              isMyMessage: isMyMessage,
            );
          } else {
            return MessageItem(
              message: model.messages[index],
              isMyMessage: isMyMessage,
            );
          }
        },
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
                onTap: () async {
                  model.showPicker();
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
                  controller: model.inputController,
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
                  model.onSendUserMessage();
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
}

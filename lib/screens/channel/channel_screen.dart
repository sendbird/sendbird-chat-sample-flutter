import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as p;

import 'package:sendbird_flutter/components/avatar_view.dart';
import 'package:sendbird_flutter/components/channel_title_text_view.dart';
import 'package:sendbird_flutter/screens/channel/components/admin_message_item.dart';
import 'package:sendbird_flutter/screens/channel/components/file_message_item.dart';
import 'package:sendbird_flutter/screens/channel/components/message_input.dart';
import 'package:sendbird_flutter/screens/channel/components/user_message_item.dart';
import 'package:sendbird_flutter/styles/text_style.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';
import 'package:sendbird_flutter/screens/channel/channel_view_model.dart';

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
    model = ChannelViewModel(channel: widget.channel);
    model.loadMessages(reload: true);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return p.ChangeNotifierProvider<ChannelViewModel>(
      create: (context) => model,
      child: Scaffold(
        appBar: _buildNavigationBar(),
        body: SafeArea(
          child: Column(
            children: [
              //TODO: message
              // p.Selector<ChannelViewModel, List<BaseMessage>>(
              //   selector: (_, model) => model.messages,
              //   builder: (c, msgs, child) {
              //     return _buildContent();
              //   },
              // ),
              p.Consumer<ChannelViewModel>(
                builder: (context, value, child) {
                  return _buildContent();
                },
              ),
              p.Selector<ChannelViewModel, bool>(
                selector: (_, model) => model.isEditing,
                builder: (c, editing, child) {
                  return MessageInput(
                    onPressPlus: () {
                      model.showPlusMenu(context);
                    },
                    onPressSend: (text) {
                      model.onSendUserMessage(text);
                    },
                    onEditing: (text) {
                      model.onUpdateMessage(text);
                    },
                    onChanged: (text) {
                      model.onTyping(text != '');
                    },
                    placeholder: model.selectedMessage?.message,
                    isEditing: editing,
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  // build helpers

  Widget _buildNavigationBar() {
    final currentUser = model.currentUser;

    return AppBar(
      elevation: 1,
      automaticallyImplyLeading: false,
      toolbarHeight: 65,
      backgroundColor: Colors.white,
      flexibleSpace: SafeArea(
        child: Container(
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
              p.Selector<ChannelViewModel, UserEngagementState>(
                selector: (_, model) => model.engagementState,
                builder: (context, value, child) {
                  return _buildTitle(value);
                },
              ),
              Container(
                margin: EdgeInsets.only(right: 10),
                width: 32,
                child: RawMaterialButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/channel_info',
                      arguments: widget.channel,
                    );
                  },
                  shape: CircleBorder(),
                  child: Image.asset(
                    "assets/iconInfo@3x.png",
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(UserEngagementState ue) {
    List<Widget> headers = [
      ChannelTitleTextView(widget.channel, model.currentUser.userId)
    ];

    switch (ue) {
      case UserEngagementState.typing:
        headers.addAll([
          SizedBox(height: 3),
          Text(
            model.typersText,
            style: TextStyles.sendbirdCaption2OnLight1,
          )
        ]);
        break;
      //   case UserEngagementState.online:
      //     headers.addAll([
      //       SizedBox(height: 3),
      //       Row(
      //         children: [
      //           Container(
      //             width: 6,
      //             height: 6,
      //             margin: EdgeInsets.only(right: 6),
      //             decoration: BoxDecoration(
      //               color: Colors.green,
      //               shape: BoxShape.circle,
      //             ),
      //           ),
      //           Text(
      //             'Online',
      //             style: TextStyles.sendbirdCaption2OnLight1,
      //           )
      //         ],
      //       )
      //     ]);
      //     break;
      //   case UserEngagementState.last_seen:
      //     headers.addAll([
      //       SizedBox(height: 3),
      //       Text(
      //         model.lastSeenText,
      //         style: TextStyles.sendbirdCaption2OnLight1,
      //       )
      //     ]);
      //     break;
      default:
        break;
    }

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: headers,
      ),
    );
  }

  Widget _buildContent() {
    // return p.Consumer<ChannelViewModel>(builder: (context, value, child) {
    return Expanded(
      child: Container(
        color: Colors.white,
        child: ListView.builder(
          controller: model.lstController,
          itemCount: model.itemCount,
          shrinkWrap: true,
          reverse: true,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.only(top: 10, bottom: 10),
          itemBuilder: (context, index) {
            if (index == model.messages.length && model.hasNext) {
              return Center(
                child: Container(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final message = model.messages[index];
            final prev = (index < model.messages.length - 1)
                ? model.messages[index + 1]
                : null;
            final next = index == 0 ? null : model.messages[index - 1];

            if (message is FileMessage) {
              return FileMessageItem(
                curr: message,
                prev: prev,
                next: next,
                model: model,
                isMyMessage: message.isMyMessage,
                onPress: (pos) {
                  //
                },
                onLongPress: (pos) {
                  model.showMessageMenu(
                    context: context,
                    message: message,
                    pos: pos,
                  );
                },
              );
            } else if (message is AdminMessage) {
              return AdminMessageItem(curr: message);
            } else {
              return UserMessageItem(
                curr: message,
                prev: prev,
                next: next,
                model: model,
                isMyMessage: message.isMyMessage,
                onPress: (pos) {
                  //
                },
                onLongPress: (pos) {
                  model.showMessageMenu(
                    context: context,
                    message: message,
                    pos: pos,
                  );
                },
              );
            }
          },
        ),
      ),
    );
    // });
    // );
  }
}

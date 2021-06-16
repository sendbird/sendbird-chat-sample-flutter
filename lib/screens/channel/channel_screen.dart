import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sendbird_flutter/components/avatar_view.dart';
import 'package:sendbird_flutter/components/channel_title_text_view.dart';
import 'package:sendbird_flutter/helper/push_handler.dart';
import 'package:sendbird_flutter/screens/channel/components/admin_message_item.dart';
import 'package:sendbird_flutter/screens/channel/components/file_message_item.dart';
import 'package:sendbird_flutter/screens/channel/components/message_input.dart';
import 'package:sendbird_flutter/screens/channel/components/user_message_item.dart';
import 'package:sendbird_flutter/styles/text_style.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';
import 'package:sendbird_flutter/screens/channel/channel_view_model.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ChannelScreen extends StatefulWidget {
  final String channelUrl;

  ChannelScreen({required this.channelUrl, Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ChannelScreenState();
}

class _ChannelScreenState extends State<ChannelScreen>
    with PushHandler, WidgetsBindingObserver {
  late ChannelViewModel model;
  bool channelLoaded = false;

  @override
  void initState() {
    model = ChannelViewModel(widget.channelUrl);
    model.loadChannel().then((value) {
      setState(() {
        channelLoaded = true;
      });
      model.loadMessages(reload: true);
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      model.loadMessages(reload: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ChannelViewModel>(
      create: (context) => model,
      child: (!channelLoaded)
          ? Scaffold(
              body: Center(
                child: Container(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(),
                ),
              ),
            )
          : VisibilityDetector(
              onVisibilityChanged: (info) {
                screenBecomeVisible(
                  info.visibleFraction == 1,
                  pop: PopType.replace,
                );
              },
              key: Key('channel_key'),
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
                      Consumer<ChannelViewModel>(
                        builder: (context, value, child) {
                          return _buildContent();
                        },
                      ),
                      Selector<ChannelViewModel, bool>(
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
            ),
    );
  }

  // build helpers

  AppBar _buildNavigationBar() {
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
                channel: model.channel,
                currentUserId: currentUser.userId,
                width: 25,
                height: 25,
              ),
              SizedBox(width: 12),
              Selector<ChannelViewModel, UserEngagementState>(
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
                      arguments: model.channel,
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
      ChannelTitleTextView(model.channel, model.currentUser.userId)
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
              return AdminMessageItem(curr: message, model: model);
            } else if (message is UserMessage) {
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
            } else {
              //undefined message type
              return Container();
            }
          },
        ),
      ),
    );
    // });
    // );
  }
}

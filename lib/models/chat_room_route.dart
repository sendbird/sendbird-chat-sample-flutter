import 'package:app/components/app_bar.dart';
import 'package:app/components/dialog.dart';
import 'package:app/components/message_field.dart';
import 'package:app/components/padding.dart';
import 'package:app/controllers/authentication_controller.dart';
import 'package:app/handlers/channel_event_handlers.dart';
import 'package:app/models/edit_message_route.dart';
import 'package:app/requests/message_requests.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class ChatRoomRoute extends StatefulWidget {
  const ChatRoomRoute({Key? key}) : super(key: key);

  @override
  ChatRoomRouteState createState() => ChatRoomRouteState();
}

class ChatRoomRouteState extends State<ChatRoomRoute> {
  final BaseAuth _authentication = Get.find<AuthenticationController>();
  final String? _channelUrl = Get.parameters['channelUrl'];
  final ChannelType _channelType = Get.arguments[0];
  late final ScrollController _scrollController;
  late final TextEditingController _messageController;
  BaseChannel? _channel;
  late Future<BaseChannel>? _futureChannel;
  late final ChannelEventHandlers _channelHandler;

  @override
  void initState() {
    _scrollController = ScrollController();
    _messageController = TextEditingController();
    _channelHandler = ChannelEventHandlers(
      refresh: refresh,
      channelUrl: _channelUrl!,
      channelType: _channelType,
    );

    _futureChannel = _channelHandler
        .getChannel(_channelUrl!, channelType: _channelType)
        .then((channel) {
      _channelHandler.loadMessages(isForce: true);
      if (channel is GroupChannel) {
        channel.markAsRead();
      }

      _channel = channel;
      return channel;
    });

    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_channel is GroupChannel) {
      (_channel as GroupChannel).markAsRead();
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    _channelHandler.dispose();
    super.dispose();
  }

  Future<void> _scrollToBottom() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  Future<void> refresh({
    bool loadPrevious = false,
    bool isForce = false,
  }) async {
    //TODO check
    switch (_channelType) {
      case ChannelType.group:
        _channel ??= await GroupChannel.getChannel(_channelUrl!);
        break;
      case ChannelType.open:
        _channel ??= await OpenChannel.getChannel(_channelUrl!);
        break;
    }

    if (mounted) {
      if (loadPrevious) {
        _channelHandler.loadMessages();
      } else if (isForce) {
        _channelHandler.loadMessages(isForce: true);
      }
    }
    setState(() {});
  }

  Future<void> messageSent() async {
    _scrollToBottom();
    await refresh(isForce: true);
  }

  Widget _infoButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: GestureDetector(
        onTap: () {
          Get.toNamed('/ChatDetailRoute', arguments: [_channel])?.then((_) {
            setState(() {});
          });
        },
        child: const Icon(Icons.info),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _futureChannel,
      builder: (BuildContext context, AsyncSnapshot<BaseChannel> messages) {
        if (messages.hasData) {
          _scrollToBottom();
          return Scaffold(
            appBar: appBarComponent(
                title: 'Chat Room',
                includeLeading: false,
                actions: [_infoButton()]),
            bottomNavigationBar: MessageField(
              controller: _messageController,
              channel: _channel!,
              onSend: messageSent,
            ),
            body: LiquidPullToRefresh(
              onRefresh: () => refresh(loadPrevious: true), // refresh callback
              child: ListView(
                // controller: _scrollController,
                children: [
                  SingleChildScrollView(
                    physics: const ScrollPhysics(),
                    child: paddingComponent(
                      widget: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: _channelHandler.messages.length,
                        itemBuilder: (BuildContext context, int index) {
                          Widget? titleWidget;
                          if (_channelHandler.messages[index] is UserMessage) {
                            titleWidget = Text(
                              _channelHandler.messages[index].message,
                              textAlign: _channelHandler
                                          .messages[index].sender?.userId ==
                                      _authentication.currentUser?.userId
                                  ? TextAlign.right
                                  : TextAlign.left,
                            );
                          } else if (_channelHandler.messages[index]
                              is FileMessage) {
                            titleWidget = Row(
                              mainAxisAlignment: _channelHandler
                                          .messages[index].sender?.userId ==
                                      _authentication.currentUser?.userId
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                CachedNetworkImage(
                                  height: 120,
                                  width: 180,
                                  fit: BoxFit.cover,
                                  imageUrl: (_channelHandler.messages[index]
                                              as FileMessage)
                                          .secureUrl ??
                                      (_channelHandler.messages[index]
                                              as FileMessage)
                                          .url,
                                  placeholder: (context, url) => const SizedBox(
                                    width: 30,
                                    height: 30,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                              ],
                            );
                          } else {
                            printError(info: 'Unknown Message Type');
                          }
                          return ListTile(
                            isThreeLine: true,
                            leading: _channelHandler
                                        .messages[index].sender?.userId ==
                                    _authentication.currentUser?.userId
                                ? null
                                : const Icon(Icons.person),
                            trailing: _channelHandler
                                        .messages[index].sender?.userId ==
                                    _authentication.currentUser?.userId
                                ? const Icon(Icons.person)
                                : null,
                            title: titleWidget,
                            subtitle: _channel!.channelType == ChannelType.group
                                ? Text(
                                    'Unread ${(_channel as GroupChannel).getUnreadMembers(_channelHandler.messages[index]).length}',
                                    textAlign: _channelHandler.messages[index]
                                                .sender?.userId ==
                                            _authentication.currentUser?.userId
                                        ? TextAlign.right
                                        : TextAlign.left,
                                  )
                                : null,
                            onLongPress: () {
                              if (_channelHandler.messages[index]
                                  is UserMessage) {
                                dialogComponent(
                                  context,
                                  buttonText1: 'Edit',
                                  onTap1: () async {
                                    await Navigator.of(context)
                                        .push(
                                      MaterialPageRoute(
                                        builder: ((context) => EditMessageRoute(
                                              message: _channelHandler
                                                      .messages[index]
                                                  as UserMessage,
                                              channel: _channel,
                                            )),
                                      ),
                                    )
                                        .then((value) async {
                                      refresh();
                                    });
                                  },
                                  buttonText2: 'Delete',
                                  onTap2: () async {
                                    await deleteMessage(
                                      channel: _channel,
                                      messageId: _channelHandler
                                          .messages[index].messageId,
                                    );
                                    refresh();
                                  },
                                );
                              } else if (_channelHandler.messages[index]
                                  is FileMessage) {
                                dialogComponent(
                                  context,
                                  type: DialogType.oneButton,
                                  buttonText1: 'Delete',
                                  onTap1: () async {
                                    await deleteMessage(
                                      channel: _channel,
                                      messageId: _channelHandler
                                          .messages[index].messageId,
                                    );
                                    refresh();
                                  },
                                );
                              } else {
                                printError(info: 'Unknown message type');
                              }
                              setState(() {});
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (messages.hasError) {
          return const Center(
            child: Text('Error retrieving Messages'),
          );
        } else {
          return Scaffold(
            appBar: appBarComponent(title: 'Chat Room', includeLeading: false),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}

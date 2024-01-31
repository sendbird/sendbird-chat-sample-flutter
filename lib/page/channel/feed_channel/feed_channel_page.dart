// Copyright (c) 2023 Sendbird, Inc. All rights reserved.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:sendbird_chat_sample/component/widgets.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';
import 'package:sendbird_chat_widget/sendbird_chat_widget.dart';

class FeedChannelPage extends StatefulWidget {
  const FeedChannelPage({Key? key}) : super(key: key);

  @override
  State<FeedChannelPage> createState() => FeedChannelPageState();
}

class FeedChannelPageState extends State<FeedChannelPage> {
  final listBgColor = Colors.blueGrey;

  final channelUrl = Get.parameters['channel_url']!;
  final itemScrollController = ItemScrollController();
  final textEditingController = TextEditingController();
  NotificationCollection? collection;

  String title = '';
  bool hasPrevious = false;
  bool hasNext = false;
  List<NotificationMessage> messageList = [];
  List<String> memberIdList = [];
  NotificationThemeMode themeMode = NotificationThemeMode.light;

  @override
  void initState() {
    super.initState();
    _initializeNotificationCollection();
  }

  void _initializeNotificationCollection() {
    FeedChannel.getChannel(channelUrl).then((channel) {
      collection = NotificationCollection(
        channel: channel,
        params: MessageListParams()..reverse = true,
        handler: MyNotificationCollectionHandler(this),
      )..initialize();

      setState(() {
        title = '${channel.name} (${messageList.length})';
        memberIdList = channel.members.map((member) => member.userId).toList();
        memberIdList.sort((a, b) => a.compareTo(b));
      });
    });
  }

  void _disposeNotificationCollection() {
    collection?.dispose();
  }

  @override
  void dispose() {
    _disposeNotificationCollection();
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Widgets.pageTitle(title, maxLines: 2),
        actions: [
          IconButton(
            icon: Icon((themeMode == NotificationThemeMode.light)
                ? Icons.dark_mode
                : Icons.light_mode),
            onPressed: () {
              setState(() {
                themeMode = (themeMode == NotificationThemeMode.light)
                    ? NotificationThemeMode.dark
                    : NotificationThemeMode.light;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          memberIdList.isNotEmpty ? _memberIdBox() : Container(),
          hasPrevious ? _previousButton() : Container(),
          Expanded(
            child: (collection != null && collection!.messageList.isNotEmpty)
                ? Container(
                    color: listBgColor,
                    child: _list(),
                  )
                : Container(color: listBgColor),
          ),
          hasNext ? _nextButton() : Container(),
        ],
      ),
    );
  }

  Widget _memberIdBox() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: double.maxFinite,
            child: Text(
              memberIdList.toString(),
              textAlign: TextAlign.left,
              style: const TextStyle(fontSize: 12.0, color: Colors.green),
            ),
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _previousButton() {
    return Container(
      width: double.maxFinite,
      height: 32.0,
      color: Colors.purple[200],
      child: IconButton(
        icon: const Icon(Icons.expand_less, size: 16.0),
        color: Colors.white,
        onPressed: () async {
          if (collection != null) {
            if (collection!.params.reverse) {
              if (collection!.hasNext && !collection!.isLoading) {
                await collection!.loadNext();
              }
            } else {
              if (collection!.hasPrevious && !collection!.isLoading) {
                await collection!.loadPrevious();
              }
            }
          }

          setState(() {
            if (collection != null) {
              hasPrevious = collection!.params.reverse
                  ? collection!.hasNext
                  : collection!.hasPrevious;
              hasNext = collection!.params.reverse
                  ? collection!.hasPrevious
                  : collection!.hasNext;
            }
          });
        },
      ),
    );
  }

  Widget _list() {
    return ScrollablePositionedList.builder(
      physics: const ClampingScrollPhysics(),
      initialScrollIndex: (collection != null && collection!.params.reverse)
          ? 0
          : messageList.length - 1,
      itemScrollController: itemScrollController,
      itemCount: messageList.length,
      itemBuilder: (BuildContext context, int index) {
        if (index >= messageList.length) return Container();

        NotificationMessage message = messageList[index];

        // [SendbirdChatWidget]
        final notificationBubbleWidget =
            SendbirdChatWidget.buildNotificationBubbleWidget(
          message: message,
          onError: (NotificationWidgetError error) {
            debugPrint('[NotificationWidgetError] ${error.name}');

            switch (error) {
              case NotificationWidgetError.notificationDisabledError:
                break;
              case NotificationWidgetError.cacheNotFoundError:
                SendbirdChatWidget.cacheNotificationInfo().then((result) {
                  if (result) _refresh();
                });
                break;
              case NotificationWidgetError.templateNotFoundError:
                SendbirdChatWidget.getNotificationTemplate(
                        key: message.notificationData!.templateKey)
                    .then((template) {
                  if (template != null) _refresh();
                });
                break;
              case NotificationWidgetError.notificationDataNotFoundError:
                break;
              case NotificationWidgetError.unknownError:
                break;
            }
          },
          onClick: _onNotificationButtonClicked,
          themeMode: themeMode,
        );

        return GestureDetector(
          onTap: () async {},
          onDoubleTap: () async {},
          onLongPress: () async {},
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: index == 0 ? 18 : 2,
                color: listBgColor,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 16,
                      color: listBgColor,
                      child: Text(
                        message.notificationData?.templateKey ?? '',
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 12.0,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                    Container(
                      height: 16,
                      color: listBgColor,
                      child: Text(
                        DateTime.fromMillisecondsSinceEpoch(message.createdAt)
                            .toString(),
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 12.0,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 2,
                color: listBgColor,
              ),
              Container(
                color: listBgColor,
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: notificationBubbleWidget,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // [SendbirdChatWidget]
  void _onNotificationButtonClicked(
    NotificationMessage message,
    NotificationView view,
    NotificationAction action,
  ) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clicked Action'),
          content: Text(
            '[message.notificationId] ${message.notificationId}\n'
            '[view.type] ${view.type}\n'
            '[action.type] ${action.type}\n'
            '[action.data] ${action.data}\n'
            '[action.alterData] ${action.alterData}',
          ),
        );
      },
    );
  }

  Widget _nextButton() {
    return Container(
      width: double.maxFinite,
      height: 32.0,
      color: Colors.purple[200],
      child: IconButton(
        icon: const Icon(Icons.expand_more, size: 16.0),
        color: Colors.white,
        onPressed: () async {
          if (collection != null) {
            if (collection!.params.reverse) {
              if (collection!.hasPrevious && !collection!.isLoading) {
                await collection!.loadPrevious();
              }
            } else {
              if (collection!.hasNext && !collection!.isLoading) {
                await collection!.loadNext();
              }
            }
          }

          setState(() {
            if (collection != null) {
              hasPrevious = collection!.params.reverse
                  ? collection!.hasNext
                  : collection!.hasPrevious;
              hasNext = collection!.params.reverse
                  ? collection!.hasPrevious
                  : collection!.hasNext;
            }
          });
        },
      ),
    );
  }

  void _refresh() async {
    if (mounted) {
      setState(() {
        if (collection != null) {
          messageList = collection!.messageList;
          title = '${collection!.channel.name} (${messageList.length})';
          hasPrevious = collection!.params.reverse
              ? collection!.hasNext
              : collection!.hasPrevious;
          hasNext = collection!.params.reverse
              ? collection!.hasPrevious
              : collection!.hasNext;
          memberIdList = collection!.channel.members
              .map((member) => member.userId)
              .toList();
          memberIdList.sort((a, b) => a.compareTo(b));
        }
      });
    }
  }

  void _scrollToAddedMessages(CollectionEventSource eventSource) async {
    if (collection == null || collection!.messageList.length <= 1) return;

    final reverse = collection!.params.reverse;
    final previous = eventSource == CollectionEventSource.messageLoadPrevious;

    final int index;
    if ((reverse && previous) || (!reverse && !previous)) {
      index = collection!.messageList.length - 1;
    } else {
      index = 0;
    }

    while (!itemScrollController.isAttached) {
      await Future.delayed(const Duration(milliseconds: 1));
    }

    itemScrollController.scrollTo(
      index: index,
      duration: const Duration(milliseconds: 200),
      curve: Curves.fastOutSlowIn,
    );
  }
}

class MyNotificationCollectionHandler extends NotificationCollectionHandler {
  final FeedChannelPageState _state;
  bool isScrolling = false;

  MyNotificationCollectionHandler(this._state);

  @override
  void onMessagesAdded(NotificationContext context, FeedChannel channel,
      List<NotificationMessage> messages) async {
    _state._refresh();
    _state.collection?.markAsRead(context);

    if (context.collectionEventSource !=
            CollectionEventSource.messageCacheInitialize &&
        context.collectionEventSource !=
            CollectionEventSource.messageInitialize) {
      if (!isScrolling) {
        isScrolling = true;
        Future.delayed(const Duration(milliseconds: 100), () {
          _state._scrollToAddedMessages(context.collectionEventSource);
          isScrolling = false;
        });
      }
    }
  }

  @override
  void onMessagesUpdated(NotificationContext context, FeedChannel channel,
      List<NotificationMessage> messages) async {
    _state._refresh();
  }

  @override
  void onMessagesDeleted(NotificationContext context, FeedChannel channel,
      List<NotificationMessage> messages) {
    _state._refresh();
  }

  @override
  void onChannelUpdated(FeedChannelContext context, FeedChannel channel) {
    _state._refresh();
  }

  @override
  void onChannelDeleted(FeedChannelContext context, String deletedChannelUrl) {
    Get.back();
  }

  @override
  void onHugeGapDetected() {
    _state._disposeNotificationCollection();
    _state._initializeNotificationCollection();
  }
}

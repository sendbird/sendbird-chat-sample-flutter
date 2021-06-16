import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sendbird_flutter/components/avatar_view.dart';
import 'package:sendbird_flutter/screens/channel/channel_view_model.dart';
import 'package:sendbird_flutter/styles/color.dart';
import 'package:sendbird_flutter/styles/text_style.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';

enum MessagePosition {
  continuous,
  normal,
}

enum MessageState {
  read,
  delivered,
  none,
}

class MessageItem extends StatelessWidget {
  final BaseMessage curr;
  final BaseMessage? prev;
  final BaseMessage? next;
  final bool? isMyMessage;
  final ChannelViewModel model;

  final Function(Offset)? onLongPress;
  final Function(Offset)? onPress;

  Widget get content => throw UnimplementedError();

  String get _currTime => DateFormat('kk:mm a')
      .format(DateTime.fromMillisecondsSinceEpoch(curr.createdAt));

  MessageItem({
    required this.curr,
    this.prev,
    this.next,
    this.isMyMessage,
    required this.model,
    this.onPress,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isCenter = isMyMessage == null;
    return Container(
      padding: EdgeInsets.only(
        left: 14,
        right: 14,
        top: _isContinuous(prev, curr) ? 2 : 16,
      ),
      child: Align(
        alignment: isCenter
            ? Alignment.center
            : isMyMessage!
                ? Alignment.topRight
                : Alignment.topLeft,
        child: isCenter
            ? _buildCenterWidget()
            : isMyMessage!
                ? _bulidRightWidget()
                : _buildLeftWidget(context),
      ),
    );
  }

  Widget _buildCenterWidget() {
    return Column(
      children: [
        if (!_isSameDate(prev, curr)) _dateWidget(curr),
        content,
      ],
    );
  }

  Widget _bulidRightWidget() {
    final wrap = Container(
      child: GestureDetector(
          onLongPressStart: (details) {
            if (onLongPress != null) onLongPress!(details.globalPosition);
          },
          onTapDown: (details) {
            if (onPress != null) onPress!(details.globalPosition);
          },
          child: content),
      constraints: BoxConstraints(maxWidth: 240),
    );

    // List<Widget> children = _timestampDefaultWidget(curr) + [wrap];
    List<Widget> children = [_additionalWidgetsForRight(curr), wrap];

    return Column(
      children: [
        if (!_isSameDate(prev, curr)) _dateWidget(curr),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: children,
        ),
      ],
    );
  }

  Widget _buildLeftWidget(BuildContext ctx) {
    final wrap = Container(
      child: GestureDetector(
          onLongPressStart: (details) {
            if (onLongPress != null) onLongPress!(details.globalPosition);
          },
          onTapDown: (details) {
            if (onPress != null) onPress!(details.globalPosition);
          },
          child: content),
      constraints: BoxConstraints(maxWidth: 240),
    );

    List<Widget> children = _avatarDefaultWidget(curr, ctx) +
        [
          Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _nameDefaultWidget(curr) + [wrap])
        ] +
        _timestampDefaultWidget(curr);

    return Column(
      children: [
        if (!_isSameDate(prev, curr)) _dateWidget(curr),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: children,
        )
      ],
    );
  }

  bool _isContinuous(BaseMessage? p, BaseMessage? c) {
    if (p == null || c == null) {
      return false;
    }

    if (p.sender?.userId != c.sender?.userId) {
      return false;
    }

    final pt = DateTime.fromMillisecondsSinceEpoch(p.createdAt);
    final ct = DateTime.fromMillisecondsSinceEpoch(c.createdAt);

    final diff = pt.difference(ct);
    if (diff.inMinutes.abs() < 1 && pt.minute == ct.minute) {
      return true;
    }
    return false;
  }

  bool _isSameDate(BaseMessage? p, BaseMessage? c) {
    if (p == null || c == null) {
      return false;
    }

    final pt = DateTime.fromMillisecondsSinceEpoch(p.createdAt);
    final ct = DateTime.fromMillisecondsSinceEpoch(c.createdAt);

    return pt.year == ct.year && pt.month == ct.month && pt.day == ct.day;
  }

  Widget _dateWidget(BaseMessage message) {
    final date = DateTime.fromMillisecondsSinceEpoch(message.createdAt);
    final format = DateFormat('E, MMM d').format(date);
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: SBColors.onlight_03,
      ),
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      child: Text(
        '$format',
        style: TextStyles.sendbirdCaption1OnDark1,
      ),
    );
  }

  Widget _additionalWidgetsForRight(BaseMessage message) {
    //status pending -> loader
    if (message.sendingStatus == MessageSendingStatus.pending) {
      return Container(
        width: 12,
        height: 12,
        margin: EdgeInsets.only(right: 3, bottom: 3),
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    //status failed -> error icon
    if (message.sendingStatus == MessageSendingStatus.failed) {
      return Container(
        width: 16,
        height: 16,
        margin: EdgeInsets.only(right: 2),
        child: Image(image: AssetImage('assets/iconError@3x.png')),
      );
    }

    return _stateAndTimeWidget(message);
  }

  Widget _stateAndTimeWidget(BaseMessage message) {
    final state = model.getMessageState(message);
    final image = state == MessageState.read
        ? Image(image: AssetImage('assets/iconDoneAll@3x.png'))
        : state == MessageState.delivered
            ? Image(
                image: AssetImage('assets/iconDoneAll@3x.png'),
                color: Colors.grey,
              )
            : Image(image: AssetImage('assets/iconDone@3x.png'));

    return Container(
        margin: EdgeInsets.only(right: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[Container(width: 16, height: 16, child: image)] +
              _timestampDefaultWidget(message),
        ));
  }

  List<Widget> _timestampDefaultWidget(BaseMessage message) {
    final myMessage = isMyMessage;
    if (myMessage == null) return [];

    return !_isContinuous(curr, next)
        ? [
            if (!myMessage) SizedBox(width: 3),
            Text(
              _currTime,
              style: TextStyles.sendbirdCaption4OnLight3,
            ),
            if (myMessage) SizedBox(width: 3)
          ]
        : [];
  }

  List<Widget> _nameDefaultWidget(BaseMessage message) {
    return !_isContinuous(prev, curr)
        ? [
            Text(
              message.sender?.nickname ?? '',
              style: TextStyles.sendbirdCaption1OnLight2,
            ),
            SizedBox(height: 4),
          ]
        : [];
  }

  List<Widget> _avatarDefaultWidget(BaseMessage message, BuildContext ctx) {
    return !_isContinuous(curr, next)
        ? [
            AvatarView(
              user: message.sender,
              width: 26,
              height: 26,
              onPressed: () => model.showProfile(ctx, message.sender),
            ),
            SizedBox(width: 12),
          ]
        : [SizedBox(width: 38, height: 26)];
  }
}

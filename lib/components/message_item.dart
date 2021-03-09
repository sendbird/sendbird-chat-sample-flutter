import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sendbird_flutter/styles/color.dart';
import 'package:sendbird_flutter/styles/text_style.dart';
import 'package:sendbirdsdk/sendbirdsdk.dart';

import 'avatar_view.dart';

enum MessagePosition {
  continuous,
  normal,
}

class MessageItem extends StatelessWidget {
  final BaseMessage curr;
  final BaseMessage prev;
  final BaseMessage next;
  final bool isMyMessage;

  Widget get content => null;

  String get _currTime => DateFormat('kk:mm a')
      .format(DateTime.fromMillisecondsSinceEpoch(curr.createdAt));

  MessageItem({this.curr, this.prev, this.next, this.isMyMessage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 14,
        right: 14,
        top: _isContinuous(prev, curr) ? 2 : 16,
      ),
      child: Align(
        alignment: isMyMessage ? Alignment.topRight : Alignment.topLeft,
        child: isMyMessage ? _bulidRightWidget() : _buildLeftWidget(),
      ),
    );
  }

  Widget _bulidRightWidget() {
    final wrap =
        Container(child: content, constraints: BoxConstraints(maxWidth: 240));
    List<Widget> children = _timestampDefaultWidget(curr) + [wrap];

    return Column(
      children: [
        if (!_isSameDate(prev, curr)) _dateWidget(curr),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: children,
        )
      ],
    );
  }

  Widget _buildLeftWidget() {
    final wrap =
        Container(child: content, constraints: BoxConstraints(maxWidth: 240));
    List<Widget> lst = _nameDefaultWidget(curr) + [wrap];
    List<Widget> children = _avatarDefaultWidget(curr) +
        [Column(children: lst)] +
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

  bool _isContinuous(BaseMessage p, BaseMessage c) {
    if (p == null || c == null) {
      return false;
    }

    if (p.sender.userId != c.sender.userId) {
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

  bool _isSameDate(BaseMessage p, BaseMessage c) {
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

  List<Widget> _timestampDefaultWidget(BaseMessage message) {
    return !_isContinuous(curr, next)
        ? [
            if (!isMyMessage) SizedBox(width: 3),
            Text(
              _currTime,
              style: TextStyles.sendbirdCaption4OnLight3,
            ),
            if (isMyMessage) SizedBox(width: 3)
          ]
        : [];
  }

  List<Widget> _nameDefaultWidget(BaseMessage message) {
    return !_isContinuous(prev, curr)
        ? [
            Text(message.sender.nickname),
            SizedBox(height: 4),
          ]
        : [];
  }

  List<Widget> _avatarDefaultWidget(BaseMessage message) {
    return !_isContinuous(curr, next)
        ? [
            AvatarView(user: message.sender, width: 26, height: 26),
            SizedBox(width: 12),
          ]
        : [];
  }
}

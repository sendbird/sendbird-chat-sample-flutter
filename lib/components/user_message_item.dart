import 'package:flutter/material.dart';

import 'package:sendbirdsdk/sendbirdsdk.dart';
import 'package:sendbird_flutter/styles/color.dart';
import 'message_item.dart';

class UserMessageItem extends MessageItem {
  UserMessageItem({
    UserMessage curr,
    BaseMessage prev,
    BaseMessage next,
    bool isMyMessage,
  }) : super(
          curr: curr,
          prev: prev,
          next: next,
          isMyMessage: isMyMessage,
        );

  @override
  Widget get content => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isMyMessage ? SBColors.primary_300 : SBColors.background_100,
        ),
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Text(
          curr.message,
          style: TextStyle(
            fontSize: 15,
            color: isMyMessage ? SBColors.ondark_01 : SBColors.onlight_01,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return super.build(context);
  }
}

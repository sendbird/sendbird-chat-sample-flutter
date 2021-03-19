import 'package:flutter/material.dart';
import 'package:sendbird_flutter/styles/text_style.dart';
import 'message_item.dart';
import 'package:sendbirdsdk/sendbirdsdk.dart';

class AdminMessageItem extends MessageItem {
  AdminMessageItem({AdminMessage curr}) : super(curr: curr);

  @override
  Widget get content => Container(
        child: Text(
          curr.message,
          style: TextStyles.sendbirdCaption2OnLight2,
        ),
      );
}

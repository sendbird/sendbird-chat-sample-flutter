import 'package:flutter/material.dart';
import 'package:sendbird_flutter/screens/channel/channel_view_model.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';
import 'package:sendbird_flutter/screens/channel/components/message_item.dart';
import 'package:sendbird_flutter/styles/text_style.dart';

class AdminMessageItem extends MessageItem {
  AdminMessageItem({
    required AdminMessage curr,
    required ChannelViewModel model,
  }) : super(curr: curr, model: model);

  @override
  Widget get content => Container(
        child: Text(
          curr.message,
          style: TextStyles.sendbirdCaption2OnLight2,
        ),
      );
}

import 'package:flutter/material.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';

import 'package:sendbird_flutter/styles/text_style.dart';

const groupChannelDefaultName = 'Group Channel';

class ChannelTitleTextView extends StatelessWidget {
  final GroupChannel channel;
  final String? currentUserId;

  ChannelTitleTextView(this.channel, this.currentUserId);

  @override
  Widget build(BuildContext context) {
    String titleText;
    if (channel.name == '' || channel.name == groupChannelDefaultName) {
      List<String> namesList = [
        for (final member in channel.members)
          if (member.userId != currentUserId) member.nickname
      ];
      titleText = namesList.join(", ");
    } else {
      titleText = channel.name ?? 'Channel';
    }
    //if channel members == 2 show last seen / online
    //otherwise just text
    return Text(
      titleText,
      maxLines: 1,
      style: TextStyles.sendbirdSubtitle1OnLight1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

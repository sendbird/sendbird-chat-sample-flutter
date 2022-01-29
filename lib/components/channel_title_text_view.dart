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
    return Row(
      children: [
        Container(
          height: 10,
          width: 10,
          margin: EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            color: connectionStatus,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        Text(
          titleText,
          maxLines: 1,
          style: TextStyles.sendbirdSubtitle1OnLight1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Color get connectionStatus {
    var _countOnline = channel.members
        .where(
          (member) => member.connectionStatus == UserConnectionStatus.online,
        )
        .toList();
    return (_countOnline.length > 1) ? Colors.green : Colors.grey;
  }
}

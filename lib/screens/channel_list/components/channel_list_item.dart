import 'package:flutter/material.dart';

import 'package:sendbird_flutter/components/avatar_view.dart';
import 'package:sendbird_flutter/components/channel_title_text_view.dart';
import 'package:sendbird_flutter/main.dart';
import 'package:sendbird_flutter/styles/color.dart';
import 'package:sendbird_flutter/styles/text_style.dart';
import 'package:sendbird_flutter/utils/extensions.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';

class ChannelListItem extends StatelessWidget {
  final GroupChannel channel;
  final currentUserId = sendbird.currentUser?.userId;

  ChannelListItem(this.channel);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          AvatarView(
            channel: this.channel,
            currentUserId: currentUserId,
            width: 56,
            height: 56,
          ),
          _buildContent(context),
          _buildTailing(context),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    BaseMessage? lastMessage = channel.lastMessage;
    String message;
    if (lastMessage is FileMessage) {
      message = lastMessage.name ?? '';
    } else {
      message = lastMessage?.message ?? '';
    }

    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ChannelTitleTextView(this.channel, currentUserId),
            SizedBox(height: 2),
            Text(
              message,
              maxLines: 2,
              style: TextStyles.sendbirdBody2OnLight3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTailing(BuildContext context) {
    int lastDate = channel.lastMessage?.createdAt ?? 0;
    String lastMessageDateString = lastDate.readableTimestamp();
    final count = channel.unreadMessageCount <= 99
        ? '${channel.unreadMessageCount}'
        : '99+';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          lastMessageDateString,
          style: TextStyles.sendbirdCaption2OnLight2,
        ),
        SizedBox(height: 10),
        if (channel.unreadMessageCount != 0)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: SBColors.primary_300,
            ),
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Text(
              "$count",
              style: TextStyles.sendbirdCaption1OnDark1,
            ),
          ),
      ],
    );
  }
}

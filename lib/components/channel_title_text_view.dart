import 'package:flutter/material.dart';
import 'package:sendbird_flutter/styles/text_style.dart';
import 'package:sendbirdsdk/sendbirdsdk.dart';

class ChannelTitleTextView extends StatelessWidget {
  final GroupChannel channel;
  final String currentUserId;

  ChannelTitleTextView(this.channel, this.currentUserId);

  @override
  Widget build(BuildContext context) {
    List<String> namesList = [
      for (final member in channel.members)
        if (member.userId != currentUserId) member.nickname
    ];
    final titleText = namesList.join(", ");
    return Text(
      titleText,
      style: TextStyles.sendbirdSubtitle1OnLight1,
    );
  }
}

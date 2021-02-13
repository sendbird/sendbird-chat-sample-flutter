import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sendbird_flutter/components/avatar_view.dart';
import 'package:sendbird_flutter/components/channel_title_text_view.dart';

import 'package:sendbirdsdk/sendbirdsdk.dart';

class ChannelListItem extends StatelessWidget {
  final GroupChannel channel;
  final currentUserId = SendbirdSdk().getCurrentUser()?.userId;

  ChannelListItem(this.channel);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: AvatarView(
        channel: this.channel,
        currentUserId: currentUserId,
        width: 40,
        height: 40,
      ),
      tileColor: Colors.white,
      title: ChannelTitleTextView(this.channel, currentUserId),
      subtitle: Text(channel?.lastMessage?.message ?? ''),
      trailing: _buildTailing(context),
    );
  }

  Widget _buildTailing(BuildContext context) {
    DateTime lastMessageDate = DateTime.fromMillisecondsSinceEpoch(
        channel?.lastMessage?.createdAt ?? 0);
    String lastMessageDateString = DateFormat("E").format(lastMessageDate);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(lastMessageDateString),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 20, maxWidth: 40),
          child: TextField(
            textAlign: TextAlign.center,
            enabled: false,
            enableInteractiveSelection: false,
            decoration: channel.unreadMessageCount == 0
                ? null
                : new InputDecoration(
                    border: new OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(20.0),
                      ),
                    ),
                    filled: true,
                    hintStyle: new TextStyle(color: Colors.white, fontSize: 8),
                    hintText: "${channel.unreadMessageCount}",
                    fillColor: Theme.of(context).primaryColor),
          ),
        ),
      ],
    );
  }
}

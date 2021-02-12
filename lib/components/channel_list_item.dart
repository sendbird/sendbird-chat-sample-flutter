import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:sendbirdsdk/sendbirdsdk.dart';

class ChannelListItem extends StatelessWidget {
  final GroupChannel channel;
  final currentUser = SendbirdSdk().getCurrentUser();

  ChannelListItem(this.channel);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _buildAvatars(),
      tileColor: Colors.white,
      title: _buildTitle(),
      subtitle: Text(channel?.lastMessage?.message ?? ''),
      trailing: _buildTailing(context),
    );
  }

  Widget _buildTitle() {
    List<String> namesList = [
      for (final member in channel.members)
        if (member.userId != currentUser.userId) member.nickname
    ];
    final titleText = namesList.join(", ");
    return Text(
      titleText,
      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildAvatars() {
    // Generate a channel image from avatars of users, excluding current user
    int crossAxisCount = 1;
    if (channel.memberCount > 3) {
      crossAxisCount = 2;
    } else {
      (channel.memberCount / 2).round();
    }
    return Container(
      width: 40,
      height: 40,
      child: RawMaterialButton(
        shape: CircleBorder(),
        clipBehavior: Clip.hardEdge,
        onPressed: () {},
        child: GridView.count(crossAxisCount: crossAxisCount, children: [
          for (final member in channel.members)
            if (member.userId != currentUser.userId &&
                member.profileUrl.isNotEmpty)
              Image(
                image: NetworkImage(member.profileUrl),
                fit: BoxFit.cover,
              )
        ]),
      ),
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

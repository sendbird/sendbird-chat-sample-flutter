import 'package:flutter/material.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';

class AvatarView extends StatelessWidget {
  final GroupChannel? channel;
  final User? user;
  final String? currentUserId;
  final double width;
  final double height;
  final Function()? onPressed;

  AvatarView({
    this.channel,
    this.user,
    this.currentUserId,
    this.width = 40,
    this.height = 40,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Generate a channel image from avatars of users, excluding current user
    int crossAxisCount = 1;

    var images = <Widget>[];
    if (channel != null) {
      if (channel!.memberCount >= 3) {
        crossAxisCount = 2;
      }

      images = [
        for (final member in channel!.members)
          if (member.userId != currentUserId && member.profileUrl != '')
            Image(image: NetworkImage(member.profileUrl!), fit: BoxFit.cover)
      ];
    } else if (user != null) {
      if (user?.profileUrl != '')
        images = [
          Image(image: NetworkImage(user!.profileUrl!), fit: BoxFit.cover)
        ];
      else
        images = [Image(image: AssetImage('assets/iconAvatarLight@3x.png'))];
    }

    return Container(
      width: width,
      height: height,
      child: RawMaterialButton(
        shape: CircleBorder(),
        clipBehavior: Clip.hardEdge,
        onPressed: onPressed,
        child: GridView.count(
          crossAxisCount: crossAxisCount,
          children: images,
        ),
      ),
    );
  }
}

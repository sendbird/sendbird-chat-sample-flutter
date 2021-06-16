import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sendbird_flutter/components/avatar_view.dart';
import 'package:sendbird_flutter/styles/color.dart';
import 'package:sendbird_flutter/styles/text_style.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';

class ProfileModal {
  final BuildContext ctx;
  final User user;

  ProfileModal({required this.ctx, required this.user});

  Future<bool> show() {
    final wait = Completer<bool>();

    showModalBottomSheet<bool>(
      context: ctx,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.0),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: UserProfile(
            sender: user,
            onPressedMessage: (userId) {
              Navigator.pop(ctx, true);
            },
          ),
        );
      },
    ).then((isManuallyHidden) {
      wait.complete(isManuallyHidden ?? false);
    });

    return wait.future;
  }
}

class UserProfile extends StatelessWidget {
  final User sender;
  final Function(String)? onPressedMessage;

  UserProfile({required this.sender, this.onPressedMessage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 32, 16, 7),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AvatarView(user: sender, width: 80, height: 80),
          SizedBox(height: 8),
          Text(
            sender.nickname,
            style: TextStyle(
              color: SBColors.onlight_01,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
              fontStyle: FontStyle.normal,
              fontSize: 18.0,
            ),
          ),
          SizedBox(height: 16),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: TextButton(
                      child: Text(
                        'Message',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onPressed: () => onPressedMessage != null
                          ? onPressedMessage!(sender.userId)
                          : null),
                )
              ],
            ),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 1),
              borderRadius: BorderRadius.circular(4.0),
            ),
          ),
          SizedBox(height: 24.5),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 0.5),
          ),
          SizedBox(height: 24.5),
          Row(children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User ID',
                  style: TextStyle(
                    color: SBColors.onlight_02,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Roboto',
                    fontStyle: FontStyle.normal,
                    fontSize: 14.0,
                  ),
                ),
                Text(
                  sender.userId,
                  style: TextStyles.sendbirdBody1OnLight1,
                ),
              ],
            )
          ])
        ],
      ),
    );
  }
}

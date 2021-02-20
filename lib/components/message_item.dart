import 'package:flutter/material.dart';
import 'package:sendbird_flutter/components/avatar_view.dart';
import 'package:sendbirdsdk/sendbirdsdk.dart';
import '../utils/extensions.dart';

class MessageItem extends StatelessWidget {
  final UserMessage message;
  final bool isMyMessage;

  MessageItem({this.message, this.isMyMessage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 14, right: 14, top: 10, bottom: 10),
      child: Align(
        alignment: (!isMyMessage ? Alignment.topLeft : Alignment.topRight),
        child:
            isMyMessage ? _myMessageView(message) : _otherMessageView(message),
      ),
    );
  }

  Widget _myMessageView(BaseMessage message) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: (!isMyMessage ? Colors.grey.shade200 : Colors.blue[200]),
      ),
      padding: EdgeInsets.all(16),
      child: Text(
        message.message,
        style: TextStyle(fontSize: 15),
      ),
    );
  }

  Widget _otherMessageView(BaseMessage message) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AvatarView(user: message.sender, width: 20, height: 20),
        SizedBox(width: 10),
        Column(
          children: [
            Text(message.sender.nickname),
            SizedBox(height: 5),
            Container(
              //username, profile, timestamp
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: (!isMyMessage ? Colors.grey.shade200 : Colors.blue[200]),
              ),
              padding: EdgeInsets.all(16),
              child: Text(
                message.message,
                style: TextStyle(fontSize: 15),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

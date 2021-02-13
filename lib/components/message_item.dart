import 'package:flutter/material.dart';
import 'package:sendbirdsdk/sendbirdsdk.dart';

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
        child: isMyMessage
            ? Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color:
                      (!isMyMessage ? Colors.grey.shade200 : Colors.blue[200]),
                ),
                padding: EdgeInsets.all(16),
                child: Text(
                  message.message,
                  style: TextStyle(fontSize: 15),
                ),
              )
            : Container(
                //username, profile, timestamp
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color:
                      (!isMyMessage ? Colors.grey.shade200 : Colors.blue[200]),
                ),
                padding: EdgeInsets.all(16),
                child: Text(
                  message.message,
                  style: TextStyle(fontSize: 15),
                ),
              ),
      ),
    );
  }
}

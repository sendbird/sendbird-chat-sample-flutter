import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sendbird_flutter/components/avatar_view.dart';
import 'package:sendbirdsdk/sendbirdsdk.dart';

class FileMessageItem extends StatelessWidget {
  final FileMessage message;
  final File file;
  final bool isMyMessage;
  final double progress;

  FileMessageItem({
    this.message,
    this.file,
    this.isMyMessage,
    this.progress,
  });

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

  Widget _myMessageView(FileMessage message) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: (!isMyMessage ? Colors.grey.shade200 : Colors.blue[200]),
      ),
      padding: EdgeInsets.all(4),
      child: Container(
          height: 120.0,
          width: 120.0,
          child: message.localFile != null
              ? FittedBox(
                  child: Image.file(message.localFile),
                  fit: BoxFit.cover,
                )
              : CachedNetworkImage(
                  //https://github.com/flutter/flutter/issues/25107
                  fit: BoxFit.cover,
                  imageUrl: message.secureUrl ?? message.url,
                  placeholder: (context, url) => message.localFile != null
                      ? Image.file(message.localFile)
                      : CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                )),
    );
  }

  Widget _otherMessageView(FileMessage message) {
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
            if (message.sendingStatus == MessageSendingStatus.succeeded)
              Container(
                  height: 120.0,
                  width: 120.0,
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl: message.secureUrl ?? message.url,
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  )),
            if (message.sendingStatus == MessageSendingStatus.pending)
              Container(
                height: 120.0,
                width: 120.0,
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ],
    );
  }
}

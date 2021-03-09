import 'package:flutter/material.dart';
import 'package:sendbird_flutter/components/message_item.dart';
import 'package:sendbirdsdk/sendbirdsdk.dart';

class AdminMessageItem extends MessageItem {
  AdminMessageItem({AdminMessage curr}) : super(curr: curr);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(curr.message),
    );
  }
}

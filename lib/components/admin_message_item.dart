import 'package:flutter/material.dart';
import 'package:sendbirdsdk/sendbirdsdk.dart';

class AdminMessageItem extends StatelessWidget {
  final AdminMessage message;

  AdminMessageItem(this.message);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(message.message),
    );
  }
}

import 'package:flutter/material.dart';

AppBar appBarComponent({
  String? title,
  bool includeLeading = true,
  List<Widget>? actions,
}) {
  return AppBar(
    centerTitle: false,
    leading: includeLeading
        ? SizedBox.square(
            dimension: 30,
            child: Image.asset(
              'assets/logo/SendbirdLogo.png',
            ),
          )
        : null,
    actions: actions,
    title: Text(
      title ?? 'Sendbird Example',
      style: const TextStyle(color: Colors.white),
    ),
  );
}

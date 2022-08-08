import 'package:flutter/material.dart';

Padding paddingComponent(
    {required Widget widget, double horizontalPadding = 20}) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
    child: widget,
  );
}

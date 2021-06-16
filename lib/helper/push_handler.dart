import 'package:flutter/material.dart';
import 'package:sendbird_flutter/main.dart';

enum PopType {
  pop,
  replace,
  popUntil,
}

abstract class PushHandler {
  void screenBecomeVisible(bool visible, {PopType pop = PopType.pop}) {
    if (appState.destChannelUrl != null && visible) {
      if (pop == PopType.replace)
        navigatorKey.currentState?.pushReplacementNamed(
          '/channel',
          arguments: appState.destChannelUrl,
        );
      else if (pop == PopType.pop)
        navigatorKey.currentState?.popAndPushNamed(
          '/channel',
          arguments: appState.destChannelUrl,
        );
      else if (pop == PopType.popUntil)
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/channel',
          ModalRoute.withName('/channel_list'),
          arguments: appState.destChannelUrl,
        );
      else
        navigatorKey.currentState?.pushNamed(
          '/channel',
          arguments: appState.destChannelUrl,
        );
      appState.setDestination(null);
    }
  }
}

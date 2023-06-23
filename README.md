# [Sendbird](https://sendbird.com) Chat Sample for Flutter

[![Platform](https://img.shields.io/badge/platform-flutter-blue)](https://flutter.dev/)
[![Language](https://img.shields.io/badge/language-dart-blue)](https://dart.dev/)

## Introduction

This sample demonstrates how you can use the [Sendbird Chat SDK for Flutter](https://github.com/sendbird/sendbird-chat-sdk-flutter) in your own Flutter application.

## Requirements

The minimum requirements for the Chat SDK for Flutter are:
- Dart 2.19.0 or later
- Flutter 3.7.0 or later

## Sample page links

- [LoginPage](https://github.com/sendbird/sendbird-chat-sample-flutter/blob/master/lib/page/login_page.dart)
- [GroupChannelListPage](https://github.com/sendbird/sendbird-chat-sample-flutter/blob/master/lib/page/channel/group_channel/group_channel_list_page.dart)
- [GroupChannelPage](https://github.com/sendbird/sendbird-chat-sample-flutter/blob/master/lib/page/channel/group_channel/group_channel_page.dart)
- [OpenChannelListPage](https://github.com/sendbird/sendbird-chat-sample-flutter/blob/master/lib/page/channel/open_channel/open_channel_list_page.dart)
- [OpenChannelPage](https://github.com/sendbird/sendbird-chat-sample-flutter/blob/master/lib/page/channel/open_channel/open_channel_page.dart)
- [UserPage](https://github.com/sendbird/sendbird-chat-sample-flutter/blob/master/lib/page/user/user_page.dart)

## 🔒 Security tip

When a new Sendbird application is created in the [dashboard](https://dashboard.sendbird.com) the default security settings are set permissive to simplify running samples and implementing your first code.

Before launching make sure to review the security tab under ⚙️ Settings -> Security, and set Access token permission to Read Only or Disabled so that unauthenticated users can not login as someone else. And review the Access Control lists. Most apps will want to disable "Allow retrieving user list" as that could expose usage numbers and other information.

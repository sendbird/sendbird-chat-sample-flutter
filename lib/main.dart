// Copyright (c) 2023 Sendbird, Inc. All rights reserved.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:sendbird_chat_sample/notifications/local_notifications_manager.dart';
import 'package:sendbird_chat_sample/notifications/push_manager.dart';
import 'package:sendbird_chat_sample/page/channel/feed_channel/feed_channel_list_page.dart';
import 'package:sendbird_chat_sample/page/channel/feed_channel/feed_channel_page.dart';
import 'package:sendbird_chat_sample/page/channel/group_channel/group_channel_create_page.dart';
import 'package:sendbird_chat_sample/page/channel/group_channel/group_channel_invite_page.dart';
import 'package:sendbird_chat_sample/page/channel/group_channel/group_channel_list_page.dart';
import 'package:sendbird_chat_sample/page/channel/group_channel/group_channel_page.dart';
import 'package:sendbird_chat_sample/page/channel/group_channel/group_channel_search_page.dart';
import 'package:sendbird_chat_sample/page/channel/group_channel/group_channel_send_file_message_page.dart';
import 'package:sendbird_chat_sample/page/channel/group_channel/group_channel_update_page.dart';
import 'package:sendbird_chat_sample/page/channel/open_channel/open_channel_create_page.dart';
import 'package:sendbird_chat_sample/page/channel/open_channel/open_channel_list_page.dart';
import 'package:sendbird_chat_sample/page/channel/open_channel/open_channel_page.dart';
import 'package:sendbird_chat_sample/page/channel/open_channel/open_channel_search_page.dart';
import 'package:sendbird_chat_sample/page/channel/open_channel/open_channel_update_page.dart';
import 'package:sendbird_chat_sample/page/login_page.dart';
import 'package:sendbird_chat_sample/page/main_page.dart';
import 'package:sendbird_chat_sample/page/message/message_update_page.dart';
import 'package:sendbird_chat_sample/page/user/user_nickname_update_page.dart';
import 'package:sendbird_chat_sample/page/user/user_page.dart';
import 'package:sendbird_chat_sample/page/user/user_profile_update_page.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';

const sampleVersion = '4.1.0';
const yourAppId = '728E8736-5D0C-47CE-B934-E39B656900F3';

void main() {
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      FlutterError.onError = (errorDetails) {
        debugPrint('[FlutterError] ${errorDetails.stack}');
        Fluttertoast.showToast(
          msg: '[FlutterError] ${errorDetails.stack}',
          gravity: ToastGravity.CENTER,
          toastLength: Toast.LENGTH_SHORT,
        );
      };

      await PushManager.initialize();
      await LocalNotificationsManager.initialize();

      runApp(MyApp());
    },
    (error, stackTrace) async {
      debugPrint('[Error] $error\n$stackTrace');
      Fluttertoast.showToast(
        msg: '[Error] $error',
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_SHORT,
      );
    },
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key}) {
    SendbirdChat.init(appId: yourAppId);
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sendbird Chat Sample',
      theme: ThemeData(
        primarySwatch: _createMaterialColor(
          const Color.fromARGB(196, 90, 24, 196),
        ),
      ),
      builder: (context, child) {
        return ScrollConfiguration(behavior: _AppBehavior(), child: child!);
      },
      initialRoute: '/login',
      getPages: [
        GetPage(
          name: '/login',
          page: () => const LoginPage(),
        ),
        GetPage(
          name: '/main',
          page: () => const MainPage(),
        ),
        GetPage(
          name: '/user',
          page: () => const UserPage(),
        ),
        GetPage(
          name: '/user/update/profile',
          page: () => const UserProfileUpdatePage(),
        ),
        GetPage(
          name: '/user/update/nickname',
          page: () => const UserNicknameUpdatePage(),
        ),
        GetPage(
          name: '/group_channel/list',
          page: () => const GroupChannelListPage(),
        ),
        GetPage(
          name: '/group_channel/search',
          page: () => const GroupChannelSearchPage(),
        ),
        GetPage(
          name: '/group_channel/create',
          page: () => const GroupChannelCreatePage(),
        ),
        GetPage(
          name: '/group_channel/update/:channel_url',
          page: () => const GroupChannelUpdatePage(),
        ),
        GetPage(
          name: '/group_channel/invite/:channel_url',
          page: () => const GroupChannelInvitePage(),
        ),
        GetPage(
          name: '/group_channel/:channel_url',
          page: () => const GroupChannelPage(),
        ),
        GetPage(
          name: '/group_channel/send_file_message/:channel_url',
          page: () => const GroupChannelSendFileMessagePage(),
        ),
        GetPage(
          name: '/open_channel/list',
          page: () => const OpenChannelListPage(),
        ),
        GetPage(
          name: '/open_channel/search',
          page: () => const OpenChannelSearchPage(),
        ),
        GetPage(
          name: '/open_channel/create',
          page: () => const OpenChannelCreatePage(),
        ),
        GetPage(
          name: '/open_channel/update/:channel_url',
          page: () => const OpenChannelUpdatePage(),
        ),
        GetPage(
          name: '/open_channel/:channel_url',
          page: () => const OpenChannelPage(),
        ),
        GetPage(
          name: '/message/update/:channel_type/:channel_url/:message_id',
          page: () => const MessageUpdatePage(),
        ),
        GetPage(
          name: '/feed_channel/list',
          page: () => const FeedChannelListPage(),
        ),
        GetPage(
          name: '/feed_channel/:channel_url',
          page: () => const FeedChannelPage(),
        ),
      ],
    );
  }

  MaterialColor _createMaterialColor(Color color) {
    final int r = color.red, g = color.green, b = color.blue;
    final strengths = <double>[.05];
    final Map<int, Color> swatch = {};

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }

    for (final strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}

class _AppBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

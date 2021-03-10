import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sendbird_flutter/screens/channel_list_screen.dart';
import 'package:sendbird_flutter/styles/color.dart';
import 'screens/create_channel_screen.dart';
import 'screens/login_screen.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)..maxConnectionsPerHost = 10;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  String initialRoute() {
    // TODO: Switch initial view between login or channel list, depending on prior
    // login state.
    return "/login";
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      initialRoute: initialRoute(),
      routes: <String, WidgetBuilder>{
        '/login': (context) => LoginScreen(),
        '/channel_list': (context) => ChannelListScreen(),
        '/create_channel': (context) => CreateChannelScreen(),
      },
      theme: ThemeData(
        fontFamily: "Gellix",
        primaryColor: Color(0xff742DDD),
        buttonColor: Color(0xff742DDD),
        accentColor: SBColors.primary_300,
        textTheme: TextTheme(
            headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
            headline6: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold)),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Color(0xff732cdd),
          selectionHandleColor: Color(0xff732cdd),
          selectionColor: Color(0xffD1BAF4),
        ),
      ),
    );
  }
}

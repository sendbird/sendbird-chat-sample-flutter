import 'dart:io';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_apns/flutter_apns.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sendbird_flutter/screens/channel/channel_screen.dart';
import 'package:sendbird_flutter/screens/channel_info/channel_info_screen.dart';
import 'package:sendbird_flutter/screens/channel_list/channel_list_screen.dart';
import 'package:sendbird_flutter/screens/create_channel/create_channel_screen.dart';
import 'package:sendbird_flutter/screens/login/login_screen.dart';
import 'package:sendbird_flutter/styles/color.dart';
import 'package:sendbird_flutter/utils/notification_service.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..maxConnectionsPerHost = 10;
  }
}

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();
final sendbird = SendbirdSdk(appId: 'FF6E181B-6325-4A32-AA6D-B1ADA6BAEE95');
//* If web Do not create push connector
final connector = kIsWeb ? null : createPushConnector();

final appState = AppState();

class AppState with ChangeNotifier {
  bool didRegisterToken = false;
  String? token;
  String? destChannelUrl;

  void setDestination(String? channelUrl) {
    destChannelUrl = channelUrl;
    notifyListeners();
  }
}

const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    'This channel is used for important notifications.', // description
    importance: Importance.high,
    playSound: true);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  HttpOverrides.global = MyHttpOverrides();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  //* If web do not create push Connector
  final PushConnector? connector = kIsWeb ? null : createPushConnector();

  Future<void> _register() async {
    //if it is not web: connector will exist
    final connector = this.connector!;
    connector.configure(
      onLaunch: (data) async {
        //launch
        print('onLaunch: $data');
        final rawData = data.data;
        appState.setDestination(rawData['sendbird']['channel']['channel_url']);
      },
      onResume: (data) async {
        //called when user tap on push notification
        final rawData = data.data;
        appState.setDestination(rawData['sendbird']['channel']['channel_url']);

        //? Android Notification
        RemoteNotification? notification = data.notification;
        AndroidNotification? android = data.notification?.android;
        if (notification != null && android != null) {
          showDialog(
              context: context,
              builder: (_) {
                return AlertDialog(
                  title: Text(notification.title ?? 'Alert'),
                  content: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [Text(notification.body ?? 'empty body')],
                    ),
                  ),
                );
              });
        }
      },
      onMessage: (RemoteMessage data) async {
        //terminated? background
        print('onMessage: $data');

        //? Android Notification
        RemoteNotification? notification = data.notification;
        AndroidNotification? android = data.notification?.android;

        var value = data.data['sendbird'];
        var body = jsonDecode(value);

        await flutterLocalNotificationsPlugin.show(
            DateTime.now().second,
            body['push_title'] ?? 'EMPTY',
            body['message'],
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channel.description,
                color: Colors.blue,
                playSound: true,
                icon: '@mipmap/ic_launcher',
              ),
            ));
        // }
      },
      onBackgroundMessage: handleBackgroundMessage,
    );
    connector.token.addListener(() {
      print('Token ${connector.token.value}');
      appState.token = connector.token.value;
    });
    connector.requestNotificationPermissions();

    if (Platform.isAndroid) {
      /// Android
      FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  @override
  void initState() {
    //* If web do not register
    if (kIsWeb == false) {
      _register();
    }

    super.initState();
  }

  String initialRoute() {
    // TODO: Switch initial view between login or channel list, depending on prior
    // login state.
    return "/";
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      initialRoute: initialRoute(),
      navigatorKey: navigatorKey,
      onGenerateRoute: (settings) {
        var routes = <String, WidgetBuilder>{
          '/': (context) => LoginScreen(),
          '/channel_list': (context) => ChannelListScreen(),
          '/create_channel': (context) => CreateChannelScreen(),
          '/channel_info': (context) =>
              ChannelInfoScreen(channel: settings.arguments as GroupChannel),
          '/channel': (context) =>
              ChannelScreen(channelUrl: settings.arguments as String),
        };
        WidgetBuilder builder = routes[settings.name]!;
        return MaterialPageRoute(
          settings: settings,
          builder: (ctx) => builder(ctx),
        );
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

Future<dynamic> handleBackgroundMessage(RemoteMessage data) async {
  print('onBackground $data'); // android only for firebase_messaging v7

  var messageBody = data.data['message'];

  NotificationService.showNotification(
    'Sendbird Example',
    messageBody,
    payload: data.data['sendbird'],
  );
}

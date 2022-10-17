import 'dart:convert';
import 'dart:io';

import 'package:app/main_binding.dart';
import 'package:app/routes.dart';
import 'package:app/util/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_apns/apns.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  return runApp(const MyApp());
}

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

//Creates correct type of push connector based on device (IOS, Android)
final connector = kIsWeb ? null : createPushConnector();

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  description:
      'This channel is used for important notifications.', // description
  importance: Importance.high,
  playSound: true,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  final PushConnector? connector = kIsWeb ? null : createPushConnector();

  Future<void> _registerNotification() async {
    print('registering nofication...');
    connector?.configure(
      onLaunch: (message) async {
        print('launch');
        //launch
        print('onLaunch: $message');
        final rawData = message.data;
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
        print('OnMessage: ');
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
                channelDescription: channel.description,
                color: Colors.blue,
                playSound: true,
                icon: '@mipmap/ic_launcher',
              ),
            ));
        // }
      },
      onBackgroundMessage: handleBackgroundMessage,
    );
    connector?.token.addListener(() async {
      print('Token ${connector?.token.value}');
      appState.token = connector?.token.value;
    });
    connector?.requestNotificationPermissions();

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
    if (kIsWeb == false) {
      _registerNotification();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sendbird Example',
      initialRoute: "MainRoute",
      getPages: routes,
      initialBinding: MainBinding(),
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

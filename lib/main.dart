import 'package:sendbird_sdk/utils/logger.dart';
import 'package:universal_io/io.dart';

import 'package:app/color.dart';
import 'package:app/main_binding.dart';
import 'package:app/routes.dart';
import 'package:app/util/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import 'components/push_notification.dart';

Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling background message: ${message.messageId}");

  NotificationService.showNotification(
    message.notification?.title ?? '',
    message.notification?.body ?? '',
  );
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  logger.i("notification tapped", response);
  print("notification tapped");
  Get.toNamed("EmptyRoute");
}

void onRecieveLocalNotification(
    int i, String? one, String? two, String? three) {
  logger.i("notification tapped");
  print("notification tapped");
  Get.toNamed("EmptyRoute");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

  final DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
    onDidReceiveLocalNotification: onRecieveLocalNotification,
  );

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse:
        (NotificationResponse notificationResponse) async {
      print("Notification Recieved with flutterLocalNotificationsPlugin");
    },
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );

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

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  description:
      'This channel is used for important notifications.', // description
  importance: Importance.high,
  playSound: true,
);

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  int _totalNotifications = 0;
  late final FirebaseMessaging _messaging;
  PushNotification? _notificationInfo;

  // [Push Notification Set Up]
  void requestAndRegisterNotification() async {
    // Instantiate Firebase Messaging
    _messaging = FirebaseMessaging.instance;
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // To enable foreground notification in firebase messaging for IOS
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );

    // On iOS, this helps to take the user permissions
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      String? token;

      if (Platform.isIOS) {
        //Retrieve pushtoken for IOS
        token = await _messaging.getAPNSToken();
      } else {
        // Retrieve pushtoken for FCM
        token = await _messaging.getToken();
      }

      appState.token = token;
      // For handling the received notifications
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('title: ${message.notification?.title}');
        print('body: ${message.notification?.body}');
        // Parse the message received
        PushNotification notification = PushNotification(
          title: message.notification?.title,
          body: message.notification?.body,
        );

        setState(() {
          _notificationInfo = notification;
          _totalNotifications++;
        });
        if (_notificationInfo != null) {
          NotificationService.showNotification(
              _notificationInfo?.title ?? '', _notificationInfo?.body ?? '');
        }
      });
    } else {
      print('User declined or has not accepted permission');
    }
  }

  @override
  void initState() {
    requestAndRegisterNotification();
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      PushNotification notification = PushNotification(
        title: message.notification?.title,
        body: message.notification?.body,
      );
      setState(() {
        _notificationInfo = notification;
        _totalNotifications++;
      });
    });
    _totalNotifications = 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        primaryColor: sendbirdColor,
      ),
      debugShowCheckedModeBanner: false,
      title: 'Sendbird Example',
      initialRoute: "MainRoute",
      getPages: routes,
      initialBinding: MainBinding(),
    );
  }
}

import UIKit
import Flutter
import Firebase // for [firebase_messaging]
import flutter_local_notifications // for [flutter_local_notifications]

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // When the system notification is tapped, after app is terminated.
    let userInfo = (launchOptions?[.remoteNotification] as? [String: Any])
    if (userInfo != nil) {
      print("[application:didFinishLaunchingWithOptions][The system notification is tapped.]")
//       print(userInfo)
    } else {
      print("[application:didFinishLaunchingWithOptions]")
    }

    /* // for PushNotifications
    //+ for [flutter_local_notifications]
    // This is required to make any communication available in the action isolate.
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
      GeneratedPluginRegistrant.register(with: registry)
    }

    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
    //- for [flutter_local_notifications]

    FirebaseApp.configure() // for [firebase_messaging]
    */

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(
    _ application: UIApplication,
    didReceiveRemoteNotification userInfo: [AnyHashable : Any],
    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
  ) {
    // When the system notification is tapped, after app is terminated.
    print("[application:didReceiveRemoteNotification]")
//     print(userInfo)
    completionHandler(.newData)
  }

  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    // When the system notification is received on foreground.
    print("[userNotificationCenter:willPresent]")
//     let userInfo = notification.request.content.userInfo
//     print(userInfo)
    completionHandler([.alert, .sound])
  }

  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    // When the system notification is tapped or dismissed on foreground or background.
    if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
      print("[userNotificationCenter:didReceive][The system notification is tapped.]")
    } else if response.actionIdentifier == UNNotificationDismissActionIdentifier {
      print("[userNotificationCenter:didReceive][The system notification is dismissed.]")
    }
//     let userInfo = response.notification.request.content.userInfo
//     print(userInfo)
    completionHandler()
  }
}

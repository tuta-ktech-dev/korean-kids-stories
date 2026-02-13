import Flutter
import UIKit
import UserNotifications
import workmanager

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Notifications: allow display when app is in foreground
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }

    // WorkManager: register periodic task for reading reminder (iOS 13+)
    if #available(iOS 13.0, *) {
      WorkmanagerPlugin.registerPeriodicTask(
        withIdentifier: "com.hbstore.koreankids.reading_reminder",
        frequency: NSNumber(value: 60 * 60) // 1 hour in seconds
      )
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

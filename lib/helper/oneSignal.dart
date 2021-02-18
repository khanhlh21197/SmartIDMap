import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'constants.dart' as Constants;

class OneSignalHelper{
  Future<void> init() async{
    //Remove this method to stop OneSignal Debugging
    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

    OneSignal.shared.init(
        Constants.one_signal_app_id,
        iOSSettings: {
          OSiOSSettings.autoPrompt: false,
          OSiOSSettings.inAppLaunchUrl: false
        }
    );
    OneSignal.shared.setInFocusDisplayType(OSNotificationDisplayType.notification);

// The promptForPushNotificationsWithUserResponse function will show the iOS push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
    await OneSignal.shared.promptUserForPushNotificationPermission(fallbackToSettings: true);
  }

  // OneSignal.shared.setNotificationReceivedHandler((OSNotification notification) {
  // // will be called whenever a notification is received
  // });
  //
  // OneSignal.shared.setNotificationOpenedHandler((OSNotificationOpenedResult result) {
  // // will be called whenever a notification is opened/button pressed.
  // });
  //
  // OneSignal.shared.setPermissionObserver((OSPermissionStateChanges changes) {
  // // will be called whenever the permission changes
  // // (ie. user taps Allow on the permission prompt in iOS)
  // });
  //
  // OneSignal.shared.setSubscriptionObserver((OSSubscriptionStateChanges changes) {
  // // will be called whenever the subscription changes
  // //(ie. user gets registered with OneSignal and gets a user ID)
  // });
  //
  // OneSignal.shared.setEmailSubscriptionObserver((OSEmailSubscriptionStateChanges emailChanges) {
  // // will be called whenever then user's email subscription changes
  // // (ie. OneSignal.setEmail(email) is called and the user gets registered
  // });

// For each of the above functions, you can also pass in a
// reference to a function as well:

  void _handleNotificationReceived(OSNotification notification) {

  }

  void main() {
    OneSignal.shared.setNotificationReceivedHandler(_handleNotificationReceived);
  }
}
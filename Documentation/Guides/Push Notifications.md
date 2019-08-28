# Push Notifications

## Setup

### Request Authorisation

Request authorisation for push notifications from the user at an appropriate point in the onboarding journey, for example after login/registration.

```swift
private func registerForPushNotifications() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (success, error) in
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
}
```

### Registering for Notifications

Import the FrolloSDK into your AppDelegate and then add the following line to register the device token for notifications

```swift
import FrolloSDK

func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Frollo.shared.notifications.registerPushNotificationToken(deviceToken)
}
```

### Handling Notifications and Events

In your AppDelegate pass the userInfo received from the remote notification to the SDK by implementing the following method. This deprecated method is required otherwise silent push notifications will not be processed.

```swift
func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    Frollo.shared.notifications.handlePushNotification(userInfo: userInfo)
        
    completionHandler(.newData)
}
```


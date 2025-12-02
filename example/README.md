# flutter_fcm_notifications Example

This example demonstrates how to use the flutter_fcm_notifications plugin.

## Getting Started

### 1. Firebase Setup

Before running the example, you need to set up Firebase:

#### Android
1. Create a Firebase project at https://console.firebase.google.com
2. Add an Android app to your Firebase project
3. Download `google-services.json` and place it in `android/app/`
4. Follow the Firebase setup instructions for Android

#### iOS
1. Add an iOS app to your Firebase project
2. Download `GoogleService-Info.plist` and place it in `ios/Runner/`
3. Enable Push Notifications in Xcode capabilities
4. Follow the Firebase setup instructions for iOS

### 2. Update Firebase Options

Update the `lib/firebase_options.dart` file with your own Firebase project credentials:

```bash
# Install FlutterFire CLI
flutter pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```

### 3. Install Dependencies

```bash
cd example
flutter pub get
```

### 4. Run the App

```bash
flutter run
```

## Features Demonstrated

1. **FCM Token Display**: Shows your device's FCM token for testing
2. **Foreground Notifications**: Receive notifications while app is open
3. **Background Notifications**: Receive notifications when app is in background
4. **Notification Persistence**: All notifications are saved and can be viewed later
5. **Read/Unread Status**: Track which notifications have been read
6. **Beautiful UI**: iOS-inspired notification interface
7. **Dark Mode Support**: Automatic theme switching
8. **Custom Configuration**: Uses English locale and custom colors

## Testing Notifications

### Method 1: Firebase Console

1. Copy the FCM token from the app (tap "Show Token" button)
2. Go to Firebase Console > Cloud Messaging
3. Click "Send your first message"
4. Enter notification title and body
5. Click "Send test message"
6. Paste your FCM token
7. Send the notification

### Method 2: Using cURL

```bash
# Replace YOUR_SERVER_KEY and YOUR_FCM_TOKEN
curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=YOUR_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "YOUR_FCM_TOKEN",
    "notification": {
      "title": "Test Notification",
      "body": "This is a test message"
    },
    "data": {
      "custom_key": "custom_value"
    }
  }'
```

### Method 3: Using Firebase Admin SDK (Node.js)

```javascript
const admin = require('firebase-admin');

await admin.messaging().send({
  token: 'YOUR_FCM_TOKEN',
  notification: {
    title: 'Hello from FCM',
    body: 'This is a test notification',
  },
  data: {
    screen: 'home',
    userId: '123',
  },
});
```

## Code Overview

### Main Entry Point

The app initializes Firebase and sets up FCM listeners in `main()`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  runApp(MyApp());
}
```

### Notification Manager

The example uses `NotificationManager` with Provider for state management:

```dart
ChangeNotifierProvider(
  create: (_) => NotificationManager(
    config: const NotificationConfig.english,
  )..initialize(),
  child: MaterialApp(...),
)
```

### Handling Messages

Foreground messages are handled in the HomePage:

```dart
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  manager.addNotification(message);
  _showNotification(message);
});
```

### Customization

The example demonstrates custom configuration:

```dart
NotificationScreen(
  manager: manager,
  config: const NotificationConfig.english,
)
```

## Platform-Specific Notes

### Android
- Requires minSdkVersion 21 or higher
- Notification channels are automatically created
- POST_NOTIFICATIONS permission is requested automatically (Android 13+)

### iOS
- Requires iOS 12.0 or higher
- Push Notifications capability must be enabled in Xcode
- APNs key must be uploaded to Firebase Console

## Troubleshooting

### Not receiving notifications on Android
1. Check that `google-services.json` is in the correct location
2. Verify that Google Services plugin is applied
3. Check that POST_NOTIFICATIONS permission is granted (Android 13+)

### Not receiving notifications on iOS
1. Verify that Push Notifications capability is enabled
2. Check that APNs key is uploaded to Firebase
3. Test on a real device (not simulator)

### Token is null
1. Ensure Firebase is properly initialized
2. Check that permissions are granted
3. Verify network connectivity

## Learn More

- [Flutter FCM Notifications Plugin Documentation](../README.md)
- [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging)
- [FlutterFire Documentation](https://firebase.flutter.dev/)

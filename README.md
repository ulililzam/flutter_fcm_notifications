# Flutter FCM Notifications

A production-ready Flutter plugin for Firebase Cloud Messaging with beautiful UI and customizable notifications management.

## Features

- Beautiful, iOS-inspired notification UI
- Persistent notification storage using SharedPreferences
- Automatic read/unread status tracking
- Date-grouped notifications (Today, Yesterday, etc.)
- Pull-to-refresh support
- Filter notifications (All/Unread)
- Haptic feedback
- Fully customizable colors, text, and locale
- Dark theme support
- Clean architecture with ChangeNotifier
- Null-safe and production-ready

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_fcm_notifications: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Firebase Setup

### Android

1. Add your `google-services.json` to `android/app/`
2. Update `android/build.gradle`:

```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

3. Update `android/app/build.gradle`:

```gradle
apply plugin: 'com.google.gms.google-services'

android {
    defaultConfig {
        minSdkVersion 21
    }
}
```

4. Add to `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

### iOS

1. Add your `GoogleService-Info.plist` to `ios/Runner/`
2. Enable Push Notifications in Xcode capabilities
3. Add to `ios/Runner/Info.plist`:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
</array>
```

## Usage

### Basic Setup

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_fcm_notifications/flutter_fcm_notifications.dart';
import 'package:provider/provider.dart';

// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Set background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NotificationManager()..initialize(),
      child: MaterialApp(
        title: 'FCM Notifications',
        home: HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _setupFCM();
  }

  Future<void> _setupFCM() async {
    final messaging = FirebaseMessaging.instance;
    final manager = context.read<NotificationManager>();
    
    // Request permission
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    
    // Get FCM token
    final token = await messaging.getToken();
    print('FCM Token: $token');
    
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      manager.addNotification(message);
    });
    
    // Handle message taps
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      manager.addNotification(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          Consumer<NotificationManager>(
            builder: (context, manager, _) {
              return Stack(
                children: [
                  IconButton(
                    icon: Icon(Icons.notifications),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NotificationScreen(
                            manager: manager,
                          ),
                        ),
                      );
                    },
                  ),
                  if (manager.unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${manager.unreadCount}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Text('Send a test notification from Firebase Console'),
      ),
    );
  }
}
```

## Customization

### Custom Configuration

```dart
final customConfig = NotificationConfig(
  primaryColor: Colors.blue,
  backgroundColor: Colors.white,
  locale: 'en_US',
  maxNotifications: 100,
  appBarTitle: 'My Notifications',
  markAllReadText: 'Mark All as Read',
  enableHapticFeedback: true,
  enablePullToRefresh: true,
);

NotificationScreen(
  manager: notificationManager,
  config: customConfig,
)
```

### Predefined Configurations

```dart
// English
NotificationConfig.english

// Indonesian
NotificationConfig.indonesian

// Dark Theme
NotificationConfig.dark

// Custom combination
NotificationConfig.english.copyWith(
  primaryColor: Colors.purple,
  backgroundColor: Colors.black,
)
```

### Customizable Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| primaryColor | Color | Color(0xFF007AFF) | Primary accent color |
| backgroundColor | Color | Color(0xFFF2F2F7) | Screen background |
| cardBackgroundColor | Color | Colors.white | Read notification card |
| unreadCardBackgroundColor | Color | Color(0xFFF8F8F8) | Unread notification card |
| titleTextColor | Color | Colors.black | Notification title |
| bodyTextColor | Color | Color(0xFF6B6B70) | Notification body |
| secondaryTextColor | Color | Color(0xFF8E8E93) | Time and headers |
| unreadIndicatorColor | Color | Color(0xFF007AFF) | Unread dot |
| locale | String | 'id_ID' | Date formatting locale |
| maxNotifications | int | 50 | Maximum stored notifications |
| markAllReadText | String | 'Tandai Sudah Dibaca' | Button text |
| allNotificationsText | String | 'Semua Notifikasi' | Filter option |
| unreadFilterText | String | 'Belum Dibaca' | Filter option |
| noNotificationsTitle | String | 'Tidak Ada Notifikasi' | Empty state title |
| noNotificationsSubtitle | String | 'Notifikasi baru akan muncul di sini' | Empty state subtitle |
| todayLabel | String | 'Hari ini' | Today label |
| yesterdayLabel | String | 'Kemarin' | Yesterday label |
| appBarTitle | String | 'Notifications' | App bar title |
| enableHapticFeedback | bool | true | Haptic feedback on tap |
| enablePullToRefresh | bool | true | Pull to refresh |
| cardBorderRadius | double | 12.0 | Card corner radius |
| emptyStateIcon | IconData | Icons.notifications_active | Empty state icon |

## NotificationManager API

### Properties

```dart
manager.notifications          // List of all notifications
manager.unreadCount           // Number of unread notifications
manager.readStatus            // Map of message IDs to read status
manager.isInitialized         // Whether manager is ready
```

### Methods

```dart
await manager.initialize()                    // Initialize and load data
await manager.addNotification(message)        // Add new notification
await manager.markAsRead(messageId)           // Mark one as read
await manager.markAllAsRead()                 // Mark all as read
await manager.clearAll()                      // Delete all notifications
await manager.removeNotification(messageId)   // Remove specific notification
```

## Testing

### Send Test Notification from Firebase Console

1. Go to Firebase Console > Cloud Messaging
2. Click "Send your first message"
3. Enter notification title and text
4. Select your app
5. Send test message to your FCM token

### Send from your backend

```javascript
const admin = require('firebase-admin');

await admin.messaging().send({
  token: 'DEVICE_FCM_TOKEN',
  notification: {
    title: 'Hello',
    body: 'Test notification',
  },
  data: {
    customKey: 'customValue',
  },
});
```

## Requirements

- Flutter >=3.0.0
- Dart >=3.0.0
- iOS >=12.0
- Android minSdkVersion 21

## License

MIT License - see LICENSE file for details

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## Support

For issues and questions, please file an issue on GitHub.


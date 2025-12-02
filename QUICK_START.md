# Quick Start Guide

## 1. Add to pubspec.yaml

```yaml
dependencies:
  flutter_fcm_notifications: ^1.0.0
```

Run:
```bash
flutter pub get
```

## 2. Setup Firebase

### Android
- Add `google-services.json` to `android/app/`
- Update `android/build.gradle`:
  ```gradle
  classpath 'com.google.gms:google-services:4.4.0'
  ```
- Update `android/app/build.gradle`:
  ```gradle
  apply plugin: 'com.google.gms.google-services'
  
  android {
      defaultConfig {
          minSdkVersion 21
      }
  }
  ```

### iOS
- Add `GoogleService-Info.plist` to `ios/Runner/`
- Enable Push Notifications in Xcode

## 3. Basic Implementation

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_fcm_notifications/flutter_fcm_notifications.dart';
import 'package:provider/provider.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => NotificationManager()..initialize(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
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
    
    await messaging.requestPermission();
    
    FirebaseMessaging.onMessage.listen((message) {
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
      body: Center(child: Text('Home Page')),
    );
  }
}
```

## 4. Customization (Optional)

```dart
final customConfig = NotificationConfig(
  primaryColor: Colors.blue,
  locale: 'en_US',
  appBarTitle: 'My Notifications',
);

NotificationScreen(
  manager: notificationManager,
  config: customConfig,
)
```

## Done!

Test by sending notification from Firebase Console.

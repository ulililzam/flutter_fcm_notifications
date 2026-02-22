import 'dart:async' show unawaited;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../managers/notification_manager.dart';

/// A convenience service that centralises Firebase Cloud Messaging (FCM)
/// and [FlutterLocalNotificationsPlugin] initialisation for Android and iOS.
///
/// Call [FcmSetupService.initialize] once in `main()` **after** Firebase has
/// been initialised. The service will:
/// - Register the [FlutterLocalNotificationsPlugin] with Android + iOS settings.
/// - Create the Android notification channel.
/// - Enable iOS foreground display options.
/// - Register the FCM background handler (if provided).
/// - Listen for foreground messages and store them in [NotificationManager].
///
/// ## Example
/// ```dart
/// @pragma('vm:entry-point')
/// Future<void> _bgHandler(RemoteMessage msg) async {
///   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
///   await FcmSetupService.showLocalNotification(msg);
/// }
///
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
///
///   final manager = NotificationManager();
///   await manager.initialize();
///   await FcmSetupService.initialize(manager, backgroundHandler: _bgHandler);
///
///   runApp(MyApp());
/// }
/// ```
class FcmSetupService {
  FcmSetupService._(); // Prevent instantiation

  /// Shared [FlutterLocalNotificationsPlugin] instance.
  ///
  /// Accessible when you need to schedule or cancel notifications directly,
  /// e.g. from a custom background handler.
  static final FlutterLocalNotificationsPlugin localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _defaultChannelId = 'high_importance_channel';
  static const String _defaultChannelName = 'High Importance Notifications';
  static const String _defaultChannelDescription =
      'This channel is used for important notifications.';

  // ─── Public API ────────────────────────────────────────────────────────────

  /// Initialises the full FCM + local-notification stack.
  ///
  /// Parameters:
  /// - [manager] — the [NotificationManager] that stores incoming messages.
  /// - [backgroundHandler] — a **top-level** `@pragma('vm:entry-point')`
  ///   function that handles background messages. Pass `null` to skip.
  /// - [androidIconName] — drawable/mipmap resource name for the notification
  ///   icon. Defaults to `'@mipmap/ic_launcher'`.
  /// - [channelId] / [channelName] / [channelDescription] — Android channel.
  /// - [onForegroundMessage] — optional extra callback fired *after* the
  ///   manager has stored the foreground message.
  /// - [onMessageOpenedApp] — optional callback when user taps a background
  ///   notification to open the app.
  /// - [onNotificationResponse] — optional callback when user taps a local
  ///   notification (payload is the message ID).
  static Future<void> initialize(
    NotificationManager manager, {
    Future<void> Function(RemoteMessage)? backgroundHandler,
    String androidIconName = '@mipmap/ic_launcher',
    String channelId = _defaultChannelId,
    String channelName = _defaultChannelName,
    String channelDescription = _defaultChannelDescription,
    void Function(RemoteMessage message)? onForegroundMessage,
    void Function(RemoteMessage message)? onMessageOpenedApp,
    void Function(NotificationResponse response)? onNotificationResponse,
  }) async {
    // ── Local notifications init ──────────────────────────────────────────
    final androidSettings = AndroidInitializationSettings(androidIconName);

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const macOSSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await localNotificationsPlugin.initialize(
      InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
        macOS: macOSSettings,
      ),
      onDidReceiveNotificationResponse: (response) {
        debugPrint(
          '[FcmSetupService] local notification tapped — '
          'id: ${response.id}, payload: ${response.payload}',
        );
        onNotificationResponse?.call(response);
      },
    );

    // ── Android notification channel ──────────────────────────────────────
    await localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          AndroidNotificationChannel(
            channelId,
            channelName,
            description: channelDescription,
            importance: Importance.max,
          ),
        );

    // ── iOS foreground display options ────────────────────────────────────
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // ── Background handler ────────────────────────────────────────────────
    if (backgroundHandler != null) {
      FirebaseMessaging.onBackgroundMessage(backgroundHandler);
    }

    // ── Foreground messages ───────────────────────────────────────────────
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint(
        '[FcmSetupService] foreground message — id: ${message.messageId}',
      );
      manager.addNotification(message);
      unawaited(showLocalNotification(
        message,
        channelId: channelId,
        channelName: channelName,
        channelDescription: channelDescription,
      ));
      onForegroundMessage?.call(message);
    });

    // ── App opened via notification tap ───────────────────────────────────
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint(
        '[FcmSetupService] notification opened app — id: ${message.messageId}',
      );
      manager.addNotification(message);
      onMessageOpenedApp?.call(message);
    });

    // ── Terminated-state initial message ─────────────────────────────────
    final initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      debugPrint(
        '[FcmSetupService] initial message (cold start) — '
        'id: ${initialMessage.messageId}',
      );
      await manager.addNotification(initialMessage);
      onMessageOpenedApp?.call(initialMessage);
    }

    debugPrint('[FcmSetupService] initialized ✓');
  }

  /// Displays a local notification for the given [RemoteMessage].
  ///
  /// Safe to call from both foreground and background isolates.
  /// In a background handler, ensure [localNotificationsPlugin] is already
  /// initialised (or call [initialize] first with Firebase already set up).
  static Future<void> showLocalNotification(
    RemoteMessage message, {
    String channelId = _defaultChannelId,
    String channelName = _defaultChannelName,
    String channelDescription = _defaultChannelDescription,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      // Use big picture style when the message carries an image
      styleInformation: message.notification?.android?.imageUrl != null
          ? BigPictureStyleInformation(
              FilePathAndroidBitmap(message.notification!.android!.imageUrl!),
              hideExpandedLargeIcon: true,
            )
          : null,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await localNotificationsPlugin.show(
      message.hashCode,
      message.notification?.title ?? 'New Message',
      message.notification?.body ?? 'You have a new message',
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: message.messageId,
    );
  }
}

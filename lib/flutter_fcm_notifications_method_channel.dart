import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_fcm_notifications_platform_interface.dart';

/// An implementation of [FlutterFcmNotificationsPlatform] that uses method channels.
class MethodChannelFlutterFcmNotifications extends FlutterFcmNotificationsPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_fcm_notifications');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_fcm_notifications_method_channel.dart';

abstract class FlutterFcmNotificationsPlatform extends PlatformInterface {
  /// Constructs a FlutterFcmNotificationsPlatform.
  FlutterFcmNotificationsPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterFcmNotificationsPlatform _instance = MethodChannelFlutterFcmNotifications();

  /// The default instance of [FlutterFcmNotificationsPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterFcmNotifications].
  static FlutterFcmNotificationsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterFcmNotificationsPlatform] when
  /// they register themselves.
  static set instance(FlutterFcmNotificationsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}

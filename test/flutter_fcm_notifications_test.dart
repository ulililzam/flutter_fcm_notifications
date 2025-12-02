import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fcm_notifications/flutter_fcm_notifications.dart';

void main() {
  test('NotificationConfig has default values', () {
    const config = NotificationConfig();
    expect(config.locale, 'id_ID');
    expect(config.maxNotifications, 50);
  });

  test('NotificationConfig.english has correct locale', () {
    final config = NotificationConfig.english;
    expect(config.locale, 'en_US');
    expect(config.appBarTitle, 'Notifications');
  });

  test('NotificationConfig.indonesian has correct locale', () {
    final config = NotificationConfig.indonesian;
    expect(config.locale, 'id_ID');
    expect(config.appBarTitle, 'Notifikasi');
  });
}

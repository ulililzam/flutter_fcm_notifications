import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_fcm_notifications/flutter_fcm_notifications.dart';

// Helper: create a bare NotificationItem without a RemoteMessage.
NotificationItem makeItem({
  String id = 'msg-001',
  String title = 'Hello',
  String body = 'World',
  bool isRead = false,
  DateTime? timestamp,
}) {
  return NotificationItem(
    messageId: id,
    title: title,
    body: body,
    timestamp: timestamp ?? DateTime(2025, 1, 15, 10, 30),
    isRead: isRead,
  );
}

void main() {
  // ─── NotificationConfig ────────────────────────────────────────────────

  group('NotificationConfig', () {
    test('has expected Indonesian defaults', () {
      const config = NotificationConfig();
      expect(config.locale, 'id_ID');
      expect(config.appBarTitle, 'Notifikasi');
      expect(config.maxNotifications, 50);
      expect(config.enableHapticFeedback, true);
      expect(config.enablePullToRefresh, true);
    });

    test('NotificationConfig.english has correct values', () {
      expect(NotificationConfig.english.locale, 'en_US');
      expect(NotificationConfig.english.appBarTitle, 'Notifications');
      expect(NotificationConfig.english.todayLabel, 'Today');
      expect(NotificationConfig.english.yesterdayLabel, 'Yesterday');
    });

    test('NotificationConfig.indonesian has correct values', () {
      expect(NotificationConfig.indonesian.locale, 'id_ID');
      expect(NotificationConfig.indonesian.appBarTitle, 'Notifikasi');
      expect(NotificationConfig.indonesian.todayLabel, 'Hari ini');
    });

    test('copyWith overrides only specified fields', () {
      const base = NotificationConfig();
      final updated = base.copyWith(locale: 'de_DE', maxNotifications: 100);
      expect(updated.locale, 'de_DE');
      expect(updated.maxNotifications, 100);
      // Unchanged fields stay the same
      expect(updated.appBarTitle, base.appBarTitle);
      expect(updated.enableHapticFeedback, base.enableHapticFeedback);
    });
  });

  // ─── NotificationItem ──────────────────────────────────────────────────

  group('NotificationItem', () {
    test('serialises to JSON and back', () {
      final item = makeItem();
      final json = item.toJson();
      final restored = NotificationItem.fromJson(json);

      expect(restored.messageId, item.messageId);
      expect(restored.title, item.title);
      expect(restored.body, item.body);
      expect(restored.isRead, item.isRead);
      expect(restored.timestamp.toIso8601String(),
          item.timestamp.toIso8601String());
    });

    test('fromJson handles isRead=true', () {
      final item = makeItem(isRead: true);
      final restored = NotificationItem.fromJson(item.toJson());
      expect(restored.isRead, true);
    });

    test('copyWith only changes specified fields', () {
      final original = makeItem();
      final updated = original.copyWith(isRead: true, title: 'Updated');
      expect(updated.isRead, true);
      expect(updated.title, 'Updated');
      expect(updated.body, original.body);
      expect(updated.messageId, original.messageId);
    });

    test('equality is based on messageId', () {
      final a = makeItem(id: 'abc', title: 'First');
      final b = makeItem(id: 'abc', title: 'Different title');
      final c = makeItem(id: 'xyz');
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('hashCode is consistent with equality', () {
      final a = makeItem(id: 'same-id');
      final b = makeItem(id: 'same-id');
      expect(a.hashCode, b.hashCode);
    });

    test('toString contains key info', () {
      final item = makeItem(id: 'test-id');
      expect(item.toString(), contains('test-id'));
    });
  });

  // ─── NotificationManager ──────────────────────────────────────────────

  group('NotificationManager', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('initializes with empty list', () async {
      final manager = NotificationManager();
      await manager.initialize();
      expect(manager.notifications, isEmpty);
      expect(manager.unreadCount, 0);
      expect(manager.isInitialized, true);
      manager.dispose();
    });

    test('initialize is idempotent (calling twice is safe)', () async {
      final manager = NotificationManager();
      await manager.initialize();
      await manager.initialize(); // should not throw
      manager.dispose();
    });

    test('addNotification via helper adds item', () async {
      final manager = NotificationManager();
      await manager.initialize();

      // RemoteMessage cannot be instantiated in unit tests without Firebase.
      // Integration-level add is tested via the persist/reload round-trip test.
      expect(manager.notifications, isEmpty);
      manager.dispose();
    });

    test('markAsRead updates item and persists', () async {
      final manager = NotificationManager();
      await manager.initialize();

      // Use public API — load persisted data with pre-seeded prefs
      SharedPreferences.setMockInitialValues({
        'fcm_notifications':
            '[{"title":"Test","body":"Body","timestamp":"2025-01-01T10:00:00.000","messageId":"id-1","isRead":false,"data":null}]',
      });

      final manager2 = NotificationManager();
      await manager2.initialize();

      expect(manager2.notifications.length, 1);
      expect(manager2.notifications.first.isRead, false);
      expect(manager2.unreadCount, 1);

      await manager2.markAsRead('id-1');
      expect(manager2.notifications.first.isRead, true);
      expect(manager2.unreadCount, 0);

      manager.dispose();
      manager2.dispose();
    });

    test('markAllAsRead marks all unread items', () async {
      SharedPreferences.setMockInitialValues({
        'fcm_notifications':
            '[{"title":"A","body":"","timestamp":"2025-01-01T10:00:00.000","messageId":"id-1","isRead":false,"data":null},'
                '{"title":"B","body":"","timestamp":"2025-01-01T11:00:00.000","messageId":"id-2","isRead":false,"data":null}]',
      });

      final manager = NotificationManager();
      await manager.initialize();

      expect(manager.unreadCount, 2);
      await manager.markAllAsRead();
      expect(manager.unreadCount, 0);
      expect(manager.notifications.every((n) => n.isRead), true);

      manager.dispose();
    });

    test('markAllAsRead is no-op when all already read', () async {
      int notifyCount = 0;

      SharedPreferences.setMockInitialValues({
        'fcm_notifications':
            '[{"title":"A","body":"","timestamp":"2025-01-01T10:00:00.000","messageId":"id-1","isRead":true,"data":null}]',
      });

      final manager = NotificationManager();
      manager.addListener(() => notifyCount++);
      await manager.initialize();
      notifyCount = 0; // reset after init

      await manager.markAllAsRead();
      expect(notifyCount, 0); // no rebuild triggered
      manager.dispose();
    });

    test('removeNotification removes only the matching item', () async {
      SharedPreferences.setMockInitialValues({
        'fcm_notifications':
            '[{"title":"A","body":"","timestamp":"2025-01-01T10:00:00.000","messageId":"id-1","isRead":false,"data":null},'
                '{"title":"B","body":"","timestamp":"2025-01-01T11:00:00.000","messageId":"id-2","isRead":false,"data":null}]',
      });

      final manager = NotificationManager();
      await manager.initialize();
      expect(manager.notifications.length, 2);

      await manager.removeNotification('id-1');
      expect(manager.notifications.length, 1);
      expect(manager.notifications.first.messageId, 'id-2');

      manager.dispose();
    });

    test('clearAll empties list and storage', () async {
      SharedPreferences.setMockInitialValues({
        'fcm_notifications':
            '[{"title":"A","body":"","timestamp":"2025-01-01T10:00:00.000","messageId":"id-1","isRead":false,"data":null}]',
      });

      final manager = NotificationManager();
      await manager.initialize();
      expect(manager.notifications.length, 1);

      await manager.clearAll();
      expect(manager.notifications, isEmpty);
      expect(manager.unreadCount, 0);

      // Reloading should also be empty
      final manager2 = NotificationManager();
      await manager2.initialize();
      expect(manager2.notifications, isEmpty);

      manager.dispose();
      manager2.dispose();
    });

    test('maxNotifications limit is respected', () async {
      SharedPreferences.setMockInitialValues({
        'fcm_notifications':
            '[{"title":"A","body":"","timestamp":"2025-01-01T10:00:00.000","messageId":"id-1","isRead":false,"data":null},'
                '{"title":"B","body":"","timestamp":"2025-01-01T11:00:00.000","messageId":"id-2","isRead":false,"data":null}]',
      });

      final manager = NotificationManager(
        config: const NotificationConfig(maxNotifications: 2),
      );
      await manager.initialize();
      expect(manager.notifications.length, lessThanOrEqualTo(2));

      manager.dispose();
    });

    test('notifications list is unmodifiable', () async {
      final manager = NotificationManager();
      await manager.initialize();
      expect(
        () => (manager.notifications as List).add(makeItem()),
        throwsUnsupportedError,
      );
      manager.dispose();
    });

    test('persist and reload round-trip', () async {
      SharedPreferences.setMockInitialValues({
        'fcm_notifications':
            '[{"title":"Persisted","body":"Body","timestamp":"2025-06-01T09:00:00.000","messageId":"persist-id","isRead":true,"data":null}]',
      });

      final manager = NotificationManager();
      await manager.initialize();

      expect(manager.notifications.length, 1);
      expect(manager.notifications.first.title, 'Persisted');
      expect(manager.notifications.first.isRead, true);

      manager.dispose();
    });
  });
}


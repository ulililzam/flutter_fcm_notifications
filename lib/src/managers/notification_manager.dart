import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../config/notification_config.dart';
import '../models/notification_item.dart';

/// Manages the lifecycle of notifications — adding, reading, persisting,
/// and clearing — using a single [SharedPreferences] key for storage.
///
/// Usage:
/// ```dart
/// final manager = NotificationManager();
/// await manager.initialize();
/// await manager.addNotification(remoteMessage);
/// ```
class NotificationManager extends ChangeNotifier {
  final NotificationConfig config;

  List<NotificationItem> _notifications = [];
  bool _isInitialized = false;

  SharedPreferences? _prefs;

  static const String _storageKey = 'fcm_notifications';
  static const _uuid = Uuid();

  NotificationManager({
    this.config = const NotificationConfig(),
  });

  // ─── Public getters ──────────────────────────────────────────────────────

  /// Immutable snapshot of all stored notifications, newest first.
  List<NotificationItem> get notifications => List.unmodifiable(_notifications);

  /// Number of notifications the user has not yet opened.
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// Whether [initialize] has completed successfully.
  bool get isInitialized => _isInitialized;

  // ─── Lifecycle ───────────────────────────────────────────────────────────

  /// Loads persisted notifications from storage. Must be called once before
  /// using any other method.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _prefs = await SharedPreferences.getInstance();
      await _loadFromStorage();
      _isInitialized = true;
      notifyListeners();
    } catch (e, st) {
      debugPrint('[NotificationManager] initialize failed: $e\n$st');
      rethrow;
    }
  }

  // ─── Mutations ───────────────────────────────────────────────────────────

  /// Converts [message] into a [NotificationItem] and prepends it to the
  /// list. Silently ignores duplicate message IDs.
  Future<void> addNotification(RemoteMessage message) async {
    try {
      // Resolve a guaranteed-non-null ID: prefer Firebase's, fall back to UUID.
      final messageId =
          (message.messageId?.isNotEmpty ?? false) ? message.messageId! : _uuid.v4();

      // Deduplicate
      if (_notifications.any((n) => n.messageId == messageId)) return;

      final item = NotificationItem.fromRemoteMessage(
        message,
        messageId: messageId,
        timestamp: DateTime.now(),
      );

      _notifications.insert(0, item);

      // Enforce capacity limit
      if (_notifications.length > config.maxNotifications) {
        _notifications.removeLast();
      }

      await _persist();
      notifyListeners();
    } catch (e, st) {
      debugPrint('[NotificationManager] addNotification failed: $e\n$st');
      rethrow;
    }
  }

  /// Marks the notification with [messageId] as read. No-ops if not found
  /// or already read.
  Future<void> markAsRead(String messageId) async {
    try {
      final index = _notifications.indexWhere((n) => n.messageId == messageId);
      if (index == -1 || _notifications[index].isRead) return;

      _notifications[index] = _notifications[index].copyWith(isRead: true);
      await _persist();
      notifyListeners();
    } catch (e, st) {
      debugPrint('[NotificationManager] markAsRead failed: $e\n$st');
      rethrow;
    }
  }

  /// Marks every unread notification as read.
  Future<void> markAllAsRead() async {
    try {
      bool changed = false;

      for (int i = 0; i < _notifications.length; i++) {
        if (!_notifications[i].isRead) {
          _notifications[i] = _notifications[i].copyWith(isRead: true);
          changed = true;
        }
      }

      if (!changed) return;

      await _persist();
      notifyListeners();
    } catch (e, st) {
      debugPrint('[NotificationManager] markAllAsRead failed: $e\n$st');
      rethrow;
    }
  }

  /// Removes the notification with [messageId]. No-ops if not found.
  Future<void> removeNotification(String messageId) async {
    try {
      final before = _notifications.length;
      _notifications.removeWhere((n) => n.messageId == messageId);
      if (_notifications.length == before) return;

      await _persist();
      notifyListeners();
    } catch (e, st) {
      debugPrint('[NotificationManager] removeNotification failed: $e\n$st');
      rethrow;
    }
  }

  /// Deletes all notifications from memory and storage.
  Future<void> clearAll() async {
    try {
      _notifications.clear();
      await _prefs?.remove(_storageKey);
      notifyListeners();
    } catch (e, st) {
      debugPrint('[NotificationManager] clearAll failed: $e\n$st');
      rethrow;
    }
  }

  // ─── Persistence ─────────────────────────────────────────────────────────

  Future<void> _loadFromStorage() async {
    try {
      final raw = _prefs?.getString(_storageKey);
      if (raw == null) return;

      final list = jsonDecode(raw) as List<dynamic>;
      _notifications = list
          .map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[NotificationManager] _loadFromStorage failed: $e');
      _notifications = [];
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      final json = jsonEncode(_notifications.map((n) => n.toJson()).toList());
      await prefs.setString(_storageKey, json);
    } catch (e) {
      debugPrint('[NotificationManager] _persist failed: $e');
    }
  }

  // ─── ChangeNotifier override ─────────────────────────────────────────────

  @override
  void dispose() {
    _notifications.clear();
    super.dispose();
  }
}


import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_item.dart';
import '../config/notification_config.dart';

/// Manager class for handling notifications with persistence
class NotificationManager extends ChangeNotifier {
  final NotificationConfig config;
  
  List<NotificationItem> _notifications = [];
  final Map<String, bool> _readStatus = {};
  final Map<String, DateTime> _messageTimestamps = {};
  
  bool _isInitialized = false;
  
  static const String _notificationsKey = 'fcm_notifications';
  static const String _readStatusPrefix = 'read_';
  static const String _timestampPrefix = 'timestamp_';

  NotificationManager({
    this.config = const NotificationConfig(),
  });

  /// Get all notifications
  List<NotificationItem> get notifications => List.unmodifiable(_notifications);

  /// Get unread notifications count
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// Get read status map
  Map<String, bool> get readStatus => Map.unmodifiable(_readStatus);

  /// Get message timestamps
  Map<String, DateTime> get messageTimestamps => Map.unmodifiable(_messageTimestamps);

  /// Check if manager is initialized
  bool get isInitialized => _isInitialized;

  /// Initialize the manager and load persisted data
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _loadNotifications();
      await _loadReadStatus();
      await _loadTimestamps();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing NotificationManager: $e');
      rethrow;
    }
  }

  /// Add a new notification from RemoteMessage
  Future<void> addNotification(RemoteMessage message) async {
    try {
      final timestamp = DateTime.now();
      final messageId = message.messageId ?? '';

      // Save timestamp
      if (messageId.isNotEmpty) {
        _messageTimestamps[messageId] = timestamp;
        await _saveTimestamp(messageId, timestamp);
      }

      final notification = NotificationItem.fromRemoteMessage(
        message,
        timestamp: timestamp,
        isRead: false,
      );

      // Add to the beginning of the list
      _notifications.insert(0, notification);

      // Limit to max notifications
      if (_notifications.length > config.maxNotifications) {
        final removed = _notifications.removeLast();
        // Clean up old data
        if (removed.messageId != null) {
          await _removeReadStatus(removed.messageId!);
          await _removeTimestamp(removed.messageId!);
        }
      }

      await _saveNotifications();
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding notification: $e');
      rethrow;
    }
  }

  /// Mark a notification as read
  Future<void> markAsRead(String messageId) async {
    try {
      _readStatus[messageId] = true;
      await _saveReadStatus(messageId, true);

      // Update the notification item
      final index = _notifications.indexWhere((n) => n.messageId == messageId);
      if (index != -1) {
        _notifications[index].isRead = true;
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
      rethrow;
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      for (var notification in _notifications) {
        if (!notification.isRead && notification.messageId != null) {
          notification.isRead = true;
          _readStatus[notification.messageId!] = true;
          await _saveReadStatus(notification.messageId!, true);
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error marking all as read: $e');
      rethrow;
    }
  }

  /// Clear all notifications
  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Remove all notification-related data
      for (var notification in _notifications) {
        if (notification.messageId != null) {
          await prefs.remove('$_readStatusPrefix${notification.messageId}');
          await prefs.remove('$_timestampPrefix${notification.messageId}');
        }
      }
      
      await prefs.remove(_notificationsKey);
      
      _notifications.clear();
      _readStatus.clear();
      _messageTimestamps.clear();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing notifications: $e');
      rethrow;
    }
  }

  /// Remove a specific notification
  Future<void> removeNotification(String messageId) async {
    try {
      _notifications.removeWhere((n) => n.messageId == messageId);
      await _removeReadStatus(messageId);
      await _removeTimestamp(messageId);
      await _saveNotifications();
      notifyListeners();
    } catch (e) {
      debugPrint('Error removing notification: $e');
      rethrow;
    }
  }

  // Private methods for persistence

  Future<void> _loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? notificationsJson = prefs.getString(_notificationsKey);
      
      if (notificationsJson != null) {
        final List<dynamic> decoded = jsonDecode(notificationsJson);
        _notifications = decoded
            .map((json) => NotificationItem.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading notifications: $e');
      _notifications = [];
    }
  }

  Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> jsonList = 
          _notifications.map((n) => n.toJson()).toList();
      await prefs.setString(_notificationsKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Error saving notifications: $e');
    }
  }

  Future<void> _loadReadStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((k) => k.startsWith(_readStatusPrefix));
      
      for (var key in keys) {
        final messageId = key.replaceFirst(_readStatusPrefix, '');
        _readStatus[messageId] = prefs.getBool(key) ?? false;
      }

      // Update notification items with read status
      for (var notification in _notifications) {
        if (notification.messageId != null) {
          notification.isRead = _readStatus[notification.messageId!] ?? false;
        }
      }
    } catch (e) {
      debugPrint('Error loading read status: $e');
    }
  }

  Future<void> _saveReadStatus(String messageId, bool isRead) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('$_readStatusPrefix$messageId', isRead);
    } catch (e) {
      debugPrint('Error saving read status: $e');
    }
  }

  Future<void> _removeReadStatus(String messageId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_readStatusPrefix$messageId');
      _readStatus.remove(messageId);
    } catch (e) {
      debugPrint('Error removing read status: $e');
    }
  }

  Future<void> _loadTimestamps() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((k) => k.startsWith(_timestampPrefix));
      
      for (var key in keys) {
        final messageId = key.replaceFirst(_timestampPrefix, '');
        final timestampStr = prefs.getString(key);
        if (timestampStr != null) {
          _messageTimestamps[messageId] = DateTime.parse(timestampStr);
        }
      }
    } catch (e) {
      debugPrint('Error loading timestamps: $e');
    }
  }

  Future<void> _saveTimestamp(String messageId, DateTime timestamp) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        '$_timestampPrefix$messageId',
        timestamp.toIso8601String(),
      );
    } catch (e) {
      debugPrint('Error saving timestamp: $e');
    }
  }

  Future<void> _removeTimestamp(String messageId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_timestampPrefix$messageId');
      _messageTimestamps.remove(messageId);
    } catch (e) {
      debugPrint('Error removing timestamp: $e');
    }
  }

  @override
  void dispose() {
    _notifications.clear();
    _readStatus.clear();
    _messageTimestamps.clear();
    super.dispose();
  }
}

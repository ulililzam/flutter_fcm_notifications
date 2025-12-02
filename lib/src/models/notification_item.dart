import 'package:firebase_messaging/firebase_messaging.dart';

/// Model class representing a notification item
class NotificationItem {
  /// Title of the notification
  final String title;

  /// Body/content of the notification
  final String body;

  /// Timestamp when the notification was received
  final DateTime timestamp;

  /// Unique message ID from Firebase
  final String? messageId;

  /// Whether the notification has been read
  bool isRead;

  /// Additional data payload
  final Map<String, dynamic>? data;

  NotificationItem({
    required this.title,
    required this.body,
    required this.timestamp,
    this.messageId,
    this.isRead = false,
    this.data,
  });

  /// Create a NotificationItem from a Firebase RemoteMessage
  factory NotificationItem.fromRemoteMessage(
    RemoteMessage message, {
    bool isRead = false,
    DateTime? timestamp,
  }) {
    return NotificationItem(
      title: message.notification?.title ?? 'Data Message',
      body: message.notification?.body ?? message.data.toString(),
      timestamp: timestamp ?? DateTime.now(),
      messageId: message.messageId,
      isRead: isRead,
      data: message.data.isNotEmpty ? message.data : null,
    );
  }

  /// Convert to JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
      'messageId': messageId,
      'isRead': isRead,
      'data': data,
    };
  }

  /// Create from JSON
  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      title: json['title'] as String,
      body: json['body'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      messageId: json['messageId'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  /// Create a copy with updated fields
  NotificationItem copyWith({
    String? title,
    String? body,
    DateTime? timestamp,
    String? messageId,
    bool? isRead,
    Map<String, dynamic>? data,
  }) {
    return NotificationItem(
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      messageId: messageId ?? this.messageId,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationItem &&
          runtimeType == other.runtimeType &&
          messageId == other.messageId;

  @override
  int get hashCode => messageId.hashCode;
}

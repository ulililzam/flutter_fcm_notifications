import 'package:firebase_messaging/firebase_messaging.dart';

/// Immutable model representing a single notification item.
class NotificationItem {
  /// Display title of the notification.
  final String title;

  /// Display body/content of the notification.
  final String body;

  /// Timestamp when the notification was received.
  final DateTime timestamp;

  /// Unique message ID. Always non-null — a UUID fallback is used when
  /// Firebase does not provide one.
  final String messageId;

  /// Whether the user has read this notification.
  final bool isRead;

  /// Additional data payload from the FCM message.
  final Map<String, dynamic>? data;

  /// Remote image URL to display in the notification card.
  /// Populated from [AndroidNotification.imageUrl] or data['image'].
  final String? imageUrl;

  /// Deep-link route / click action.
  /// Populated from data['click_action'].
  final String? clickAction;

  /// Android notification channel ID.
  /// Populated from [AndroidNotification.channelId].
  final String? channelId;

  /// Android notification tag used to replace or update a notification.
  /// Populated from [AndroidNotification.tag].
  final String? tag;

  /// Android notification accent color as a hex string (e.g. '#FF0000').
  /// Populated from [AndroidNotification.color].
  final String? color;

  const NotificationItem({
    required this.title,
    required this.body,
    required this.timestamp,
    required this.messageId,
    this.isRead = false,
    this.data,
    this.imageUrl,
    this.clickAction,
    this.channelId,
    this.tag,
    this.color,
  });

  /// Creates a [NotificationItem] from a Firebase [RemoteMessage].
  ///
  /// [messageId] should be the Firebase message ID or a pre-generated UUID
  /// fallback — never null at the call site.
  factory NotificationItem.fromRemoteMessage(
    RemoteMessage message, {
    required String messageId,
    bool isRead = false,
    DateTime? timestamp,
  }) {
    final android = message.notification?.android;
    final data = message.data;
    return NotificationItem(
      title: message.notification?.title ?? 'New Message',
      body: message.notification?.body ??
          (data.isNotEmpty ? data.toString() : ''),
      timestamp: timestamp ?? DateTime.now(),
      messageId: messageId,
      isRead: isRead,
      data: data.isNotEmpty ? data : null,
      // Android-specific fields from notification payload
      imageUrl: android?.imageUrl ?? data['image'] as String?,
      clickAction: data['click_action'] as String?,
      channelId: android?.channelId,
      tag: android?.tag,
      color: android?.color,
    );
  }

  /// Returns a copy of this item with the given fields replaced.
  NotificationItem copyWith({
    String? title,
    String? body,
    DateTime? timestamp,
    String? messageId,
    bool? isRead,
    Map<String, dynamic>? data,
    String? imageUrl,
    String? clickAction,
    String? channelId,
    String? tag,
    String? color,
  }) {
    return NotificationItem(
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      messageId: messageId ?? this.messageId,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
      imageUrl: imageUrl ?? this.imageUrl,
      clickAction: clickAction ?? this.clickAction,
      channelId: channelId ?? this.channelId,
      tag: tag ?? this.tag,
      color: color ?? this.color,
    );
  }

  /// Serialises this item to JSON for persistence.
  Map<String, dynamic> toJson() => {
        'title': title,
        'body': body,
        'timestamp': timestamp.toIso8601String(),
        'messageId': messageId,
        'isRead': isRead,
        'data': data,
        'imageUrl': imageUrl,
        'clickAction': clickAction,
        'channelId': channelId,
        'tag': tag,
        'color': color,
      };

  /// Deserialises a [NotificationItem] from a JSON map.
  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      title: json['title'] as String,
      body: json['body'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      messageId: json['messageId'] as String,
      isRead: json['isRead'] as bool? ?? false,
      data: json['data'] as Map<String, dynamic>?,
      imageUrl: json['imageUrl'] as String?,
      clickAction: json['clickAction'] as String?,
      channelId: json['channelId'] as String?,
      tag: json['tag'] as String?,
      color: json['color'] as String?,
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

  @override
  String toString() =>
      'NotificationItem(id: $messageId, title: $title, isRead: $isRead)';
}

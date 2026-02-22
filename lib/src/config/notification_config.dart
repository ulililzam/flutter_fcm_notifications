import 'package:flutter/material.dart';
import '../models/notification_item.dart';

/// Configuration class for customizing the notification screen appearance and behavior
class NotificationConfig {
  /// Primary color for UI elements
  final Color primaryColor;

  /// Background color for the screen
  final Color backgroundColor;

  /// Card background color for read notifications
  final Color cardBackgroundColor;

  /// Card background color for unread notifications
  final Color unreadCardBackgroundColor;

  /// Text color for titles
  final Color titleTextColor;

  /// Text color for body content
  final Color bodyTextColor;

  /// Text color for secondary information (time, etc)
  final Color secondaryTextColor;

  /// Color for unread indicator dot
  final Color unreadIndicatorColor;

  /// Date header text color
  final Color dateHeaderColor;

  /// Locale for date formatting (e.g., 'id_ID', 'en_US')
  final String locale;

  /// Maximum number of notifications to store
  final int maxNotifications;

  /// Custom text for 'Mark All Read' button
  final String markAllReadText;

  /// Custom text for 'All Notifications' filter
  final String allNotificationsText;

  /// Custom text for 'Unread' filter
  final String unreadFilterText;

  /// Custom text for 'No Notifications' empty state title
  final String noNotificationsTitle;

  /// Custom text for 'No Notifications' empty state subtitle
  final String noNotificationsSubtitle;

  /// Custom text for 'Today' date label
  final String todayLabel;

  /// Custom text for 'Yesterday' date label
  final String yesterdayLabel;

  /// Custom text for 'Notifications' app bar title
  final String appBarTitle;

  /// Enable haptic feedback on interactions
  final bool enableHapticFeedback;

  /// Enable pull-to-refresh
  final bool enablePullToRefresh;

  /// Card border radius
  final double cardBorderRadius;

  /// Empty state icon
  final IconData emptyStateIcon;

  /// Empty state icon size
  final double emptyStateIconSize;

  /// Empty state icon background color
  final Color emptyStateIconBackgroundColor;

  /// Empty state icon color
  final Color emptyStateIconColor;

  /// Callback invoked when the user taps a notification card.
  ///
  /// Use this to navigate to a specific route using the notification's
  /// [NotificationItem.clickAction] or custom [NotificationItem.data]. Example:
  /// ```dart
  /// onNotificationTap: (n) => context.go(n.clickAction ?? '/notifications'),
  /// ```
  ///
  /// Note: marking the notification as read is handled automatically before
  /// this callback fires.
  final void Function(NotificationItem notification)? onNotificationTap;

  const NotificationConfig({
    this.primaryColor = const Color(0xFF007AFF),
    this.backgroundColor = const Color(0xFFF2F2F7),
    this.cardBackgroundColor = Colors.white,
    this.unreadCardBackgroundColor = const Color(0xFFF8F8F8),
    this.titleTextColor = Colors.black,
    this.bodyTextColor = const Color(0xFF6B6B70),
    this.secondaryTextColor = const Color(0xFF8E8E93),
    this.unreadIndicatorColor = const Color(0xFF007AFF),
    this.dateHeaderColor = const Color(0xFF8E8E93),
    this.locale = 'id_ID',
    this.maxNotifications = 50,
    this.markAllReadText = 'Tandai Sudah Dibaca',
    this.allNotificationsText = 'Semua Notifikasi',
    this.unreadFilterText = 'Belum Dibaca',
    this.noNotificationsTitle = 'Tidak Ada Notifikasi',
    this.noNotificationsSubtitle = 'Notifikasi baru akan muncul di sini',
    this.todayLabel = 'Hari ini',
    this.yesterdayLabel = 'Kemarin',
    this.appBarTitle = 'Notifikasi',
    this.enableHapticFeedback = true,
    this.enablePullToRefresh = true,
    this.cardBorderRadius = 12.0,
    this.emptyStateIcon = Icons.notifications_active,
    this.emptyStateIconSize = 40.0,
    this.emptyStateIconBackgroundColor = const Color(0xFFE5E5EA),
    this.emptyStateIconColor = const Color(0xFF8E8E93),
    this.onNotificationTap,
  });

  /// Create a copy of this configuration with updated values
  NotificationConfig copyWith({
    Color? primaryColor,
    Color? backgroundColor,
    Color? cardBackgroundColor,
    Color? unreadCardBackgroundColor,
    Color? titleTextColor,
    Color? bodyTextColor,
    Color? secondaryTextColor,
    Color? unreadIndicatorColor,
    Color? dateHeaderColor,
    String? locale,
    int? maxNotifications,
    String? markAllReadText,
    String? allNotificationsText,
    String? unreadFilterText,
    String? noNotificationsTitle,
    String? noNotificationsSubtitle,
    String? todayLabel,
    String? yesterdayLabel,
    String? appBarTitle,
    bool? enableHapticFeedback,
    bool? enablePullToRefresh,
    double? cardBorderRadius,
    IconData? emptyStateIcon,
    double? emptyStateIconSize,
    Color? emptyStateIconBackgroundColor,
    Color? emptyStateIconColor,
    void Function(NotificationItem notification)? onNotificationTap,
  }) {
    return NotificationConfig(
      primaryColor: primaryColor ?? this.primaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      cardBackgroundColor: cardBackgroundColor ?? this.cardBackgroundColor,
      unreadCardBackgroundColor: unreadCardBackgroundColor ?? this.unreadCardBackgroundColor,
      titleTextColor: titleTextColor ?? this.titleTextColor,
      bodyTextColor: bodyTextColor ?? this.bodyTextColor,
      secondaryTextColor: secondaryTextColor ?? this.secondaryTextColor,
      unreadIndicatorColor: unreadIndicatorColor ?? this.unreadIndicatorColor,
      dateHeaderColor: dateHeaderColor ?? this.dateHeaderColor,
      locale: locale ?? this.locale,
      maxNotifications: maxNotifications ?? this.maxNotifications,
      markAllReadText: markAllReadText ?? this.markAllReadText,
      allNotificationsText: allNotificationsText ?? this.allNotificationsText,
      unreadFilterText: unreadFilterText ?? this.unreadFilterText,
      noNotificationsTitle: noNotificationsTitle ?? this.noNotificationsTitle,
      noNotificationsSubtitle: noNotificationsSubtitle ?? this.noNotificationsSubtitle,
      todayLabel: todayLabel ?? this.todayLabel,
      yesterdayLabel: yesterdayLabel ?? this.yesterdayLabel,
      appBarTitle: appBarTitle ?? this.appBarTitle,
      enableHapticFeedback: enableHapticFeedback ?? this.enableHapticFeedback,
      enablePullToRefresh: enablePullToRefresh ?? this.enablePullToRefresh,
      cardBorderRadius: cardBorderRadius ?? this.cardBorderRadius,
      emptyStateIcon: emptyStateIcon ?? this.emptyStateIcon,
      emptyStateIconSize: emptyStateIconSize ?? this.emptyStateIconSize,
      emptyStateIconBackgroundColor: emptyStateIconBackgroundColor ?? this.emptyStateIconBackgroundColor,
      emptyStateIconColor: emptyStateIconColor ?? this.emptyStateIconColor,
      onNotificationTap: onNotificationTap ?? this.onNotificationTap,
    );
  }

  /// English locale configuration
  static const NotificationConfig english = NotificationConfig(
    locale: 'en_US',
    markAllReadText: 'Mark All Read',
    allNotificationsText: 'All Notifications',
    unreadFilterText: 'Unread',
    noNotificationsTitle: 'No Notifications',
    noNotificationsSubtitle: 'New notifications will appear here',
    todayLabel: 'Today',
    yesterdayLabel: 'Yesterday',
    appBarTitle: 'Notifications',
  );

  /// Indonesian locale configuration
  static const NotificationConfig indonesian = NotificationConfig(
    locale: 'id_ID',
    markAllReadText: 'Tandai Sudah Dibaca',
    allNotificationsText: 'Semua Notifikasi',
    unreadFilterText: 'Belum Dibaca',
    noNotificationsTitle: 'Tidak Ada Notifikasi',
    noNotificationsSubtitle: 'Notifikasi baru akan muncul di sini',
    todayLabel: 'Hari ini',
    yesterdayLabel: 'Kemarin',
    appBarTitle: 'Notifikasi',
  );

  /// Dark theme configuration
  static const NotificationConfig dark = NotificationConfig(
    backgroundColor: Color(0xFF000000),
    cardBackgroundColor: Color(0xFF1C1C1E),
    unreadCardBackgroundColor: Color(0xFF2C2C2E),
    titleTextColor: Colors.white,
    bodyTextColor: Color(0xFF98989D),
    secondaryTextColor: Color(0xFF98989D),
    dateHeaderColor: Color(0xFF98989D),
    emptyStateIconBackgroundColor: Color(0xFF1C1C1E),
    emptyStateIconColor: Color(0xFF98989D),
  );
}

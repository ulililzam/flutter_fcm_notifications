import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../config/notification_config.dart';
import '../managers/notification_manager.dart';
import '../models/notification_item.dart';
import '../widgets/notification_card.dart';
import '../widgets/empty_state_widget.dart';

/// Screen for displaying and managing notifications
class NotificationScreen extends StatefulWidget {
  final NotificationManager manager;
  final NotificationConfig? config;

  const NotificationScreen({
    Key? key,
    required this.manager,
    this.config,
  }) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late NotificationConfig _config;
  String _filter = 'all'; // 'all' or 'unread'

  Future<void> _refreshNotifications() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {});
    }
  }

  void _triggerHapticFeedback() {
    if (_config.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }
  }

  @override
  void initState() {
    super.initState();

    _config = widget.config ?? const NotificationConfig();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    try {
      initializeDateFormatting(_config.locale, null);
    } catch (e) {
      debugPrint('Error initializing locale: $e');
    }

    // Listen to manager changes
    widget.manager.addListener(_onManagerChanged);
  }

  void _onManagerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    widget.manager.removeListener(_onManagerChanged);
    _animationController.dispose();
    super.dispose();
  }

  Map<String, List<NotificationItem>> _groupNotificationsByDate() {
    final Map<String, List<NotificationItem>> grouped = {};
    final now = DateTime.now();

    // Filter notifications based on user selection
    var filteredNotifications = _filter == 'unread'
        ? widget.manager.notifications.where((n) => !n.isRead).toList()
        : widget.manager.notifications;

    for (var notification in filteredNotifications) {
      String dateKey;
      try {
        final difference = now.difference(notification.timestamp).inDays;

        if (difference == 0) {
          dateKey = '${_config.todayLabel}, ${DateFormat('d MMMM', _config.locale).format(notification.timestamp)}';
        } else if (difference == 1) {
          dateKey = '${_config.yesterdayLabel}, ${DateFormat('d MMMM', _config.locale).format(notification.timestamp)}';
        } else {
          dateKey = DateFormat('d MMMM', _config.locale).format(notification.timestamp);
        }
      } catch (e) {
        dateKey = _config.appBarTitle;
      }

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(notification);
    }

    // Sort each group from newest to oldest
    for (var key in grouped.keys) {
      grouped[key]!.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }

    return grouped;
  }

  Future<void> _markAllAsRead() async {
    _triggerHapticFeedback();
    _animationController.forward(from: 0.0).then((_) {
      _animationController.reverse();
    });

    await widget.manager.markAllAsRead();
  }

  Future<void> _markAsRead(NotificationItem notification) async {
    _triggerHapticFeedback();
    _animationController.forward(from: 0.0).then((_) {
      _animationController.reverse();
    });

    if (notification.messageId != null) {
      await widget.manager.markAsRead(notification.messageId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupedNotifications = _groupNotificationsByDate();

    return Scaffold(
      backgroundColor: _config.backgroundColor,
      appBar: AppBar(
        backgroundColor: _config.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          color: _config.titleTextColor,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _config.appBarTitle,
          style: TextStyle(
            color: _config.titleTextColor,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list, color: _config.titleTextColor),
            onSelected: (value) {
              setState(() {
                _filter = value;
              });
              _triggerHapticFeedback();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'all',
                child: Row(
                  children: [
                    Icon(
                      Icons.notifications,
                      color: _filter == 'all' ? _config.primaryColor : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _config.allNotificationsText,
                      style: TextStyle(
                        color: _filter == 'all' ? _config.primaryColor : _config.titleTextColor,
                        fontWeight: _filter == 'all' ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'unread',
                child: Row(
                  children: [
                    Icon(
                      Icons.circle,
                      color: _filter == 'unread' ? _config.primaryColor : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _config.unreadFilterText,
                      style: TextStyle(
                        color: _filter == 'unread' ? _config.primaryColor : _config.titleTextColor,
                        fontWeight: _filter == 'unread' ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Mark All Read Button
          if (widget.manager.unreadCount > 0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _markAllAsRead,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: Text(
                      _config.markAllReadText,
                      style: TextStyle(
                        color: _config.primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Notifications List
          Expanded(
            child: _config.enablePullToRefresh
                ? RefreshIndicator(
                    onRefresh: _refreshNotifications,
                    color: _config.primaryColor,
                    child: _buildNotificationsList(groupedNotifications),
                  )
                : _buildNotificationsList(groupedNotifications),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(Map<String, List<NotificationItem>> groupedNotifications) {
    if (widget.manager.notifications.isEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: EmptyStateWidget(config: _config),
            ),
          );
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: groupedNotifications.length,
      itemBuilder: (context, index) {
        final dateKey = groupedNotifications.keys.elementAt(index);
        final notifications = groupedNotifications[dateKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                dateKey,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _config.dateHeaderColor,
                  letterSpacing: -0.08,
                ),
              ),
            ),
            // Notifications for this date
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: notifications.length,
              itemBuilder: (context, notifIndex) {
                final notification = notifications[notifIndex];

                return NotificationCard(
                  notification: notification,
                  config: _config,
                  onTap: () => _markAsRead(notification),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/notification_item.dart';
import '../config/notification_config.dart';

/// Card widget for displaying a single notification
class NotificationCard extends StatelessWidget {
  final NotificationItem notification;
  final NotificationConfig config;
  final VoidCallback? onTap;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.config,
    this.onTap,
  });

  String _formatTime(DateTime timestamp) {
    try {
      return DateFormat('HH:mm').format(timestamp);
    } catch (e) {
      return '00:00';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: 6,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isUnread 
              ? config.unreadCardBackgroundColor
              : config.cardBackgroundColor,
          borderRadius: BorderRadius.circular(config.cardBorderRadius),
        ),
        child: Stack(
          children: [
            if (isUnread)
              Positioned(
                top: 0,
                right: 0,
                child: SizedBox(
                  width: 7,
                  height: 7,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: config.unreadIndicatorColor,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isUnread 
                                ? FontWeight.w600 
                                : FontWeight.w400,
                            color: config.titleTextColor,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        _formatTime(notification.timestamp),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isUnread 
                              ? FontWeight.w500 
                              : FontWeight.w400,
                          color: config.secondaryTextColor,
                          letterSpacing: -0.08,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notification.body,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: isUnread
                          ? config.bodyTextColor
                          : config.secondaryTextColor,
                      height: 1.2,
                      letterSpacing: -0.2,
                    ),
                    maxLines: notification.imageUrl != null ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Image — shown only when the notification carries one
                  if (notification.imageUrl != null) ...[
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        notification.imageUrl!,
                        width: double.infinity,
                        height: 160,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return SizedBox(
                            height: 160,
                            child: Center(
                              child: CircularProgressIndicator(
                                value: progress.expectedTotalBytes != null
                                    ? progress.cumulativeBytesLoaded /
                                        progress.expectedTotalBytes!
                                    : null,
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

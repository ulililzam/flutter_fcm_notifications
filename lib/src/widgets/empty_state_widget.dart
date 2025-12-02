import 'package:flutter/material.dart';
import '../config/notification_config.dart';

/// Empty state widget shown when there are no notifications
class EmptyStateWidget extends StatelessWidget {
  final NotificationConfig config;

  const EmptyStateWidget({
    Key? key,
    required this.config,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: config.emptyStateIconBackgroundColor,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              config.emptyStateIcon,
              size: config.emptyStateIconSize,
              color: config.emptyStateIconColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            config.noNotificationsTitle,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: config.titleTextColor,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            config.noNotificationsSubtitle,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: config.secondaryTextColor,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}

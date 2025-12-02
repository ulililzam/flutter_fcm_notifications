# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-12-02

### Added
- Initial release of Flutter FCM Notifications plugin
- Beautiful iOS-inspired notification UI
- NotificationManager with ChangeNotifier for state management
- Persistent notification storage with SharedPreferences
- Automatic read/unread status tracking
- Date-grouped notifications (Today, Yesterday, custom dates)
- Pull-to-refresh functionality
- Filter notifications (All/Unread)
- Haptic feedback support
- NotificationConfig for full customization
- Predefined configurations (English, Indonesian, Dark theme)
- Customizable colors, text, and locale
- Empty state widget
- Notification card widget
- Support for foreground and background FCM messages
- Comprehensive documentation and examples
- Production-ready code with error handling
- Null safety support
- Clean architecture with separation of concerns

### Features
- Maximum notification limit (configurable, default 50)
- Automatic old notification cleanup
- JSON serialization for persistence
- Timestamp tracking for each notification
- Message ID tracking
- Data payload support
- Customizable animations
- Configurable haptic feedback
- Configurable pull-to-refresh
- Customizable card border radius
- Customizable empty state icon
- Support for multiple locales (Indonesian and English by default)

### Dependencies
- firebase_core: ^2.24.2
- firebase_messaging: ^14.7.10
- flutter_local_notifications: ^17.0.0
- provider: ^6.1.1
- shared_preferences: ^2.2.2
- intl: ^0.19.0

[1.0.0]: https://github.com/novuhq/flutter-fcm-novu/releases/tag/v1.0.0

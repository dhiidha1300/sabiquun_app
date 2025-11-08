import 'package:equatable/equatable.dart';

/// Domain entity for notifications
class NotificationEntity extends Equatable {
  final String id;
  final String userId;
  final String? notificationTemplateId;
  final String title;
  final String body;
  final String notificationType;
  final bool isRead;
  final DateTime sentAt;
  final DateTime? readAt;
  final Map<String, dynamic>? data; // Additional action data

  const NotificationEntity({
    required this.id,
    required this.userId,
    this.notificationTemplateId,
    required this.title,
    required this.body,
    required this.notificationType,
    required this.isRead,
    required this.sentAt,
    this.readAt,
    this.data,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        notificationTemplateId,
        title,
        body,
        notificationType,
        isRead,
        sentAt,
        readAt,
        data,
      ];

  /// Get relative time string (e.g., "2 hours ago")
  String getRelativeTime() {
    final now = DateTime.now();
    final difference = now.difference(sentAt);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else {
      return '${(difference.inDays / 30).floor()}mo ago';
    }
  }

  /// Get action route based on notification type and data
  String? getActionRoute() {
    switch (notificationType) {
      case 'payment':
        if (data?['status'] == 'approved' || data?['status'] == 'rejected') {
          return '/payment-history';
        }
        return '/submit-payment';
      case 'penalty':
        return '/penalty-history';
      case 'excuse':
        return '/excuses';
      case 'deadline':
        return '/today-deeds';
      case 'account':
        if (data?['status'] == 'deactivated') {
          return '/submit-payment';
        }
        return '/home';
      default:
        return null;
    }
  }

  /// Copy with method
  NotificationEntity copyWith({
    String? id,
    String? userId,
    String? notificationTemplateId,
    String? title,
    String? body,
    String? notificationType,
    bool? isRead,
    DateTime? sentAt,
    DateTime? readAt,
    Map<String, dynamic>? data,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      notificationTemplateId:
          notificationTemplateId ?? this.notificationTemplateId,
      title: title ?? this.title,
      body: body ?? this.body,
      notificationType: notificationType ?? this.notificationType,
      isRead: isRead ?? this.isRead,
      sentAt: sentAt ?? this.sentAt,
      readAt: readAt ?? this.readAt,
      data: data ?? this.data,
    );
  }
}

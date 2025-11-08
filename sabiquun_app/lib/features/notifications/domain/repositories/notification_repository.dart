import 'package:sabiquun_app/features/notifications/domain/entities/notification_entity.dart';

/// Abstract repository for notifications
abstract class NotificationRepository {
  /// Get notifications for a user
  Future<List<NotificationEntity>> getNotifications({
    required String userId,
    int? limit,
    int? offset,
    bool? unreadOnly,
  });

  /// Get unread notification count
  Future<int> getUnreadCount(String userId);

  /// Mark notification as read
  Future<void> markAsRead(String notificationId);

  /// Mark all notifications as read for a user
  Future<void> markAllAsRead(String userId);

  /// Delete a notification
  Future<void> deleteNotification(String notificationId);

  /// Subscribe to real-time notifications for a user
  Stream<NotificationEntity> subscribeToNotifications(String userId);
}

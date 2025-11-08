import 'package:sabiquun_app/features/notifications/data/datasources/notification_remote_datasource.dart';
import 'package:sabiquun_app/features/notifications/domain/entities/notification_entity.dart';
import 'package:sabiquun_app/features/notifications/domain/repositories/notification_repository.dart';

/// Implementation of NotificationRepository
class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDatasource remoteDatasource;

  NotificationRepositoryImpl({required this.remoteDatasource});

  @override
  Future<List<NotificationEntity>> getNotifications({
    required String userId,
    int? limit,
    int? offset,
    bool? unreadOnly,
  }) async {
    try {
      final models = await remoteDatasource.getNotifications(
        userId: userId,
        limit: limit ?? 20,
        offset: offset ?? 0,
        unreadOnly: unreadOnly ?? false,
      );
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get notifications: $e');
    }
  }

  @override
  Future<int> getUnreadCount(String userId) async {
    try {
      return await remoteDatasource.getUnreadCount(userId);
    } catch (e) {
      throw Exception('Failed to get unread count: $e');
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await remoteDatasource.markAsRead(notificationId);
    } catch (e) {
      throw Exception('Failed to mark as read: $e');
    }
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    try {
      await remoteDatasource.markAllAsRead(userId);
    } catch (e) {
      throw Exception('Failed to mark all as read: $e');
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      await remoteDatasource.deleteNotification(notificationId);
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  @override
  Stream<NotificationEntity> subscribeToNotifications(String userId) {
    try {
      return remoteDatasource
          .subscribeToNotifications(userId)
          .map((model) => model.toEntity());
    } catch (e) {
      throw Exception('Failed to subscribe to notifications: $e');
    }
  }
}

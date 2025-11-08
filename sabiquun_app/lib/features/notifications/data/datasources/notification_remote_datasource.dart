import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sabiquun_app/features/notifications/data/models/notification_model.dart';

/// Remote data source for notifications using Supabase
class NotificationRemoteDatasource {
  final SupabaseClient supabaseClient;

  NotificationRemoteDatasource({required this.supabaseClient});

  /// Get notifications for a user with pagination
  Future<List<NotificationModel>> getNotifications({
    required String userId,
    int limit = 20,
    int offset = 0,
    bool unreadOnly = false,
  }) async {
    try {
      var query = supabaseClient
          .from('notifications_log')
          .select()
          .eq('user_id', userId);

      if (unreadOnly) {
        query = query.eq('is_read', false);
      }

      final response = await query
          .order('sent_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  /// Get unread notification count
  Future<int> getUnreadCount(String userId) async {
    try {
      final response = await supabaseClient
          .rpc('get_unread_notification_count', params: {'p_user_id': userId});

      return response as int;
    } catch (e) {
      throw Exception('Failed to get unread count: $e');
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await supabaseClient
          .from('notifications_log')
          .update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('id', notificationId);
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  /// Mark all notifications as read for a user
  Future<void> markAllAsRead(String userId) async {
    try {
      await supabaseClient
          .from('notifications_log')
          .update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .eq('is_read', false);
    } catch (e) {
      throw Exception('Failed to mark all as read: $e');
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await supabaseClient
          .from('notifications_log')
          .delete()
          .eq('id', notificationId);
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  /// Subscribe to real-time notifications for a user
  Stream<NotificationModel> subscribeToNotifications(String userId) {
    final controller = StreamController<NotificationModel>();

    final subscription = supabaseClient
        .from('notifications_log')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('sent_at', ascending: false)
        .listen((List<Map<String, dynamic>> data) {
          if (data.isNotEmpty) {
            // Get the most recent notification
            final latestNotification = NotificationModel.fromJson(data.first);
            controller.add(latestNotification);
          }
        });

    controller.onCancel = () {
      subscription.cancel();
    };

    return controller.stream;
  }
}

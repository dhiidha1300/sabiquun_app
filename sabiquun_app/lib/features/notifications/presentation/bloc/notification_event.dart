import 'package:equatable/equatable.dart';

/// Base class for notification events
abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load notifications
class LoadNotificationsRequested extends NotificationEvent {
  final String userId;
  final bool unreadOnly;
  final bool refresh;

  const LoadNotificationsRequested({
    required this.userId,
    this.unreadOnly = false,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [userId, unreadOnly, refresh];
}

/// Event to load more notifications (pagination)
class LoadMoreNotificationsRequested extends NotificationEvent {
  final String userId;
  final bool unreadOnly;

  const LoadMoreNotificationsRequested({
    required this.userId,
    this.unreadOnly = false,
  });

  @override
  List<Object?> get props => [userId, unreadOnly];
}

/// Event to mark notification as read
class MarkNotificationAsReadRequested extends NotificationEvent {
  final String notificationId;

  const MarkNotificationAsReadRequested(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

/// Event to mark all notifications as read
class MarkAllNotificationsAsReadRequested extends NotificationEvent {
  final String userId;

  const MarkAllNotificationsAsReadRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Event to delete notification
class DeleteNotificationRequested extends NotificationEvent {
  final String notificationId;

  const DeleteNotificationRequested(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

/// Event when a new notification is received (real-time)
class NewNotificationReceived extends NotificationEvent {
  final String? userId;

  const NewNotificationReceived({this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Event to refresh unread count
class RefreshUnreadCountRequested extends NotificationEvent {
  final String userId;

  const RefreshUnreadCountRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

import 'package:equatable/equatable.dart';
import 'package:sabiquun_app/features/notifications/domain/entities/notification_entity.dart';

/// Base class for notification states
abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

/// Loading state
class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

/// Loading more (pagination)
class NotificationLoadingMore extends NotificationState {
  final List<NotificationEntity> currentNotifications;
  final int unreadCount;

  const NotificationLoadingMore({
    required this.currentNotifications,
    required this.unreadCount,
  });

  @override
  List<Object?> get props => [currentNotifications, unreadCount];
}

/// Loaded state
class NotificationLoaded extends NotificationState {
  final List<NotificationEntity> notifications;
  final int unreadCount;
  final bool hasMore;
  final int currentPage;

  const NotificationLoaded({
    required this.notifications,
    required this.unreadCount,
    this.hasMore = true,
    this.currentPage = 0,
  });

  @override
  List<Object?> get props => [notifications, unreadCount, hasMore, currentPage];

  NotificationLoaded copyWith({
    List<NotificationEntity>? notifications,
    int? unreadCount,
    bool? hasMore,
    int? currentPage,
  }) {
    return NotificationLoaded(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

/// Error state
class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Action success state (mark as read, delete, etc.)
class NotificationActionSuccess extends NotificationState {
  final String message;
  final List<NotificationEntity> notifications;
  final int unreadCount;

  const NotificationActionSuccess({
    required this.message,
    required this.notifications,
    required this.unreadCount,
  });

  @override
  List<Object?> get props => [message, notifications, unreadCount];
}

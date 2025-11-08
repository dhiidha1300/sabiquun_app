import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sabiquun_app/features/notifications/domain/entities/notification_entity.dart';
import 'package:sabiquun_app/features/notifications/domain/repositories/notification_repository.dart';
import 'package:sabiquun_app/features/notifications/presentation/bloc/notification_event.dart';
import 'package:sabiquun_app/features/notifications/presentation/bloc/notification_state.dart';

/// BLoC for managing notifications
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository repository;
  StreamSubscription? _notificationSubscription;
  static const int _pageSize = 20;

  NotificationBloc({required this.repository})
      : super(const NotificationInitial()) {
    on<LoadNotificationsRequested>(_onLoadNotificationsRequested);
    on<LoadMoreNotificationsRequested>(_onLoadMoreNotificationsRequested);
    on<MarkNotificationAsReadRequested>(_onMarkNotificationAsReadRequested);
    on<MarkAllNotificationsAsReadRequested>(
        _onMarkAllNotificationsAsReadRequested);
    on<DeleteNotificationRequested>(_onDeleteNotificationRequested);
    on<NewNotificationReceived>(_onNewNotificationReceived);
    on<RefreshUnreadCountRequested>(_onRefreshUnreadCountRequested);
  }

  /// Load notifications
  Future<void> _onLoadNotificationsRequested(
    LoadNotificationsRequested event,
    Emitter<NotificationState> emit,
  ) async {
    if (!event.refresh) {
      emit(const NotificationLoading());
    }

    try {
      final notifications = await repository.getNotifications(
        userId: event.userId,
        limit: _pageSize,
        offset: 0,
        unreadOnly: event.unreadOnly,
      );

      final unreadCount = await repository.getUnreadCount(event.userId);

      emit(NotificationLoaded(
        notifications: notifications,
        unreadCount: unreadCount,
        hasMore: notifications.length >= _pageSize,
        currentPage: 0,
      ));

      // Subscribe to real-time updates
      _subscribeToNotifications(event.userId);
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  /// Load more notifications (pagination)
  Future<void> _onLoadMoreNotificationsRequested(
    LoadMoreNotificationsRequested event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is! NotificationLoaded) return;

    final currentState = state as NotificationLoaded;
    if (!currentState.hasMore) return;

    emit(NotificationLoadingMore(
      currentNotifications: currentState.notifications,
      unreadCount: currentState.unreadCount,
    ));

    try {
      final nextPage = currentState.currentPage + 1;
      final moreNotifications = await repository.getNotifications(
        userId: event.userId,
        limit: _pageSize,
        offset: nextPage * _pageSize,
        unreadOnly: event.unreadOnly,
      );

      final allNotifications = [
        ...currentState.notifications,
        ...moreNotifications,
      ];

      emit(NotificationLoaded(
        notifications: allNotifications,
        unreadCount: currentState.unreadCount,
        hasMore: moreNotifications.length >= _pageSize,
        currentPage: nextPage,
      ));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  /// Mark notification as read
  Future<void> _onMarkNotificationAsReadRequested(
    MarkNotificationAsReadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is! NotificationLoaded) return;

    final currentState = state as NotificationLoaded;

    try {
      await repository.markAsRead(event.notificationId);

      // Update local state
      final updatedNotifications = currentState.notifications.map((n) {
        if (n.id == event.notificationId && !n.isRead) {
          return n.copyWith(isRead: true, readAt: DateTime.now());
        }
        return n;
      }).toList();

      // Get fresh unread count from database instead of counting local notifications
      final newUnreadCount = await repository.getUnreadCount(currentState.notifications.first.userId);

      emit(currentState.copyWith(
        notifications: updatedNotifications,
        unreadCount: newUnreadCount,
      ));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  /// Mark all notifications as read
  Future<void> _onMarkAllNotificationsAsReadRequested(
    MarkAllNotificationsAsReadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is! NotificationLoaded) return;

    final currentState = state as NotificationLoaded;

    try {
      await repository.markAllAsRead(event.userId);

      // Update local state
      final updatedNotifications = currentState.notifications
          .map((n) => n.copyWith(isRead: true, readAt: DateTime.now()))
          .toList();

      emit(NotificationActionSuccess(
        message: 'All notifications marked as read',
        notifications: updatedNotifications,
        unreadCount: 0,
      ));

      // Transition back to loaded state
      emit(currentState.copyWith(
        notifications: updatedNotifications,
        unreadCount: 0,
      ));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  /// Delete notification
  Future<void> _onDeleteNotificationRequested(
    DeleteNotificationRequested event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is! NotificationLoaded) return;

    final currentState = state as NotificationLoaded;

    try {
      await repository.deleteNotification(event.notificationId);

      // Update local state
      final updatedNotifications = currentState.notifications
          .where((n) => n.id != event.notificationId)
          .toList();

      // Get fresh unread count from database
      final userId = updatedNotifications.isNotEmpty
          ? updatedNotifications.first.userId
          : currentState.notifications.first.userId;
      final newUnreadCount = await repository.getUnreadCount(userId);

      emit(currentState.copyWith(
        notifications: updatedNotifications,
        unreadCount: newUnreadCount,
      ));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  /// Handle new notification received (real-time)
  Future<void> _onNewNotificationReceived(
    NewNotificationReceived event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;

      try {
        // Get the actual unread count from database
        final userId = currentState.notifications.isNotEmpty
            ? currentState.notifications.first.userId
            : event.userId;

        if (userId != null) {
          final unreadCount = await repository.getUnreadCount(userId);
          emit(currentState.copyWith(unreadCount: unreadCount));
        }
      } catch (e) {
        // Silently fail - keep current state
      }
    }
  }

  /// Refresh unread count
  Future<void> _onRefreshUnreadCountRequested(
    RefreshUnreadCountRequested event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final unreadCount = await repository.getUnreadCount(event.userId);

      if (state is NotificationLoaded) {
        final currentState = state as NotificationLoaded;
        emit(currentState.copyWith(unreadCount: unreadCount));
      }
    } catch (e) {
      // Silently fail for unread count refresh
    }
  }

  /// Subscribe to real-time notifications
  void _subscribeToNotifications(String userId) {
    _notificationSubscription?.cancel();
    _notificationSubscription = repository
        .subscribeToNotifications(userId)
        .listen((notification) {
      add(NewNotificationReceived(userId: userId));
    });
  }

  @override
  Future<void> close() {
    _notificationSubscription?.cancel();
    return super.close();
  }
}

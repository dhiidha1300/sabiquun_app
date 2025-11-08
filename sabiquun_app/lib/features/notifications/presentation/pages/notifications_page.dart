import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sabiquun_app/core/theme/app_colors.dart';
import 'package:sabiquun_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sabiquun_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:sabiquun_app/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:sabiquun_app/features/notifications/presentation/bloc/notification_event.dart';
import 'package:sabiquun_app/features/notifications/presentation/bloc/notification_state.dart';
import 'package:sabiquun_app/features/notifications/presentation/widgets/notification_item.dart';

/// Notifications center page
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showUnreadOnly = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      // Load more when scrolled 90% down
      final authState = context.read<AuthBloc>().state;
      if (authState is Authenticated) {
        context.read<NotificationBloc>().add(
              LoadMoreNotificationsRequested(
                userId: authState.user.id,
                unreadOnly: _showUnreadOnly,
              ),
            );
      }
    }
  }

  Future<void> _onRefresh() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<NotificationBloc>().add(
            LoadNotificationsRequested(
              userId: authState.user.id,
              unreadOnly: _showUnreadOnly,
              refresh: true,
            ),
          );
    }
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! Authenticated) {
          return const Scaffold(
            body: Center(child: Text('Please log in')),
          );
        }

        final userId = authState.user.id;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: AppColors.textPrimary,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text(
              'Notifications',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            actions: [
              // Filter toggle
              IconButton(
                icon: Icon(
                  _showUnreadOnly
                      ? Icons.mark_email_read
                      : Icons.mark_email_unread,
                  color: _showUnreadOnly
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
                onPressed: () {
                  setState(() {
                    _showUnreadOnly = !_showUnreadOnly;
                  });
                  context.read<NotificationBloc>().add(
                        LoadNotificationsRequested(
                          userId: userId,
                          unreadOnly: _showUnreadOnly,
                        ),
                      );
                },
                tooltip: _showUnreadOnly ? 'Show all' : 'Show unread only',
              ),
              // Mark all as read
              BlocBuilder<NotificationBloc, NotificationState>(
                builder: (context, state) {
                  final hasUnread = state is NotificationLoaded &&
                      state.unreadCount > 0;

                  return IconButton(
                    icon: Icon(
                      Icons.done_all,
                      color: hasUnread
                          ? AppColors.primary
                          : AppColors.textHint,
                    ),
                    onPressed: hasUnread
                        ? () {
                            context.read<NotificationBloc>().add(
                                  MarkAllNotificationsAsReadRequested(userId),
                                );
                          }
                        : null,
                    tooltip: 'Mark all as read',
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: BlocConsumer<NotificationBloc, NotificationState>(
            listener: (context, state) {
              if (state is NotificationError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error,
                  ),
                );
              } else if (state is NotificationActionSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.success,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is NotificationLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (state is NotificationLoaded ||
                  state is NotificationLoadingMore ||
                  state is NotificationActionSuccess) {
                final notifications = state is NotificationLoaded
                    ? state.notifications
                    : state is NotificationLoadingMore
                        ? state.currentNotifications
                        : (state as NotificationActionSuccess).notifications;

                if (notifications.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: notifications.length +
                        (state is NotificationLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == notifications.length) {
                        // Loading indicator for pagination
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final notification = notifications[index];

                      return NotificationItem(
                        notification: notification,
                        onTap: () {
                          // Mark as read when tapped
                          if (!notification.isRead) {
                            context.read<NotificationBloc>().add(
                                  MarkNotificationAsReadRequested(
                                    notification.id,
                                  ),
                                );
                          }
                        },
                        onMarkAsRead: () {
                          context.read<NotificationBloc>().add(
                                MarkNotificationAsReadRequested(
                                  notification.id,
                                ),
                              );
                        },
                        onDismiss: () {
                          context.read<NotificationBloc>().add(
                                DeleteNotificationRequested(notification.id),
                              );
                        },
                      );
                    },
                  ),
                );
              }

              // Initial state - trigger load
              context.read<NotificationBloc>().add(
                    LoadNotificationsRequested(userId: userId),
                  );

              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.1),
                    AppColors.secondary.withValues(alpha: 0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _showUnreadOnly
                    ? Icons.mark_email_read
                    : Icons.notifications_off_outlined,
                size: 64,
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _showUnreadOnly
                  ? 'No unread notifications'
                  : 'No notifications yet',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _showUnreadOnly
                  ? 'You\'re all caught up!'
                  : 'We\'ll notify you when something new happens',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

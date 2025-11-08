import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sabiquun_app/core/theme/app_colors.dart';
import 'package:sabiquun_app/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:sabiquun_app/features/notifications/presentation/bloc/notification_event.dart';
import 'package:sabiquun_app/features/notifications/presentation/bloc/notification_state.dart';

/// Notification bell icon with unread badge
class NotificationBell extends StatelessWidget {
  final String userId;

  const NotificationBell({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        int unreadCount = 0;

        if (state is NotificationLoaded) {
          unreadCount = state.unreadCount;
        } else if (state is NotificationLoadingMore) {
          unreadCount = state.unreadCount;
        } else if (state is NotificationActionSuccess) {
          unreadCount = state.unreadCount;
        }

        // Load notifications if not loaded yet
        if (state is NotificationInitial) {
          context.read<NotificationBloc>().add(
                LoadNotificationsRequested(userId: userId),
              );
        }

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.1),
                    AppColors.secondary.withValues(alpha: 0.08),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: IconButton(
                onPressed: () {
                  context.push('/notifications');
                },
                icon: Icon(
                  unreadCount > 0
                      ? Icons.notifications
                      : Icons.notifications_outlined,
                  color: AppColors.primary,
                  size: 24,
                ),
                tooltip: 'Notifications',
              ),
            ),
            if (unreadCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.symmetric(
                    horizontal: unreadCount > 9 ? 6 : 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.red.shade600,
                        Colors.red.shade700,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.4),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    unreadCount > 99 ? '99+' : unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

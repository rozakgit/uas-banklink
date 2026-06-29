import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/notification_entity.dart';
import '../../blocs/notification/notification_bloc.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('id', timeago.IdMessages());
    timeago.setLocaleMessages('id_short', timeago.IdShortMessages());
  }

  void _markAllAsRead(BuildContext context) {
    context.read<NotificationBloc>().add(NotificationMarkAllAsReadRequested());
  }

  void _markAsRead(BuildContext context, int id) {
    context.read<NotificationBloc>().add(NotificationMarkAsReadRequested(id));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : AppColors.lightTextPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Notifikasi',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.lightTextPrimary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Tandai semua dibaca',
            icon: const Icon(Icons.done_all, color: AppColors.bluePrimary),
            onPressed: () => _markAllAsRead(context),
          ),
        ],
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading || state is NotificationInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.bluePrimary),
            );
          } else if (state is NotificationError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: AppColors.danger),
              ),
            );
          } else if (state is NotificationLoaded) {
            final notifications = state.notifications;
            if (notifications.isEmpty) {
              return _buildEmptyState(isDark);
            }
            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return _buildNotificationCard(context, notif, isDark);
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined,
              size: 64, color: isDark ? Colors.white24 : Colors.black12),
          const SizedBox(height: 16),
          Text(
            'Belum ada notifikasi',
            style: TextStyle(
              fontFamily: 'Inter',
              color: isDark ? Colors.white54 : AppColors.lightTextSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, NotificationEntity notif, bool isDark) {
    return GestureDetector(
      onTap: () {
        if (!notif.isRead) {
          _markAsRead(context, notif.id);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notif.isRead
              ? (isDark ? Colors.black.withValues(alpha: 0.3) : Colors.white)
              : (isDark ? AppColors.bluePrimary.withValues(alpha: 0.1) : AppColors.blueLight.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notif.isRead
                ? (isDark ? Colors.white24 : AppColors.lightLine)
                : AppColors.bluePrimary.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: (isDark || notif.isRead) ? [] : [
            BoxShadow(
              color: AppColors.bluePrimary.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: notif.isRead
                    ? (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03))
                    : AppColors.bluePrimary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                notif.isRead ? Icons.notifications_none : Icons.notifications_active,
                color: notif.isRead ? (isDark ? Colors.white54 : AppColors.lightTextSecondary) : AppColors.bluePrimary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.bold,
                            color: notif.isRead ? (isDark ? Colors.white70 : AppColors.lightTextPrimary) : (isDark ? Colors.white : AppColors.lightTextPrimary),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        timeago.format(notif.createdAt, locale: 'id_short'),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          color: notif.isRead
                              ? (isDark ? Colors.white38 : AppColors.lightTextSecondary)
                              : AppColors.bluePrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notif.body,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: notif.isRead ? (isDark ? Colors.white54 : AppColors.lightTextSecondary) : (isDark ? Colors.white70 : AppColors.lightTextPrimary),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheelspe_provider/core/constants/app_colors.dart';
import 'package:wheelspe_provider/core/constants/app_text_styles.dart';
import 'package:wheelspe_provider/core/utils/date_formatter.dart';
import 'package:wheelspe_provider/features/notifications/data/notification_model.dart';
import 'package:wheelspe_provider/features/notifications/presentation/notifications_providers.dart';
import 'package:wheelspe_provider/shared/widgets/empty_state.dart';
import 'package:wheelspe_provider/shared/widgets/error_state.dart';
import 'package:wheelspe_provider/shared/widgets/shimmer_card.dart';
import 'package:wheelspe_provider/shared/widgets/snackbars.dart';
import 'package:wheelspe_provider/shared/widgets/wheelspe_card.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(notificationsProvider);
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        actions: [
          TextButton(
            onPressed: () async {
              try {
                await ref.read(notificationActionsProvider).markAllRead();
              } catch (e) {
                if (context.mounted) showErrorSnackBar(context, e);
              }
            },
            child: const Text('Marcar todo'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(notificationsProvider),
        child: async.when(
          loading: () => ListView(
            padding: const EdgeInsets.all(16),
            children: const [
              ShimmerCard(height: 80),
              SizedBox(height: 12),
              ShimmerCard(height: 80),
            ],
          ),
          error: (e, _) =>
              ErrorState(onRetry: () => ref.invalidate(notificationsProvider)),
          data: (items) {
            if (items.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  EmptyState(
                    icon: Icons.notifications_none,
                    title: 'Sin notificaciones',
                    message: 'Aquí verás avisos de reservas, pagos y mensajes.',
                  ),
                ],
              );
            }
            return ListView.separated(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) =>
                  _NotificationTile(item: items[i], locale: locale),
            );
          },
        ),
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  final NotificationModel item;
  final String locale;

  const _NotificationTile({required this.item, required this.locale});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.error),
      ),
      onDismissed: (_) =>
          ref.read(notificationActionsProvider).delete(item.id),
      child: WheelsPeCard(
        onTap: item.read
            ? null
            : () => ref.read(notificationActionsProvider).markRead(item.id),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(top: 6, right: 12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: item.read ? AppColors.divider : AppColors.primary,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: AppTextStyles.body.copyWith(
                      fontWeight:
                          item.read ? FontWeight.w400 : FontWeight.w700,
                    ),
                  ),
                  if (item.body.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(item.body, style: AppTextStyles.bodySecondary),
                  ],
                  if (item.createdAt != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      DateFormatter.fullDateTime(item.createdAt!, locale),
                      style: AppTextStyles.caption,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

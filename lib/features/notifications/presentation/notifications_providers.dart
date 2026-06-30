import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheelspe_provider/core/network/dio_client.dart';
import 'package:wheelspe_provider/features/notifications/data/notification_model.dart';
import 'package:wheelspe_provider/features/notifications/data/notifications_remote_datasource.dart';
import 'package:wheelspe_provider/shared/providers/user_provider.dart';

final notificationsDataSourceProvider =
    Provider<NotificationsRemoteDataSource>(
  (ref) => NotificationsRemoteDataSource(ref.watch(dioProvider)),
);

/// Bandeja de notificaciones del usuario autenticado.
final notificationsProvider =
    FutureProvider<List<NotificationModel>>((ref) async {
  final userId = await ref.watch(currentUserIdProvider.future);
  if (userId == null) return const [];
  return ref.watch(notificationsDataSourceProvider).getByUser(userId);
});

/// Nº de notificaciones sin leer (para el badge del icono).
final unreadCountProvider = FutureProvider<int>((ref) async {
  final userId = await ref.watch(currentUserIdProvider.future);
  if (userId == null) return 0;
  return ref.watch(notificationsDataSourceProvider).unreadCount(userId);
});

class NotificationActions {
  final Ref _ref;

  const NotificationActions(this._ref);

  NotificationsRemoteDataSource get _ds =>
      _ref.read(notificationsDataSourceProvider);

  Future<void> markRead(String id) async {
    await _ds.markRead(id);
    _invalidate();
  }

  Future<void> markAllRead() async {
    final userId = await _ref.read(currentUserIdProvider.future);
    if (userId == null) return;
    await _ds.markAllRead(userId);
    _invalidate();
  }

  Future<void> delete(String id) async {
    await _ds.delete(id);
    _invalidate();
  }

  void _invalidate() {
    _ref.invalidate(notificationsProvider);
    _ref.invalidate(unreadCountProvider);
  }
}

final notificationActionsProvider =
    Provider<NotificationActions>((ref) => NotificationActions(ref));

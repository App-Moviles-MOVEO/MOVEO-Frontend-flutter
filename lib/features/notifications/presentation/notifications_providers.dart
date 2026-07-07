import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheelspe_provider/core/network/dio_client.dart';
import 'package:wheelspe_provider/features/chat/presentation/chat_providers.dart';
import 'package:wheelspe_provider/features/fleet/presentation/fleet_providers.dart';
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

/// Notificaciones sintetizadas en cliente a partir de eventos que el backend
/// aún no emite en `/Notifications`: solicitudes de reserva PENDING y mensajes
/// de chat sin leer. Así el proveedor recibe el aviso aunque el backend no lo
/// genere. El id lleva el prefijo `synthetic:` para distinguirlas.
final syntheticNotificationsProvider =
    FutureProvider<List<NotificationModel>>((ref) async {
  final result = <NotificationModel>[];

  // Solicitudes de reserva pendientes → "Nueva solicitud de reserva".
  final pending = await ref.watch(pendingReservationsProvider.future);
  for (final r in pending) {
    result.add(NotificationModel(
      id: 'synthetic:reservation:${r.id}',
      title: 'Nueva solicitud de reserva',
      body: '${r.renterName} quiere reservar ${r.vehicleName}',
      type: 'reservation',
      createdAt: r.createdAt ?? r.startDate,
    ));
  }

  // Mensajes de chat sin leer → "Nuevo mensaje de {nombre}".
  final conversations = await ref.watch(conversationsProvider.future);
  for (final c in conversations.where((c) => c.unreadCount > 0)) {
    result.add(NotificationModel(
      id: 'synthetic:chat:${c.otherUserId}',
      title: 'Nuevo mensaje de ${c.otherUserName}',
      body: c.lastMessage,
      type: 'chat',
      createdAt: c.lastDate,
    ));
  }

  return result;
});

/// Bandeja combinada: notificaciones sintéticas (reservas/mensajes) + las del
/// backend, ordenadas por fecha descendente. Es la que consume la pantalla.
final notificationsFeedProvider =
    FutureProvider<List<NotificationModel>>((ref) async {
  final synthetic = await ref.watch(syntheticNotificationsProvider.future);
  final backend = await ref.watch(notificationsProvider.future);
  final all = [...synthetic, ...backend];
  all.sort((a, b) {
    final da = a.createdAt;
    final db = b.createdAt;
    if (da == null && db == null) return 0;
    if (da == null) return 1;
    if (db == null) return -1;
    return db.compareTo(da);
  });
  return all;
});

/// Nº de notificaciones sin leer (para el badge del icono): las del backend
/// más las sintéticas (reservas pendientes + chats sin leer).
final unreadCountProvider = FutureProvider<int>((ref) async {
  final userId = await ref.watch(currentUserIdProvider.future);
  if (userId == null) return 0;
  final backend =
      await ref.watch(notificationsDataSourceProvider).unreadCount(userId);
  final synthetic =
      await ref.watch(syntheticNotificationsProvider.future);
  return backend + synthetic.length;
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

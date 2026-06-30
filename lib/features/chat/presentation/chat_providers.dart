import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheelspe_provider/core/network/dio_client.dart';
import 'package:wheelspe_provider/features/chat/data/chat_models.dart';
import 'package:wheelspe_provider/features/chat/data/chat_remote_datasource.dart';
import 'package:wheelspe_provider/shared/providers/user_provider.dart';

final chatDataSourceProvider = Provider<ChatRemoteDataSource>(
  (ref) => ChatRemoteDataSource(ref.watch(dioProvider)),
);

/// Lista de conversaciones del usuario autenticado.
final conversationsProvider =
    FutureProvider<List<ConversationModel>>((ref) async {
  final userId = await ref.watch(currentUserIdProvider.future);
  if (userId == null) return const [];
  return ref.watch(chatDataSourceProvider).getConversations(userId);
});

/// Hilo de mensajes con otro usuario.
final chatThreadProvider =
    FutureProvider.family<List<MessageModel>, String>((ref, otherUserId) async {
  final userId = await ref.watch(currentUserIdProvider.future);
  if (userId == null) return const [];
  final ds = ref.watch(chatDataSourceProvider);
  final thread = await ds.getThread(userId, otherUserId);
  // Marca como leídos al abrir la conversación.
  await ds.markThreadRead(userId, otherUserId);
  return thread;
});

class ChatActions {
  final Ref _ref;

  const ChatActions(this._ref);

  Future<void> send(String otherUserId, String content) async {
    final userId = await _ref.read(currentUserIdProvider.future);
    if (userId == null) throw StateError('Sin sesión activa');
    await _ref.read(chatDataSourceProvider).send(
          senderId: userId,
          receiverId: otherUserId,
          content: content,
        );
    _ref.invalidate(chatThreadProvider(otherUserId));
    _ref.invalidate(conversationsProvider);
  }
}

final chatActionsProvider = Provider<ChatActions>((ref) => ChatActions(ref));

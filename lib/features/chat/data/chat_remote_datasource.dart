import 'package:dio/dio.dart';
import 'package:wheelspe_provider/core/constants/api_constants.dart';
import 'package:wheelspe_provider/core/network/dio_client.dart';
import 'package:wheelspe_provider/features/chat/data/chat_models.dart';

class ChatRemoteDataSource {
  final Dio _dio;

  const ChatRemoteDataSource(this._dio);

  Future<List<ConversationModel>> getConversations(String userId) async {
    try {
      final response =
          await _dio.get<dynamic>(ApiConstants.conversations(userId));
      return _asList(response.data)
          .map(ConversationModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throwAsAppException(e);
    }
  }

  Future<List<MessageModel>> getThread(
    String userId,
    String otherUserId,
  ) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiConstants.messages,
        queryParameters: {'userId': userId, 'otherUserId': otherUserId},
      );
      final list = _asList(response.data).map(MessageModel.fromJson).toList();
      list.sort((a, b) => (a.createdAt ?? DateTime(0))
          .compareTo(b.createdAt ?? DateTime(0)));
      return list;
    } on DioException catch (e) {
      throwAsAppException(e);
    }
  }

  Future<MessageModel> send({
    required String senderId,
    required String receiverId,
    required String content,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.messages,
        data: {
          'senderId': senderId,
          'receiverId': receiverId,
          'content': content,
        },
      );
      return MessageModel.fromJson(response.data ?? {});
    } on DioException catch (e) {
      throwAsAppException(e);
    }
  }

  /// Marca como leídos los mensajes recibidos del otro usuario.
  Future<void> markThreadRead(String userId, String otherUserId) async {
    try {
      await _dio.put<dynamic>(
        '${ApiConstants.messages}/read',
        queryParameters: {'userId': userId, 'otherUserId': otherUserId},
      );
    } on DioException catch (_) {
      // No crítico si falla.
    }
  }

  static List<Map<String, dynamic>> _asList(dynamic data) {
    if (data is List) return data.cast<Map<String, dynamic>>();
    if (data is Map && data['content'] is List) {
      return (data['content'] as List).cast<Map<String, dynamic>>();
    }
    if (data is Map && data['data'] is List) {
      return (data['data'] as List).cast<Map<String, dynamic>>();
    }
    if (data is Map && data['messages'] is List) {
      return (data['messages'] as List).cast<Map<String, dynamic>>();
    }
    return const [];
  }
}

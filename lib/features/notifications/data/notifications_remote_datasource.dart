import 'package:dio/dio.dart';
import 'package:wheelspe_provider/core/constants/api_constants.dart';
import 'package:wheelspe_provider/core/network/dio_client.dart';
import 'package:wheelspe_provider/features/notifications/data/notification_model.dart';

class NotificationsRemoteDataSource {
  final Dio _dio;

  const NotificationsRemoteDataSource(this._dio);

  Future<List<NotificationModel>> getByUser(String userId) async {
    try {
      final response =
          await _dio.get<dynamic>(ApiConstants.notificationsByUser(userId));
      return _asList(response.data).map(NotificationModel.fromJson).toList();
    } on DioException catch (e) {
      throwAsAppException(e);
    }
  }

  Future<int> unreadCount(String userId) async {
    try {
      final response =
          await _dio.get<dynamic>(ApiConstants.notificationsUnread(userId));
      return _asList(response.data).length;
    } on DioException catch (_) {
      return 0;
    }
  }

  Future<void> markRead(String id) async {
    try {
      await _dio.put<dynamic>(ApiConstants.notificationRead(id));
    } on DioException catch (e) {
      throwAsAppException(e);
    }
  }

  Future<void> markAllRead(String userId) async {
    try {
      await _dio.put<dynamic>(ApiConstants.notificationsReadAll(userId));
    } on DioException catch (e) {
      throwAsAppException(e);
    }
  }

  Future<void> delete(String id) async {
    try {
      await _dio.delete<dynamic>(ApiConstants.notificationById(id));
    } on DioException catch (e) {
      throwAsAppException(e);
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
    return const [];
  }
}

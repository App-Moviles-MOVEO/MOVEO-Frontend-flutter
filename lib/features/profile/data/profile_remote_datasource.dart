import 'package:dio/dio.dart';
import 'package:wheelspe_provider/core/constants/api_constants.dart';
import 'package:wheelspe_provider/core/network/dio_client.dart';

/// Reseña recibida de un arrendatario o pasajero.
class ReviewModel {
  final String authorName;
  final String? authorAvatar;
  final double score;
  final String comment;
  final DateTime? date;

  const ReviewModel({
    required this.authorName,
    this.authorAvatar,
    required this.score,
    this.comment = '',
    this.date,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
        authorName: (json['reviewerName'] ??
            json['authorName'] ??
            json['raterName'] ??
            'Usuario') as String,
        authorAvatar:
            (json['reviewerAvatar'] ?? json['authorAvatar'] ?? json['avatarUrl'])
                as String?,
        score: ((json['rating'] ?? json['score']) as num?)?.toDouble() ?? 0,
        comment: (json['comment'] ?? '') as String,
        date: DateTime.tryParse(
            (json['createdAt'] ?? json['date'] ?? '').toString()),
      );
}

class ProfileRemoteDataSource {
  final Dio _dio;

  const ProfileRemoteDataSource(this._dio);

  Future<void> updateUser(String id, Map<String, dynamic> changes) async {
    try {
      await _dio.put<dynamic>(ApiConstants.userById(id), data: changes);
    } on DioException catch (e) {
      throwAsAppException(e);
    }
  }

  /// Reseñas recibidas por el usuario: GET /user-reviews?reviewedUserId=.
  Future<List<ReviewModel>> getReviews(String userId) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiConstants.userReviews,
        queryParameters: {'reviewedUserId': userId},
      );
      final data = response.data;
      final list = data is List
          ? data.cast<Map<String, dynamic>>()
          : (data is Map && data['content'] is List)
              ? (data['content'] as List).cast<Map<String, dynamic>>()
              : (data is Map && data['data'] is List)
                  ? (data['data'] as List).cast<Map<String, dynamic>>()
                  : const <Map<String, dynamic>>[];
      return list.map(ReviewModel.fromJson).toList();
    } on DioException catch (e) {
      throwAsAppException(e);
    }
  }
}

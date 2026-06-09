import 'package:dio/dio.dart';
import 'package:wheelspe_provider/core/constants/api_constants.dart';
import 'package:wheelspe_provider/core/network/dio_client.dart';
import 'package:wheelspe_provider/features/auth/data/auth_models.dart';

class AuthRemoteDataSource {
  final Dio _dio;

  const AuthRemoteDataSource(this._dio);

  Future<LoginResult> login(String email, String password) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      return LoginResult.fromJson(response.data ?? {});
    } on DioException catch (e) {
      throwAsAppException(e);
    }
  }

  Future<LoginResult?> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.register,
        data: {
          'email': email,
          'password': password,
          'fullName': fullName,
          'phone': phone,
          'role': 'PROVIDER',
        },
      );
      final data = response.data;
      if (data == null || data['token'] == null) return null;
      return LoginResult.fromJson(data);
    } on DioException catch (e) {
      throwAsAppException(e);
    }
  }

  Future<void> uploadKyc({
    required String documentType,
    required String frontImagePath,
    required String backImagePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'documentType': documentType,
        'frontImage': await MultipartFile.fromFile(frontImagePath),
        'backImage': await MultipartFile.fromFile(backImagePath),
      });
      await _dio.post<dynamic>(ApiConstants.kycUpload, data: formData);
    } on DioException catch (e) {
      throwAsAppException(e);
    }
  }

  Future<KycStatusResult> getKycStatus() async {
    try {
      final response =
          await _dio.get<Map<String, dynamic>>(ApiConstants.kycStatus);
      return KycStatusResult.fromJson(response.data ?? {});
    } on DioException catch (e) {
      throwAsAppException(e);
    }
  }

  Future<UserModel> getUser(String id) async {
    try {
      final response =
          await _dio.get<Map<String, dynamic>>(ApiConstants.userById(id));
      return UserModel.fromJson(response.data ?? {});
    } on DioException catch (e) {
      throwAsAppException(e);
    }
  }

  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    try {
      await _dio.put<dynamic>(ApiConstants.userById(id), data: data);
    } on DioException catch (e) {
      throwAsAppException(e);
    }
  }

  Future<void> rateUser({
    required String raterId,
    required String rateeId,
    required int score,
    String? comment,
  }) async {
    try {
      await _dio.post<dynamic>(
        ApiConstants.rateUser,
        data: {
          'raterId': raterId,
          'rateeId': rateeId,
          'score': score,
          'comment': comment,
        },
      );
    } on DioException catch (e) {
      throwAsAppException(e);
    }
  }
}

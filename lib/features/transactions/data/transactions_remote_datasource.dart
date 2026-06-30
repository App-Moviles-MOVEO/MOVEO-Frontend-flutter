import 'package:dio/dio.dart';
import 'package:wheelspe_provider/core/constants/api_constants.dart';
import 'package:wheelspe_provider/core/network/dio_client.dart';
import 'package:wheelspe_provider/features/transactions/data/transaction_model.dart';

class TransactionsRemoteDataSource {
  final Dio _dio;

  const TransactionsRemoteDataSource(this._dio);

  List<Map<String, dynamic>> _asList(dynamic data) => data is List
      ? data.cast<Map<String, dynamic>>()
      : (data is Map && data['content'] is List)
          ? (data['content'] as List).cast<Map<String, dynamic>>()
          : (data is Map && data['data'] is List)
              ? (data['data'] as List).cast<Map<String, dynamic>>()
              : const <Map<String, dynamic>>[];

  /// Ingresos del proveedor: GET /Payments/recipient/{id}.
  Future<List<TransactionModel>> getByRecipient(String userId) async {
    try {
      final response = await _dio
          .get<dynamic>(ApiConstants.paymentsByRecipient(userId));
      return _asList(response.data).map(TransactionModel.fromJson).toList();
    } on DioException catch (e) {
      throwAsAppException(e);
    }
  }

  Future<TransactionModel> getById(String id) async {
    try {
      final response =
          await _dio.get<Map<String, dynamic>>(ApiConstants.paymentById(id));
      return TransactionModel.fromJson(response.data ?? {});
    } on DioException catch (e) {
      throwAsAppException(e);
    }
  }

  /// Reembolso: PATCH /Payments/{id} con {status:"refunded"}.
  Future<void> refund(String id) async {
    try {
      await _dio.patch<dynamic>(
        ApiConstants.paymentById(id),
        data: {'status': 'refunded'},
      );
    } on DioException catch (e) {
      throwAsAppException(e);
    }
  }
}
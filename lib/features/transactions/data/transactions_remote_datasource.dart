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

  /// Reembolso con políticas (US26/US33): POST /payments/{id}/refund.
  /// Devuelve el monto reembolsado y la política aplicada.
  Future<RefundResult> refund(String id, {String? reason}) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.paymentRefund(id),
        data: {'reason': ?reason},
      );
      return RefundResult.fromJson(response.data ?? const {});
    } on DioException catch (e) {
      throwAsAppException(e);
    }
  }

  /// Saldo de la wallet: GET /wallet/{userId}.
  Future<WalletBalance> getWallet(String userId) async {
    try {
      final response =
          await _dio.get<Map<String, dynamic>>(ApiConstants.wallet(userId));
      return WalletBalance.fromJson(response.data ?? const {});
    } on DioException catch (e) {
      throwAsAppException(e);
    }
  }

  /// Historial de retiros: GET /withdrawals/user/{userId}.
  Future<List<WithdrawalModel>> getWithdrawals(String userId) async {
    try {
      final response = await _dio
          .get<dynamic>(ApiConstants.withdrawalsByUser(userId));
      return _asList(response.data).map(WithdrawalModel.fromJson).toList();
    } on DioException catch (e) {
      throwAsAppException(e);
    }
  }

  /// Solicita un retiro: POST /withdrawals.
  Future<WithdrawalModel> requestWithdrawal({
    required String userId,
    required double amount,
    required String method,
    required String destination,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.withdrawals,
        data: {
          'userId': int.tryParse(userId) ?? userId,
          'amount': amount,
          'method': method,
          'destination': destination,
        },
      );
      return WithdrawalModel.fromJson(response.data ?? const {});
    } on DioException catch (e) {
      throwAsAppException(e);
    }
  }

  /// Comprobante server-side (US25): GET /rentals/{id}/invoice.
  Future<InvoiceModel> getInvoice(String rentalId) async {
    try {
      final response = await _dio
          .get<Map<String, dynamic>>(ApiConstants.rentalInvoice(rentalId));
      return InvoiceModel.fromJson(response.data ?? const {});
    } on DioException catch (e) {
      throwAsAppException(e);
    }
  }
}
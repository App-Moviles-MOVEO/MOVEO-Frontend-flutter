import 'package:wheelspe_provider/features/transactions/data/transaction_model.dart';
import 'package:wheelspe_provider/features/transactions/data/transactions_remote_datasource.dart';
import 'package:wheelspe_provider/features/transactions/domain/transactions_repository.dart';

class TransactionsRepositoryImpl implements TransactionsRepository {
  final TransactionsRemoteDataSource _remote;

  const TransactionsRepositoryImpl(this._remote);

  @override
  Future<List<TransactionModel>> getMyTransactions(String userId) =>
      _remote.getByRecipient(userId);

  @override
  Future<TransactionModel> getTransaction(String id) => _remote.getById(id);

  /// Comprobantes derivados de los cobros completados. El número oficial
  /// lo emite el backend en `GET /rentals/{id}/invoice` (ver detalle).
  @override
  Future<List<InvoiceModel>> getMyInvoices(String userId) async {
    final txs = await _remote.getByRecipient(userId);
    return [
      for (final t in txs)
        if (t.status == TransactionStatus.completed)
          InvoiceModel(
            id: t.id,
            transactionId: t.id,
            number: 'WPE-${t.id}',
            date: t.date,
          ),
    ];
  }

  @override
  Future<RefundResult> requestRefund(String id, {String? reason}) =>
      _remote.refund(id, reason: reason);

  @override
  Future<InvoiceModel> getRentalInvoice(String rentalId) =>
      _remote.getInvoice(rentalId);

  @override
  Future<WalletBalance> getWallet(String userId) => _remote.getWallet(userId);

  @override
  Future<List<WithdrawalModel>> getWithdrawals(String userId) =>
      _remote.getWithdrawals(userId);

  @override
  Future<WithdrawalModel> requestWithdrawal({
    required String userId,
    required double amount,
    required String method,
    required String destination,
  }) =>
      _remote.requestWithdrawal(
        userId: userId,
        amount: amount,
        method: method,
        destination: destination,
      );
}

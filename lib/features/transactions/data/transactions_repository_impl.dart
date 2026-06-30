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

  /// El backend NO tiene `/invoices`. Los comprobantes se derivan de los
  /// cobros completados y el PDF se genera en el dispositivo (ver detalle).
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
  Future<void> requestRefund(String id) => _remote.refund(id);
}

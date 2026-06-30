import 'package:wheelspe_provider/features/transactions/data/transaction_model.dart';

/// Contrato de cobros del proveedor.
abstract class TransactionsRepository {
  Future<List<TransactionModel>> getMyTransactions(String userId);

  Future<TransactionModel> getTransaction(String id);

  Future<List<InvoiceModel>> getMyInvoices(String userId);

  Future<void> requestRefund(String id);
}

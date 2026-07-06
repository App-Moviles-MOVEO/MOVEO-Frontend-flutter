import 'package:wheelspe_provider/features/transactions/data/transaction_model.dart';

/// Contrato de cobros del proveedor.
abstract class TransactionsRepository {
  Future<List<TransactionModel>> getMyTransactions(String userId);

  Future<TransactionModel> getTransaction(String id);

  Future<List<InvoiceModel>> getMyInvoices(String userId);

  Future<RefundResult> requestRefund(String id, {String? reason});

  Future<InvoiceModel> getRentalInvoice(String rentalId);

  Future<WalletBalance> getWallet(String userId);

  Future<List<WithdrawalModel>> getWithdrawals(String userId);

  Future<WithdrawalModel> requestWithdrawal({
    required String userId,
    required double amount,
    required String method,
    required String destination,
  });
}

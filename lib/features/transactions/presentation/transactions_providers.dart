import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheelspe_provider/core/network/dio_client.dart';
import 'package:wheelspe_provider/features/transactions/data/transaction_model.dart';
import 'package:wheelspe_provider/features/transactions/data/transactions_remote_datasource.dart';
import 'package:wheelspe_provider/features/transactions/data/transactions_repository_impl.dart';
import 'package:wheelspe_provider/features/transactions/domain/transactions_repository.dart';
import 'package:wheelspe_provider/shared/providers/user_provider.dart';

final transactionsRepositoryProvider = Provider<TransactionsRepository>(
  (ref) => TransactionsRepositoryImpl(
    TransactionsRemoteDataSource(ref.watch(dioProvider)),
  ),
);

/// Cobros recibidos por el proveedor autenticado.
final myTransactionsProvider =
    FutureProvider<List<TransactionModel>>((ref) async {
  final userId = await ref.watch(currentUserIdProvider.future);
  if (userId == null) return const [];
  return ref.watch(transactionsRepositoryProvider).getMyTransactions(userId);
});

final transactionDetailProvider =
    FutureProvider.family<TransactionModel, String>(
  (ref, id) => ref.watch(transactionsRepositoryProvider).getTransaction(id),
);

/// Facturas/comprobantes del proveedor.
final myInvoicesProvider = FutureProvider<List<InvoiceModel>>((ref) async {
  final userId = await ref.watch(currentUserIdProvider.future);
  if (userId == null) return const [];
  return ref.watch(transactionsRepositoryProvider).getMyInvoices(userId);
});

/// Resumen financiero derivado de los cobros completados.
class WalletSummary {
  final double balance;
  final double weekTotal;
  final double monthTotal;

  /// Ingresos por día de los últimos 7 días (índice 0 = hace 6 días).
  final List<double> last7Days;

  const WalletSummary({
    this.balance = 0,
    this.weekTotal = 0,
    this.monthTotal = 0,
    this.last7Days = const [0, 0, 0, 0, 0, 0, 0],
  });
}

final walletSummaryProvider = FutureProvider<WalletSummary>((ref) async {
  final transactions = await ref.watch(myTransactionsProvider.future);
  final completed = transactions
      .where((t) => t.status == TransactionStatus.completed)
      .toList();

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  double balance = 0;
  double week = 0;
  double month = 0;
  final daily = List<double>.filled(7, 0);

  for (final t in completed) {
    balance += t.netAmount;
    final day = DateTime(t.date.year, t.date.month, t.date.day);
    final daysAgo = today.difference(day).inDays;
    if (daysAgo < 7) {
      week += t.netAmount;
      daily[6 - daysAgo] += t.netAmount;
    }
    if (t.date.year == now.year && t.date.month == now.month) {
      month += t.netAmount;
    }
  }

  return WalletSummary(
    balance: balance,
    weekTotal: week,
    monthTotal: month,
    last7Days: daily,
  );
});

/// Acciones sobre transacciones.
class TransactionActions {
  final Ref _ref;

  const TransactionActions(this._ref);

  Future<void> requestRefund(String id) async {
    await _ref.read(transactionsRepositoryProvider).requestRefund(id);
    _ref.invalidate(transactionDetailProvider(id));
    _ref.invalidate(myTransactionsProvider);
    _ref.invalidate(walletSummaryProvider);
  }
}

final transactionActionsProvider =
    Provider<TransactionActions>((ref) => TransactionActions(ref));

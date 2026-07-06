import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheelspe_provider/core/storage/local_storage.dart';
import 'package:wheelspe_provider/features/moderation/domain/anomaly_detector.dart';
import 'package:wheelspe_provider/features/moderation/domain/dispute_mediator.dart';
import 'package:wheelspe_provider/features/profile/data/profile_remote_datasource.dart';
import 'package:wheelspe_provider/features/profile/presentation/profile_providers.dart';
import 'package:wheelspe_provider/features/transactions/presentation/transactions_providers.dart';

/// US40: anomalías financieras detectadas automáticamente sobre los cobros
/// del proveedor. Se recalculan solas cuando cambian las transacciones.
final financialAnomaliesProvider =
    FutureProvider<List<FinancialAnomaly>>((ref) async {
  final transactions = await ref.watch(myTransactionsProvider.future);
  return AnomalyDetector.scan(transactions);
});

/// US41: claves de reseñas cuya disputa procedió (excluidas de la reputación).
/// Persistidas localmente; la mediación es automática (sin admin).
final reviewDisputesProvider =
    NotifierProvider<ReviewDisputesNotifier, Set<String>>(
  ReviewDisputesNotifier.new,
);

class ReviewDisputesNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() =>
      ref.watch(localStorageProvider).loadDisputedReviewIds().toSet();

  Future<void> _persist(Set<String> keys) async {
    await ref.read(localStorageProvider).saveDisputedReviewIds(keys.toList());
    state = keys;
  }

  bool isExcluded(ReviewModel review) =>
      state.contains(DisputeMediator.keyOf(review));

  /// Resuelve la disputa de [review] automáticamente y persiste el resultado.
  /// Devuelve el resultado de la mediación.
  Future<DisputeOutcome> dispute(
    ReviewModel review,
    List<ReviewModel> all,
  ) async {
    final outcome =
        DisputeMediator.autoResolve(review: review, all: all);
    if (outcome == DisputeOutcome.upheld) {
      await _persist({...state, DisputeMediator.keyOf(review)});
    }
    return outcome;
  }

  /// Revierte una exclusión previa (reincorpora la reseña).
  Future<void> restore(ReviewModel review) async {
    final key = DisputeMediator.keyOf(review);
    if (!state.contains(key)) return;
    await _persist({...state}..remove(key));
  }
}

/// Reputación ajustada del proveedor tras la mediación automática (US41).
final adjustedReputationProvider = FutureProvider<double>((ref) async {
  final reviews = await ref.watch(myReviewsProvider.future);
  final excluded = ref.watch(reviewDisputesProvider);
  return DisputeMediator.adjustedAverage(
    reviews: reviews,
    excludedKeys: excluded,
  );
});

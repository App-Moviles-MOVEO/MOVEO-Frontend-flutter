import 'package:wheelspe_provider/features/profile/data/profile_remote_datasource.dart';

/// Resultado de la mediación automática de una disputa de reseña (US41).
enum DisputeOutcome {
  /// La disputa procede: la reseña se excluye del cálculo de reputación.
  upheld,

  /// La disputa no procede: la reseña se mantiene.
  rejected,
}

/// Mediador automático de disputas de reputación (US41). Sustituye la revisión
/// manual de un administrador por una política determinística: una reseña
/// disputada se excluye solo si es un voto bajo, atípico respecto al historial
/// del proveedor y sin justificación escrita (patrón de reseña injusta).
class DisputeMediator {
  DisputeMediator._();

  /// Clave estable para identificar una reseña (no trae id del backend).
  static String keyOf(ReviewModel review) => [
        review.authorName.trim().toLowerCase(),
        review.score.toStringAsFixed(1),
        review.comment.trim(),
        review.date?.toIso8601String() ?? '',
      ].join('|');

  static DisputeOutcome autoResolve({
    required ReviewModel review,
    required List<ReviewModel> all,
  }) {
    if (all.isEmpty) return DisputeOutcome.rejected;
    final scores = all.map((r) => r.score).toList()..sort();
    final median = scores[scores.length ~/ 2];

    final isLow = review.score <= 2;
    final isOutlier = median - review.score >= 2;
    final noJustification = review.comment.trim().length < 10;

    return (isLow && isOutlier && noJustification)
        ? DisputeOutcome.upheld
        : DisputeOutcome.rejected;
  }

  /// Promedio de reputación excluyendo las reseñas cuya disputa procedió.
  static double adjustedAverage({
    required List<ReviewModel> reviews,
    required Set<String> excludedKeys,
  }) {
    final kept = reviews
        .where((r) => !excludedKeys.contains(keyOf(r)))
        .map((r) => r.score)
        .toList();
    if (kept.isEmpty) return 0;
    return kept.reduce((a, b) => a + b) / kept.length;
  }
}

import 'dart:math';

import 'package:wheelspe_provider/features/transactions/data/transaction_model.dart';

/// Tipo de anomalía financiera detectada (US40).
enum AnomalyType {
  /// Cobro con un monto muy por encima del comportamiento habitual.
  amountOutlier,

  /// Dos cobros idénticos (mismo pagador y monto) el mismo día: posible
  /// duplicado.
  duplicateCharge,

  /// Proporción de reembolsos inusualmente alta en el histórico.
  refundSpike,
}

/// Una anomalía concreta detectada sobre las transacciones del proveedor.
class FinancialAnomaly {
  final AnomalyType type;

  /// Transacción implicada (vacío en anomalías agregadas como [refundSpike]).
  final String transactionId;
  final String label;
  final double amount;

  const FinancialAnomaly({
    required this.type,
    this.transactionId = '',
    this.label = '',
    this.amount = 0,
  });
}

/// Monitor automático de anomalías financieras (US40). Sustituye la revisión
/// manual de un administrador por un análisis determinístico sobre los cobros
/// del proveedor. Es puro y sin dependencias de UI.
class AnomalyDetector {
  AnomalyDetector._();

  /// Analiza [transactions] y devuelve las anomalías encontradas, ordenadas
  /// por monto descendente.
  static List<FinancialAnomaly> scan(List<TransactionModel> transactions) {
    final anomalies = <FinancialAnomaly>[];
    final completed = transactions
        .where((t) => t.status == TransactionStatus.completed)
        .toList();

    // 1) Montos atípicos (media + 3σ) — requiere una muestra mínima.
    if (completed.length >= 4) {
      final amounts = completed.map((t) => t.amount).toList();
      final mean = amounts.reduce((a, b) => a + b) / amounts.length;
      final variance = amounts
              .map((a) => (a - mean) * (a - mean))
              .reduce((a, b) => a + b) /
          amounts.length;
      final std = sqrt(variance);
      for (final t in completed) {
        if (std > 0 && t.amount > mean + 3 * std && t.amount > mean * 1.5) {
          anomalies.add(FinancialAnomaly(
            type: AnomalyType.amountOutlier,
            transactionId: t.id,
            label: t.payerName.isNotEmpty ? t.payerName : t.reference,
            amount: t.amount,
          ));
        }
      }
    }

    // 2) Cobros duplicados: mismo pagador + monto el mismo día.
    final seen = <String, TransactionModel>{};
    for (final t in completed) {
      final key = '${t.payerName.trim().toLowerCase()}|${t.amount}|'
          '${t.date.year}-${t.date.month}-${t.date.day}';
      if (seen.containsKey(key)) {
        anomalies.add(FinancialAnomaly(
          type: AnomalyType.duplicateCharge,
          transactionId: t.id,
          label: t.payerName.isNotEmpty ? t.payerName : t.reference,
          amount: t.amount,
        ));
      } else {
        seen[key] = t;
      }
    }

    // 3) Exceso de reembolsos en el histórico.
    final refunds =
        transactions.where((t) => t.status == TransactionStatus.refunded).length;
    if (transactions.length >= 5 &&
        refunds >= 3 &&
        refunds / transactions.length >= 0.3) {
      anomalies.add(FinancialAnomaly(
        type: AnomalyType.refundSpike,
        amount: refunds.toDouble(),
      ));
    }

    anomalies.sort((a, b) => b.amount.compareTo(a.amount));
    return anomalies;
  }
}

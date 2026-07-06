import 'dart:math';

/// Tipo de descuento de una promoción.
enum DiscountType {
  percent,
  fixed;

  String get apiValue => name;

  static DiscountType fromString(String? v) =>
      v == 'fixed' ? DiscountType.fixed : DiscountType.percent;
}

/// Resultado de intentar aplicar un cupón (US27).
enum CouponStatus {
  applied,
  notFound,
  notStarted,
  expired,
  disabled,
  reputationTooLow;

  bool get isSuccess => this == CouponStatus.applied;
}

/// Salida de la aplicación de un cupón: estado, descuento y precio final.
class CouponOutcome {
  final CouponStatus status;
  final double discount;
  final double finalAmount;
  final PromoOffer? promo;

  const CouponOutcome({
    required this.status,
    this.discount = 0,
    this.finalAmount = 0,
    this.promo,
  });
}

/// Oferta promocional temporal (US34). Puede exigir una reputación mínima,
/// lo que la convierte en una recompensa para usuarios de alta reputación (US29).
class PromoOffer {
  final String id;
  final String code;
  final String title;
  final DiscountType type;

  /// Porcentaje (0–100) o monto fijo en soles según [type].
  final double value;
  final DateTime startDate;
  final DateTime endDate;

  /// Reputación mínima del beneficiario. 0 = para cualquiera (US29 cuando > 0).
  final double minReputation;
  final bool enabled;

  const PromoOffer({
    required this.id,
    required this.code,
    required this.title,
    required this.type,
    required this.value,
    required this.startDate,
    required this.endDate,
    this.minReputation = 0,
    this.enabled = true,
  });

  /// Descuento en soles que aplicaría sobre [base] (nunca mayor que [base]).
  double discountOn(double base) {
    final raw = type == DiscountType.percent ? base * value / 100 : value;
    return min(raw, base).clamp(0, base).toDouble();
  }

  /// Vigente en [now] según fechas y estado (independiente de reputación).
  bool isLiveOn(DateTime now) =>
      enabled &&
      !now.isBefore(_dayStart(startDate)) &&
      !now.isAfter(_dayEnd(endDate));

  static DateTime _dayStart(DateTime d) => DateTime(d.year, d.month, d.day);
  static DateTime _dayEnd(DateTime d) =>
      DateTime(d.year, d.month, d.day, 23, 59, 59);

  /// Motor de aplicación de cupón (US27). Determinístico y puro: la app
  /// Renter usaría exactamente esta misma lógica al cobrar.
  static CouponOutcome apply({
    required List<PromoOffer> offers,
    required String code,
    required double amount,
    double reputation = 0,
    DateTime? now,
  }) {
    final today = now ?? DateTime.now();
    final normalized = code.trim().toUpperCase();
    final match = offers
        .where((o) => o.code.trim().toUpperCase() == normalized)
        .firstOrNull;

    if (match == null) {
      return const CouponOutcome(status: CouponStatus.notFound);
    }
    if (!match.enabled) {
      return CouponOutcome(status: CouponStatus.disabled, promo: match);
    }
    if (today.isBefore(_dayStart(match.startDate))) {
      return CouponOutcome(status: CouponStatus.notStarted, promo: match);
    }
    if (today.isAfter(_dayEnd(match.endDate))) {
      return CouponOutcome(status: CouponStatus.expired, promo: match);
    }
    if (reputation < match.minReputation) {
      return CouponOutcome(status: CouponStatus.reputationTooLow, promo: match);
    }
    final discount = match.discountOn(amount);
    return CouponOutcome(
      status: CouponStatus.applied,
      discount: discount,
      finalAmount: (amount - discount).clamp(0, amount).toDouble(),
      promo: match,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'title': title,
        'type': type.apiValue,
        'value': value,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'minReputation': minReputation,
        'enabled': enabled,
      };

  factory PromoOffer.fromJson(Map<String, dynamic> json) => PromoOffer(
        id: json['id']?.toString() ?? '',
        code: (json['code'] ?? '') as String,
        title: (json['title'] ?? '') as String,
        type: DiscountType.fromString(json['type'] as String?),
        value: (json['value'] as num?)?.toDouble() ?? 0,
        startDate:
            DateTime.tryParse('${json['startDate']}') ?? DateTime.now(),
        endDate: DateTime.tryParse('${json['endDate']}') ?? DateTime.now(),
        minReputation: (json['minReputation'] as num?)?.toDouble() ?? 0,
        enabled: json['enabled'] != false,
      );

  PromoOffer copyWith({bool? enabled}) => PromoOffer(
        id: id,
        code: code,
        title: title,
        type: type,
        value: value,
        startDate: startDate,
        endDate: endDate,
        minReputation: minReputation,
        enabled: enabled ?? this.enabled,
      );
}

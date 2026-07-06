import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheelspe_provider/core/storage/local_storage.dart';
import 'package:wheelspe_provider/features/promotions/data/promo_model.dart';

/// Lista de promociones del proveedor (US34). Persistida localmente hasta
/// que exista un endpoint de promociones en el backend.
final promotionsProvider =
    NotifierProvider<PromotionsNotifier, List<PromoOffer>>(
  PromotionsNotifier.new,
);

class PromotionsNotifier extends Notifier<List<PromoOffer>> {
  @override
  List<PromoOffer> build() {
    final raw = ref.watch(localStorageProvider).loadPromotions();
    return raw.map(PromoOffer.fromJson).toList();
  }

  Future<void> _persist(List<PromoOffer> offers) async {
    await ref
        .read(localStorageProvider)
        .savePromotions(offers.map((o) => o.toJson()).toList());
    state = offers;
  }

  Future<void> add(PromoOffer offer) => _persist([...state, offer]);

  Future<void> remove(String id) =>
      _persist(state.where((o) => o.id != id).toList());

  Future<void> toggle(String id) => _persist([
        for (final o in state)
          if (o.id == id) o.copyWith(enabled: !o.enabled) else o,
      ]);
}

/// Aplica un cupón sobre un monto (US27). Reutiliza el motor puro del modelo.
final applyCouponProvider =
    Provider<CouponOutcome Function(String, double, {double reputation})>(
  (ref) {
    final offers = ref.watch(promotionsProvider);
    return (code, amount, {reputation = 0}) => PromoOffer.apply(
          offers: offers,
          code: code,
          amount: amount,
          reputation: reputation,
        );
  },
);

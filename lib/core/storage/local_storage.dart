import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Claves de preferencias locales (datos no sensibles).
class LocalStorageKeys {
  LocalStorageKeys._();

  static const String locale = 'locale';
  static const String onboardingSeen = 'onboarding_seen';
  static const String kycDevBypass = 'kyc_dev_bypass';
  static const String reputationThreshold = 'reputation_threshold';
  static const String payoutMethods = 'payout_methods';
  static const String promotions = 'promotions';
  static const String alliances = 'alliances';
  static const String reviewDisputes = 'review_disputes';

  static String checklist(String reservationId, String tipo) =>
      'checklist_${reservationId}_$tipo';

  static String vehicleDocs(String vehicleId) => 'vehicle_docs_$vehicleId';
}

/// Wrapper sobre shared_preferences para preferencias de usuario
/// y el checklist fotográfico temporal.
class LocalStorageService {
  final SharedPreferences _prefs;

  const LocalStorageService(this._prefs);

  String? get locale => _prefs.getString(LocalStorageKeys.locale);

  Future<void> setLocale(String code) =>
      _prefs.setString(LocalStorageKeys.locale, code);

  bool get onboardingSeen =>
      _prefs.getBool(LocalStorageKeys.onboardingSeen) ?? false;

  Future<void> setOnboardingSeen() =>
      _prefs.setBool(LocalStorageKeys.onboardingSeen, true);

  /// Bypass de KYC solo para pruebas: permite entrar al home sin verificación
  /// aprobada por un admin. Persistido para que el usuario no rebote al KYC
  /// en cada arranque mientras prueba el flujo.
  bool get kycDevBypass =>
      _prefs.getBool(LocalStorageKeys.kycDevBypass) ?? false;

  Future<void> setKycDevBypass(bool value) =>
      _prefs.setBool(LocalStorageKeys.kycDevBypass, value);

  /// Guarda el checklist fotográfico como mapa punto → ruta de archivo local.
  Future<void> saveChecklist(
    String reservationId,
    String tipo,
    Map<String, String> photosByPoint,
  ) =>
      _prefs.setString(
        LocalStorageKeys.checklist(reservationId, tipo),
        jsonEncode(photosByPoint),
      );

  Map<String, String> loadChecklist(String reservationId, String tipo) {
    final raw = _prefs.getString(LocalStorageKeys.checklist(reservationId, tipo));
    if (raw == null) return {};
    return Map<String, String>.from(jsonDecode(raw) as Map);
  }

  /// Documentos de propiedad del vehículo (US05) como mapa
  /// tipo de documento → ruta de archivo local. El backend aún no los
  /// persiste, así que esta es la copia de referencia del proveedor.
  Future<void> saveVehicleDocs(String vehicleId, Map<String, String> docs) =>
      _prefs.setString(
        LocalStorageKeys.vehicleDocs(vehicleId),
        jsonEncode(docs),
      );

  Map<String, String> loadVehicleDocs(String vehicleId) {
    final raw = _prefs.getString(LocalStorageKeys.vehicleDocs(vehicleId));
    if (raw == null) return {};
    return Map<String, String>.from(jsonDecode(raw) as Map);
  }

  /// Umbral de reputación mínima para pasajeros (US30). 0 = sin umbral.
  double get reputationThreshold =>
      _prefs.getDouble(LocalStorageKeys.reputationThreshold) ?? 0;

  Future<void> setReputationThreshold(double value) =>
      _prefs.setDouble(LocalStorageKeys.reputationThreshold, value);

  /// Métodos de cobro guardados (US21): lista de mapas
  /// {alias, method, destination}.
  List<Map<String, String>> loadPayoutMethods() {
    final raw = _prefs.getString(LocalStorageKeys.payoutMethods);
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((e) => Map<String, String>.from(e as Map))
        .toList();
  }

  Future<void> savePayoutMethods(List<Map<String, String>> methods) =>
      _prefs.setString(LocalStorageKeys.payoutMethods, jsonEncode(methods));

  /// Promociones/ofertas del proveedor (US34/US27/US29): lista de mapas JSON.
  /// El backend aún no tiene endpoint de promociones; se persiste localmente.
  List<Map<String, dynamic>> loadPromotions() {
    final raw = _prefs.getString(LocalStorageKeys.promotions);
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<void> savePromotions(List<Map<String, dynamic>> promos) =>
      _prefs.setString(LocalStorageKeys.promotions, jsonEncode(promos));

  /// Solicitudes de alianza corporativa (US46): lista de mapas JSON. El
  /// backend no tiene endpoint de alianzas; se persiste localmente además de
  /// registrar el ticket de soporte.
  List<Map<String, dynamic>> loadAlliances() {
    final raw = _prefs.getString(LocalStorageKeys.alliances);
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<void> saveAlliances(List<Map<String, dynamic>> requests) =>
      _prefs.setString(LocalStorageKeys.alliances, jsonEncode(requests));

  /// Reseñas disputadas por el proveedor (US41): conjunto de ids de reseña
  /// que la mediación automática excluyó del cálculo de reputación.
  List<String> loadDisputedReviewIds() {
    final raw = _prefs.getString(LocalStorageKeys.reviewDisputes);
    if (raw == null) return [];
    return (jsonDecode(raw) as List).map((e) => e.toString()).toList();
  }

  Future<void> saveDisputedReviewIds(List<String> ids) =>
      _prefs.setString(LocalStorageKeys.reviewDisputes, jsonEncode(ids));
}

/// Se sobreescribe en main() con la instancia real de SharedPreferences.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Override en main()'),
);

final localStorageProvider = Provider<LocalStorageService>(
  (ref) => LocalStorageService(ref.watch(sharedPreferencesProvider)),
);

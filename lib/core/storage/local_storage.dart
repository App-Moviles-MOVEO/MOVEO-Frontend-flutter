import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Claves de preferencias locales (datos no sensibles).
class LocalStorageKeys {
  LocalStorageKeys._();

  static const String locale = 'locale';
  static const String onboardingSeen = 'onboarding_seen';

  static String checklist(String reservationId, String tipo) =>
      'checklist_${reservationId}_$tipo';
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
}

/// Se sobreescribe en main() con la instancia real de SharedPreferences.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Override en main()'),
);

final localStorageProvider = Provider<LocalStorageService>(
  (ref) => LocalStorageService(ref.watch(sharedPreferencesProvider)),
);

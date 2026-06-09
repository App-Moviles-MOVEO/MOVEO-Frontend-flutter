import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheelspe_provider/core/storage/local_storage.dart';

/// Locale de la app. Por defecto español; el usuario puede cambiarlo
/// en el perfil y se persiste en shared_preferences.
class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    final saved = ref.watch(localStorageProvider).locale;
    return Locale(saved ?? 'es');
  }

  Future<void> setLocale(String code) async {
    await ref.read(localStorageProvider).setLocale(code);
    state = Locale(code);
  }
}

final localeProvider =
    NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);

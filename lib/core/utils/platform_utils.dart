import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wheelspe_provider/shared/widgets/snackbars.dart';

/// `true` cuando la app corre en un navegador (Flutter web).
///
/// Úsalo para deshabilitar o sustituir funciones que dependen de hardware
/// nativo (cámara, escáner de DNI, mapas, impresión de PDF, etc.) que no
/// funcionan —o funcionan a medias— en web.
bool get isWeb => kIsWeb;

/// Ejecuta [action] solo en plataformas nativas (Android/iOS).
///
/// En web no ejecuta nada: muestra un aviso al usuario y devuelve `false`.
/// En nativo ejecuta [action] y devuelve `true`.
///
/// Ejemplo:
/// ```dart
/// onTap: () => runNativeOnly(
///   context,
///   () => _abrirCamara(),
///   webMessage: 'El escaneo de DNI solo está disponible en la app móvil.',
/// ),
/// ```
Future<bool> runNativeOnly(
  BuildContext context,
  Future<void> Function() action, {
  String? webMessage,
}) async {
  if (kIsWeb) {
    showInfoSnackBar(
      context,
      webMessage ?? 'Esta función solo está disponible en la app móvil.',
    );
    return false;
  }
  await action();
  return true;
}

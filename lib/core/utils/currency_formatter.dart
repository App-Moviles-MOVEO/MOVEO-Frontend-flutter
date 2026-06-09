import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Formato de moneda peruana: S/ 1,250.00
class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _pen = NumberFormat.currency(
    locale: 'es_PE',
    symbol: 'S/ ',
    decimalDigits: 2,
  );

  static final NumberFormat _penCompact = NumberFormat.currency(
    locale: 'es_PE',
    symbol: 'S/ ',
    decimalDigits: 0,
  );

  static String format(num amount) => _pen.format(amount);

  static String formatCompact(num amount) => _penCompact.format(amount);
}

/// TextInputFormatter que antepone "S/ " y agrega separadores de miles
/// mientras el usuario escribe (ej. "S/ 1,250").
class SolesInputFormatter extends TextInputFormatter {
  static final NumberFormat _grouping = NumberFormat('#,##0', 'en_US');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) return const TextEditingValue(text: '');

    final value = int.parse(digits);
    final formatted = 'S/ ${_grouping.format(value)}';
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  /// Extrae el valor numérico de un texto formateado por este formatter.
  static double parse(String text) {
    final digits = text.replaceAll(RegExp(r'[^\d]'), '');
    return digits.isEmpty ? 0 : double.parse(digits);
  }
}

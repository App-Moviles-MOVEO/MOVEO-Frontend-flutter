/// PIN de 4 dígitos para validar la entrega/inicio del viaje (US09).
///
/// El backend aún no expone un PIN por alquiler, así que se deriva de forma
/// **determinística** del id del alquiler: ambas apps (Renter y Owner) usan
/// exactamente esta misma fórmula, de modo que el arrendatario ve el PIN en su
/// app y el proveedor lo valida en la suya sin necesidad de un endpoint.
///
/// Cuando el backend agregue un PIN real por reserva, se reemplaza esta
/// derivación por el valor del servidor sin tocar la UI.
class TripPin {
  TripPin._();

  /// PIN de 4 dígitos (0000–9999) estable para un mismo [rentalId].
  static String forRental(String rentalId) {
    // Hash tipo FNV-1a de 32 bits sobre "wpe:{id}" para un valor estable
    // y bien distribuido, luego lo llevamos a 4 dígitos.
    const seed = 'wpe-trip:';
    var hash = 0x811c9dc5;
    for (final code in '$seed$rentalId'.codeUnits) {
      hash ^= code;
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    final pin = hash % 10000;
    return pin.toString().padLeft(4, '0');
  }

  /// Valida un PIN ingresado contra el esperado para el alquiler.
  static bool validate(String rentalId, String input) =>
      input.trim() == forRental(rentalId);
}

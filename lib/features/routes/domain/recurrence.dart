/// Planificador puro de recurrencia semanal para rutas de carpooling (US17).
///
/// Genera las fechas concretas en las que debe publicarse una ruta que se
/// repite ciertos días de la semana durante un número de semanas. Es
/// determinístico y sin dependencias de UI para poder testearse aislado.
class RecurrencePlanner {
  RecurrencePlanner._();

  /// Devuelve las fechas (a medianoche) de las ocurrencias de una ruta que
  /// se repite en [weekdays] (1 = lunes … 7 = domingo) durante [weeks]
  /// semanas, contando desde la semana de [firstDate].
  ///
  /// Nunca incluye fechas anteriores a [firstDate]. Si no hay días o semanas
  /// válidas, cae a una única ocurrencia en [firstDate].
  static List<DateTime> weeklyOccurrences({
    required DateTime firstDate,
    required Set<int> weekdays,
    required int weeks,
  }) {
    final start = DateTime(firstDate.year, firstDate.month, firstDate.day);
    if (weekdays.isEmpty || weeks < 1) return [start];

    // Lunes de la semana de [firstDate] (weekday: lunes = 1).
    final monday = start.subtract(Duration(days: start.weekday - 1));
    final result = <DateTime>[];
    for (var w = 0; w < weeks; w++) {
      for (final wd in weekdays) {
        final day = monday.add(Duration(days: (wd - 1) + w * 7));
        if (!day.isBefore(start)) result.add(day);
      }
    }
    result.sort((a, b) => a.compareTo(b));
    return result;
  }
}

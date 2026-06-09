import 'package:intl/intl.dart';

/// Formatos de fecha por locale: dd/MM/yyyy en español, MM/dd/yyyy en inglés.
class DateFormatter {
  DateFormatter._();

  static String shortDate(DateTime date, String localeCode) {
    final pattern = localeCode.startsWith('en') ? 'MM/dd/yyyy' : 'dd/MM/yyyy';
    return DateFormat(pattern, localeCode).format(date);
  }

  static String time(DateTime date, String localeCode) =>
      DateFormat('HH:mm', localeCode).format(date);

  static String dayMonth(DateTime date, String localeCode) =>
      DateFormat('d MMM', localeCode).format(date);

  static String fullDateTime(DateTime date, String localeCode) {
    final pattern = localeCode.startsWith('en')
        ? 'MM/dd/yyyy HH:mm'
        : 'dd/MM/yyyy HH:mm';
    return DateFormat(pattern, localeCode).format(date);
  }

  static String monthYear(DateTime date, String localeCode) =>
      DateFormat('MMMM yyyy', localeCode).format(date);

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}

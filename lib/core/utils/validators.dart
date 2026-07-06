/// Validadores de formularios. Retornan null cuando el valor es válido;
/// los mensajes localizados los aporta la capa de presentación.
class Validators {
  Validators._();

  static final RegExp _email =
      RegExp(r'^[\w\.\-+]+@[\w\-]+(\.[\w\-]+)+$');

  /// Placa peruana: ABC-123
  static final RegExp peruvianPlate = RegExp(r'^[A-Z]{3}-\d{3}$');

  /// Celular peruano: 9 dígitos.
  static final RegExp _phone = RegExp(r'^\d{9}$');

  static bool isValidEmail(String value) => _email.hasMatch(value.trim());

  static bool isValidPassword(String value) => value.length >= 8;

  static bool isValidPhone(String value) => _phone.hasMatch(value.trim());

  static bool isValidPlate(String value) =>
      peruvianPlate.hasMatch(value.trim().toUpperCase());

  static bool isNotEmpty(String? value) =>
      value != null && value.trim().isNotEmpty;

  /// Dominios de correo institucional habilitados para carpooling.
  static const List<String> institutionalDomains = ['upc.edu.pe'];

  /// El carpooling exige correo institucional: acepta `@dominio` y
  /// subdominios (`u201812345@upc.edu.pe`, `nombre@u.upc.edu.pe`).
  static bool isInstitutionalEmail(String? value) {
    final email = value?.trim().toLowerCase() ?? '';
    if (!isValidEmail(email)) return false;
    return institutionalDomains.any(
      (domain) => email.endsWith('@$domain') || email.endsWith('.$domain'),
    );
  }
}

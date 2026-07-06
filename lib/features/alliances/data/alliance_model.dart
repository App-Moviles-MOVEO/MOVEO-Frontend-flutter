/// Resultado de la evaluación automática de una solicitud de alianza (US46).
///
/// Como no existe rol de administrador, la revisión que normalmente haría un
/// admin se resuelve de forma automática con una política determinística.
enum AllianceStatus {
  /// Cumple los criterios mínimos: aprobada automáticamente.
  approved,

  /// Faltan datos o no cumple el umbral mínimo: queda en revisión.
  underReview;

  bool get isApproved => this == AllianceStatus.approved;
}

/// Solicitud de alianza corporativa (US46). El backend no tiene endpoint de
/// alianzas: se registra como ticket de soporte (type `partnership`) y se
/// guarda una copia local con el resultado de la evaluación automática.
class AlliancePartnership {
  final String id;
  final String companyName;

  /// RUC de la empresa (11 dígitos en Perú).
  final String taxId;
  final String contactName;
  final String email;
  final String phone;

  /// Tamaño estimado de flota o número de colaboradores a movilizar.
  final int fleetSize;
  final String message;
  final AllianceStatus status;
  final DateTime createdAt;

  const AlliancePartnership({
    required this.id,
    required this.companyName,
    required this.taxId,
    required this.contactName,
    required this.email,
    required this.phone,
    required this.fleetSize,
    required this.message,
    required this.status,
    required this.createdAt,
  });

  /// Política de aprobación automática (reemplaza la revisión de un admin):
  /// se aprueba si el RUC tiene 11 dígitos y declara al menos 5 unidades de
  /// flota/colaboradores; en otro caso queda en revisión.
  static AllianceStatus evaluate({
    required String taxId,
    required int fleetSize,
  }) {
    final validRuc = RegExp(r'^\d{11}$').hasMatch(taxId.trim());
    return (validRuc && fleetSize >= 5)
        ? AllianceStatus.approved
        : AllianceStatus.underReview;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'companyName': companyName,
        'taxId': taxId,
        'contactName': contactName,
        'email': email,
        'phone': phone,
        'fleetSize': fleetSize,
        'message': message,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
      };

  factory AlliancePartnership.fromJson(Map<String, dynamic> json) =>
      AlliancePartnership(
        id: json['id']?.toString() ?? '',
        companyName: (json['companyName'] ?? '') as String,
        taxId: (json['taxId'] ?? '') as String,
        contactName: (json['contactName'] ?? '') as String,
        email: (json['email'] ?? '') as String,
        phone: (json['phone'] ?? '') as String,
        fleetSize: (json['fleetSize'] as num?)?.toInt() ?? 0,
        message: (json['message'] ?? '') as String,
        status: json['status'] == AllianceStatus.approved.name
            ? AllianceStatus.approved
            : AllianceStatus.underReview,
        createdAt:
            DateTime.tryParse('${json['createdAt']}') ?? DateTime.now(),
      );
}

/// Modelos de autenticación y usuario.
///
/// El backend devuelve el objeto usuario (UserResource) en login/register,
/// SIN token JWT. La sesión es el `id` del usuario.
class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String role;
  final String verificationStatus;
  final bool dniVerified;
  final bool licenseVerified;
  final double reputation;
  final int ratingCount;
  final String? avatarUrl;
  final int completedRentals;
  final int completedRoutes;
  final double totalEarned;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    required this.verificationStatus,
    this.dniVerified = false,
    this.licenseVerified = false,
    this.reputation = 0,
    this.ratingCount = 0,
    this.avatarUrl,
    this.completedRentals = 0,
    this.completedRoutes = 0,
    this.totalEarned = 0,
  });

  bool get isVerified =>
      verificationStatus.toUpperCase() == 'VERIFIED' ||
      (dniVerified && licenseVerified);

  bool get isOwner => role.toLowerCase() == 'owner';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Reputación: puede venir como número plano, como objeto {score,count}
    // o dentro de "stats" / "reputation".
    final reputation = json['reputation'] ?? json['rating'];
    double score = 0;
    int count = (json['ratingCount'] ?? json['reviewsCount'] ?? 0) is num
        ? ((json['ratingCount'] ?? json['reviewsCount'] ?? 0) as num).toInt()
        : 0;
    if (reputation is Map) {
      score = (reputation['score'] ?? reputation['average'] as num?)
              ?.toDouble() ??
          0;
      count = (reputation['count'] as num?)?.toInt() ?? count;
    } else if (reputation is num) {
      score = reputation.toDouble();
    }

    // Verificación: flags planos (dniVerified...) o dentro de "verification".
    final verification = json['verification'];
    bool dni = json['dniVerified'] == true;
    bool license = json['licenseVerified'] == true;
    if (verification is Map) {
      dni = verification['dniVerified'] == true || dni;
      license = verification['licenseVerified'] == true || license;
    }

    final stats = json['stats'];
    int completedRentals = (json['completedRentals'] as num?)?.toInt() ?? 0;
    double totalEarned = (json['totalEarned'] as num?)?.toDouble() ?? 0;
    if (stats is Map) {
      completedRentals =
          (stats['completedRentals'] as num?)?.toInt() ?? completedRentals;
      totalEarned = (stats['totalEarned'] as num?)?.toDouble() ?? totalEarned;
    }

    final status = (json['verificationStatus'] ?? json['kycStatus']) as String?;

    return UserModel(
      id: json['id']?.toString() ?? json['userId']?.toString() ?? '',
      fullName: (json['fullName'] ?? json['name'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      phone: (json['phone'] ?? json['phoneNumber'] ?? '') as String,
      role: (json['role'] ?? 'owner') as String,
      verificationStatus:
          status ?? ((dni && license) ? 'VERIFIED' : 'PENDING'),
      dniVerified: dni,
      licenseVerified: license,
      reputation: score,
      ratingCount: count,
      avatarUrl: (json['avatarUrl'] ?? json['avatar']) as String?,
      completedRentals: completedRentals,
      completedRoutes: (json['completedRoutes'] as num?)?.toInt() ?? 0,
      totalEarned: totalEarned,
    );
  }
}

/// Resultado de login/register: el backend NO devuelve token, solo el usuario.
class LoginResult {
  final String userId;
  final String role;

  const LoginResult({required this.userId, required this.role});

  factory LoginResult.fromJson(Map<String, dynamic> json) {
    // La respuesta puede ser el usuario directamente o envuelto en "user".
    final user = json['user'] is Map
        ? (json['user'] as Map).cast<String, dynamic>()
        : json;
    return LoginResult(
      userId: user['id']?.toString() ?? user['userId']?.toString() ?? '',
      role: (user['role'] ?? 'owner') as String,
    );
  }
}

enum KycStatus {
  pending,
  verified,
  rejected;

  static KycStatus fromString(String? value) =>
      switch (value?.toUpperCase()) {
        'VERIFIED' || 'APPROVED' => KycStatus.verified,
        'REJECTED' => KycStatus.rejected,
        _ => KycStatus.pending,
      };
}

/// Estado de verificación derivado de los flags del usuario.
///
/// El backend NO tiene flujo KYC dedicado; se reconstruye a partir de
/// `dniVerified` / `licenseVerified` / `verificationStatus` del usuario.
class KycStatusResult {
  final KycStatus status;
  final String? reason;

  /// `true` cuando el usuario ya envió sus datos y están en revisión.
  final bool submitted;

  const KycStatusResult({
    required this.status,
    this.reason,
    this.submitted = false,
  });

  factory KycStatusResult.fromUser(UserModel user) {
    if (user.isVerified) {
      return const KycStatusResult(status: KycStatus.verified, submitted: true);
    }
    final status = KycStatus.fromString(user.verificationStatus);
    return KycStatusResult(
      status: status,
      submitted: status != KycStatus.pending ||
          user.verificationStatus.toUpperCase() == 'IN_REVIEW',
    );
  }
}

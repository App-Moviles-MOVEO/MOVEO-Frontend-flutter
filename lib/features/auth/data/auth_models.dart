/// Modelos de autenticación y usuario.
class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String role;
  final String verificationStatus;
  final double reputation;
  final int ratingCount;
  final String? avatarUrl;
  final int completedRentals;
  final int completedRoutes;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    required this.verificationStatus,
    this.reputation = 0,
    this.ratingCount = 0,
    this.avatarUrl,
    this.completedRentals = 0,
    this.completedRoutes = 0,
  });

  bool get isVerified => verificationStatus.toUpperCase() == 'VERIFIED';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final reputation = json['reputation'];
    double score = 0;
    int count = 0;
    if (reputation is Map) {
      score = (reputation['score'] as num?)?.toDouble() ?? 0;
      count = (reputation['count'] as num?)?.toInt() ?? 0;
    } else if (reputation is num) {
      score = reputation.toDouble();
      count = (json['ratingCount'] as num?)?.toInt() ?? 0;
    }
    return UserModel(
      id: json['id']?.toString() ?? '',
      fullName: (json['fullName'] ?? json['name'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      phone: (json['phone'] ?? '') as String,
      role: (json['role'] ?? 'PROVIDER') as String,
      verificationStatus:
          (json['verificationStatus'] ?? json['kycStatus'] ?? 'PENDING')
              as String,
      reputation: score,
      ratingCount: count,
      avatarUrl: json['avatarUrl'] as String?,
      completedRentals: (json['completedRentals'] as num?)?.toInt() ?? 0,
      completedRoutes: (json['completedRoutes'] as num?)?.toInt() ?? 0,
    );
  }
}

class LoginResult {
  final String token;
  final String userId;

  const LoginResult({required this.token, required this.userId});

  factory LoginResult.fromJson(Map<String, dynamic> json) => LoginResult(
        token: (json['token'] ?? json['accessToken'] ?? '') as String,
        userId: json['userId']?.toString() ?? json['id']?.toString() ?? '',
      );
}

enum KycStatus {
  pending,
  verified,
  rejected;

  static KycStatus fromString(String? value) =>
      switch (value?.toUpperCase()) {
        'VERIFIED' => KycStatus.verified,
        'REJECTED' => KycStatus.rejected,
        _ => KycStatus.pending,
      };
}

class KycStatusResult {
  final KycStatus status;
  final String? reason;

  /// `true` cuando el usuario ya envió documentos y están en revisión.
  final bool submitted;

  const KycStatusResult({
    required this.status,
    this.reason,
    this.submitted = false,
  });

  factory KycStatusResult.fromJson(Map<String, dynamic> json) =>
      KycStatusResult(
        status: KycStatus.fromString(json['status'] as String?),
        reason: json['reason'] as String?,
        submitted: json['submitted'] as bool? ?? json['status'] != null,
      );
}

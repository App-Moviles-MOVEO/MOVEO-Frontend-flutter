/// Estado de la reserva de alquiler (contrato real del backend):
/// `pending` → `accepted` → `active` → `completed`, o `cancelled`.
enum ReservationStatus {
  pending,
  confirmed, // == "accepted" en el backend
  inProgress, // == "active" en el backend
  completed,
  cancelled;

  String get apiValue => switch (this) {
        ReservationStatus.pending => 'pending',
        ReservationStatus.confirmed => 'accepted',
        ReservationStatus.inProgress => 'active',
        ReservationStatus.completed => 'completed',
        ReservationStatus.cancelled => 'cancelled',
      };

  static ReservationStatus fromString(String? value) =>
      switch (value?.toUpperCase()) {
        'ACCEPTED' || 'CONFIRMED' => ReservationStatus.confirmed,
        'ACTIVE' || 'IN_PROGRESS' || 'STARTED' => ReservationStatus.inProgress,
        'COMPLETED' => ReservationStatus.completed,
        'CANCELLED' || 'CANCELED' || 'REJECTED' => ReservationStatus.cancelled,
        _ => ReservationStatus.pending,
      };
}

class ReservationModel {
  final String id;
  final String vehicleId;
  final String vehicleName;
  final String renterId;
  final String renterName;
  final String? renterAvatar;
  final double renterRating;
  final bool renterVerified;
  final DateTime startDate;
  final DateTime endDate;
  final double totalAmount;
  final double deposit;
  final ReservationStatus status;
  final DateTime? createdAt;
  final DateTime? confirmedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;

  const ReservationModel({
    required this.id,
    required this.vehicleId,
    this.vehicleName = '',
    required this.renterId,
    required this.renterName,
    this.renterAvatar,
    this.renterRating = 0,
    this.renterVerified = false,
    required this.startDate,
    required this.endDate,
    required this.totalAmount,
    this.deposit = 0,
    this.status = ReservationStatus.pending,
    this.createdAt,
    this.confirmedAt,
    this.startedAt,
    this.completedAt,
  });

  int get totalDaysCount {
    final days = endDate.difference(startDate).inDays;
    return days <= 0 ? 1 : days;
  }

  static DateTime? _date(dynamic value) =>
      value == null ? null : DateTime.tryParse(value.toString());

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    final renter = json['renter'];
    String renterId = json['renterId']?.toString() ?? '';
    String renterName = (json['renterName'] ?? '') as String;
    String? renterAvatar;
    double renterRating = 0;
    bool renterVerified = false;
    if (renter is Map) {
      renterId = renter['id']?.toString() ?? renterId;
      renterName = (renter['fullName'] ?? renter['name'] ?? renterName) as String;
      renterAvatar = renter['avatarUrl'] as String?;
      renterRating = (renter['reputation'] as num?)?.toDouble() ?? 0;
      renterVerified = renter['verificationStatus'] == 'VERIFIED';
    }
    return ReservationModel(
      id: json['id']?.toString() ?? '',
      vehicleId: json['vehicleId']?.toString() ?? '',
      vehicleName: (json['vehicleName'] ?? '') as String,
      renterId: renterId,
      renterName: renterName,
      renterAvatar: renterAvatar,
      renterRating: renterRating,
      renterVerified: renterVerified,
      startDate: _date(json['startDate']) ?? DateTime.now(),
      endDate: _date(json['endDate']) ?? DateTime.now(),
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      deposit: (json['deposit'] as num?)?.toDouble() ?? 0,
      status: ReservationStatus.fromString(json['status'] as String?),
      createdAt: _date(json['createdAt']),
      confirmedAt: _date(json['confirmedAt']),
      startedAt: _date(json['startedAt']),
      completedAt: _date(json['completedAt']),
    );
  }
}

/// Estado de la ruta de carpooling.
enum RouteStatus {
  scheduled,
  inProgress,
  completed,
  cancelled;

  String get apiValue => switch (this) {
        RouteStatus.scheduled => 'SCHEDULED',
        RouteStatus.inProgress => 'IN_PROGRESS',
        RouteStatus.completed => 'COMPLETED',
        RouteStatus.cancelled => 'CANCELLED',
      };

  static RouteStatus fromString(String? value) =>
      switch (value?.toUpperCase()) {
        'IN_PROGRESS' || 'STARTED' => RouteStatus.inProgress,
        'COMPLETED' => RouteStatus.completed,
        'CANCELLED' => RouteStatus.cancelled,
        _ => RouteStatus.scheduled,
      };
}

enum PassengerStatus {
  pending,
  confirmed;

  static PassengerStatus fromString(String? value) =>
      value?.toUpperCase() == 'CONFIRMED'
          ? PassengerStatus.confirmed
          : PassengerStatus.pending;
}

class RoutePassenger {
  final String id;
  final String name;
  final String? avatarUrl;
  final double rating;
  final bool verified;
  final PassengerStatus status;

  const RoutePassenger({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.rating = 0,
    this.verified = false,
    this.status = PassengerStatus.pending,
  });

  factory RoutePassenger.fromJson(Map<String, dynamic> json) =>
      RoutePassenger(
        id: json['id']?.toString() ?? json['passengerId']?.toString() ?? '',
        name: (json['fullName'] ?? json['name'] ?? '') as String,
        avatarUrl: json['avatarUrl'] as String?,
        rating: (json['reputation'] as num?)?.toDouble() ?? 0,
        verified: json['verificationStatus'] == 'VERIFIED',
        status: PassengerStatus.fromString(json['status'] as String?),
      );
}

class RouteModel {
  final String id;
  final String origin;
  final String destination;
  final double? originLat;
  final double? originLng;
  final double? destLat;
  final double? destLng;
  final DateTime departureDateTime;
  final int availableSeats;
  final double pricePerSeat;
  final bool institutionalFilter;
  final bool womenOnly;
  final String notes;
  final RouteStatus status;
  final List<RoutePassenger> passengers;

  const RouteModel({
    required this.id,
    required this.origin,
    required this.destination,
    this.originLat,
    this.originLng,
    this.destLat,
    this.destLng,
    required this.departureDateTime,
    required this.availableSeats,
    required this.pricePerSeat,
    this.institutionalFilter = false,
    this.womenOnly = false,
    this.notes = '',
    this.status = RouteStatus.scheduled,
    this.passengers = const [],
  });

  int get confirmedSeats => passengers
      .where((p) => p.status == PassengerStatus.confirmed)
      .length;

  List<RoutePassenger> get confirmedPassengers => passengers
      .where((p) => p.status == PassengerStatus.confirmed)
      .toList();

  List<RoutePassenger> get pendingPassengers => passengers
      .where((p) => p.status == PassengerStatus.pending)
      .toList();

  double get earnings => confirmedSeats * pricePerSeat;

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    DateTime departure = DateTime.now();
    final rawDate = json['departureDate']?.toString();
    final rawTime = json['departureTime']?.toString();
    if (rawDate != null) {
      final parsed = DateTime.tryParse(
        rawTime != null && !rawDate.contains('T')
            ? '${rawDate}T$rawTime'
            : rawDate,
      );
      if (parsed != null) departure = parsed;
    }
    return RouteModel(
      id: json['id']?.toString() ?? '',
      origin: (json['origin'] ?? '') as String,
      destination: (json['destination'] ?? '') as String,
      originLat: (json['originLat'] as num?)?.toDouble(),
      originLng: (json['originLng'] as num?)?.toDouble(),
      destLat: (json['destLat'] as num?)?.toDouble(),
      destLng: (json['destLng'] as num?)?.toDouble(),
      departureDateTime: departure,
      availableSeats: (json['availableSeats'] as num?)?.toInt() ?? 0,
      pricePerSeat: (json['pricePerSeat'] as num?)?.toDouble() ?? 0,
      institutionalFilter: json['institutionalFilter'] == true ||
          json['institutionalFilter'] == 'UPC',
      womenOnly: json['womenOnly'] == true,
      notes: (json['notes'] ?? '') as String,
      status: RouteStatus.fromString(json['status'] as String?),
      passengers: (json['passengers'] as List?)
              ?.cast<Map<String, dynamic>>()
              .map(RoutePassenger.fromJson)
              .toList() ??
          const [],
    );
  }
}

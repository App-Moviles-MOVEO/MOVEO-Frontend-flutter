/// Estado de la ruta de carpooling.
enum RouteStatus {
  scheduled,
  inProgress,
  completed,
  cancelled;

  String get apiValue => switch (this) {
        RouteStatus.scheduled => 'active',
        RouteStatus.inProgress => 'in_progress',
        RouteStatus.completed => 'completed',
        RouteStatus.cancelled => 'cancelled',
      };

  static RouteStatus fromString(String? value) =>
      switch (value?.toUpperCase()) {
        'IN_PROGRESS' || 'STARTED' || 'ONGOING' => RouteStatus.inProgress,
        'COMPLETED' || 'FINISHED' => RouteStatus.completed,
        'CANCELLED' || 'CANCELED' => RouteStatus.cancelled,
        _ => RouteStatus.scheduled, // active / scheduled
      };
}

enum PassengerStatus {
  pending,
  confirmed,
  rejected,
  cancelled;

  static PassengerStatus fromString(String? value) =>
      switch (value?.toUpperCase()) {
        'CONFIRMED' || 'ACCEPTED' => PassengerStatus.confirmed,
        'REJECTED' => PassengerStatus.rejected,
        'CANCELLED' || 'CANCELED' || 'REMOVED' => PassengerStatus.cancelled,
        _ => PassengerStatus.pending,
      };
}

class RoutePassenger {
  /// Id de la **solicitud** (RoutePassenger), distinto del id del usuario.
  final String id;

  /// Id del **usuario** pasajero. Es el que usan los endpoints
  /// `.../passengers/{passengerId}/accept|reject` y el DELETE.
  final String passengerId;
  final String name;
  final String? avatarUrl;
  final double rating;
  final bool verified;
  final PassengerStatus status;
  final int seats;

  const RoutePassenger({
    required this.id,
    required this.passengerId,
    required this.name,
    this.avatarUrl,
    this.rating = 0,
    this.verified = false,
    this.status = PassengerStatus.pending,
    this.seats = 1,
  });

  factory RoutePassenger.fromJson(Map<String, dynamic> json) {
    final passengerId =
        json['passengerId']?.toString() ?? json['id']?.toString() ?? '';
    return RoutePassenger(
      id: json['id']?.toString() ?? passengerId,
      passengerId: passengerId,
      name: (json['fullName'] ?? json['name'] ?? '') as String,
      avatarUrl: json['avatarUrl'] as String?,
      rating: (json['reputation'] as num?)?.toDouble() ?? 0,
      verified: json['verificationStatus'] == 'VERIFIED',
      status: PassengerStatus.fromString(json['status'] as String?),
      seats: (json['seats'] as num?)?.toInt() ?? 1,
    );
  }
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

  /// Asientos aún libres (`seatsAvailable`); el backend lo descuenta
  /// con cada reserva.
  final int availableSeats;

  /// Capacidad total de la ruta (`seatsTotal`). 0 si el contrato no lo trae.
  final int totalSeats;
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
    this.totalSeats = 0,
    required this.pricePerSeat,
    this.institutionalFilter = false,
    this.womenOnly = false,
    this.notes = '',
    this.status = RouteStatus.scheduled,
    this.passengers = const [],
  });

  int get confirmedSeats => confirmedPassengers.fold(0, (s, p) => s + p.seats);

  List<RoutePassenger> get confirmedPassengers => passengers
      .where((p) => p.status == PassengerStatus.confirmed)
      .toList();

  List<RoutePassenger> get pendingPassengers => passengers
      .where((p) => p.status == PassengerStatus.pending)
      .toList();

  /// Capacidad a mostrar: total real, o los libres si el contrato no
  /// trae `seatsTotal` (para no romper con backends antiguos).
  int get seatCapacity => totalSeats > 0 ? totalSeats : availableSeats;

  /// Asientos ocupados según el backend (total − libres). Si no hay
  /// `seatsTotal`, cae a los confirmados registrados.
  int get occupiedSeats {
    final taken = totalSeats - availableSeats;
    return taken > 0 ? taken : confirmedSeats;
  }

  /// Asientos reservados desde la app de alquiler que no tienen un
  /// pasajero registrado (la lista `passengers` no los incluye).
  int get unregisteredSeats {
    final registered = passengers
        .where((p) =>
            p.status == PassengerStatus.confirmed ||
            p.status == PassengerStatus.pending)
        .fold(0, (s, p) => s + p.seats);
    final unregistered = occupiedSeats - registered;
    return unregistered > 0 ? unregistered : 0;
  }

  double get earnings => occupiedSeats * pricePerSeat;

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
      // El backend real usa startLocation/endLocation; mantenemos
      // origin/destination por tolerancia.
      origin:
          (json['startLocation'] ?? json['origin'] ?? '') as String,
      destination:
          (json['endLocation'] ?? json['destination'] ?? '') as String,
      originLat:
          ((json['lat'] ?? json['originLat']) as num?)?.toDouble(),
      originLng:
          ((json['lng'] ?? json['originLng']) as num?)?.toDouble(),
      destLat: (json['destLat'] as num?)?.toDouble(),
      destLng: (json['destLng'] as num?)?.toDouble(),
      departureDateTime: departure,
      availableSeats: ((json['seatsAvailable'] ??
                  json['availableSeats'] ??
                  json['seatsTotal']) as num?)
              ?.toInt() ??
          0,
      totalSeats:
          ((json['seatsTotal'] ?? json['totalSeats']) as num?)?.toInt() ?? 0,
      pricePerSeat: (json['pricePerSeat'] as num?)?.toDouble() ?? 0,
      institutionalFilter: (json['community'] as String?)?.isNotEmpty == true ||
          json['institutionalFilter'] == true,
      womenOnly: json['onlyWomen'] == true || json['womenOnly'] == true,
      notes: (json['description'] ?? json['notes'] ?? '') as String,
      status: RouteStatus.fromString(json['status'] as String?),
      passengers: (json['passengers'] as List?)
              ?.cast<Map<String, dynamic>>()
              .map(RoutePassenger.fromJson)
              .toList() ??
          const [],
    );
  }
}

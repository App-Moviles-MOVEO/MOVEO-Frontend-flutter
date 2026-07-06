/// Estado del vehículo en la plataforma.
enum VehicleStatus {
  available,
  rented,
  maintenance;

  /// El backend usa `active` para "disponible para alquilar".
  String get apiValue => switch (this) {
        VehicleStatus.available => 'active',
        VehicleStatus.rented => 'rented',
        VehicleStatus.maintenance => 'maintenance',
      };

  static VehicleStatus fromString(String? value) =>
      switch (value?.toUpperCase()) {
        'RENTED' || 'BOOKED' => VehicleStatus.rented,
        'MAINTENANCE' || 'INACTIVE' => VehicleStatus.maintenance,
        _ => VehicleStatus.available, // active / available
      };
}

class VehicleModel {
  final String id;
  final String brand;
  final String model;
  final int year;
  final String plate;
  final String category;
  final double pricePerDay;
  final String description;
  final double? lat;
  final double? lng;
  final String address;
  final List<String> photos;

  /// Documentos que acreditan la propiedad (US05). Claves:
  /// `propertyCardFront`, `propertyCardBack`, `soat`.
  final Map<String, String> documents;

  /// Estado de acreditación de propiedad que resuelve un admin:
  /// not_submitted | pending | approved | rejected.
  final String ownershipStatus;
  final String? ownershipRejectionReason;
  final VehicleStatus status;
  final int monthReservations;
  final double monthEarnings;

  const VehicleModel({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.plate,
    required this.category,
    required this.pricePerDay,
    this.description = '',
    this.lat,
    this.lng,
    this.address = '',
    this.photos = const [],
    this.documents = const {},
    this.ownershipStatus = 'not_submitted',
    this.ownershipRejectionReason,
    this.status = VehicleStatus.available,
    this.monthReservations = 0,
    this.monthEarnings = 0,
  });

  String get displayName => '$brand $model $year';

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    // Coordenadas: planas (lat/lng) o dentro de "location".
    final location = json['location'];
    double? lat = (json['lat'] as num?)?.toDouble();
    double? lng = (json['lng'] as num?)?.toDouble();
    String address =
        (json['address'] ?? json['district'] ?? '') as String? ?? '';
    if (location is Map) {
      lat = (location['lat'] as num?)?.toDouble() ?? lat;
      lng = (location['lng'] as num?)?.toDouble() ?? lng;
      address = (location['address'] ?? location['district'] ?? address)
          as String;
    } else if (location is String) {
      address = location;
    }
    final photos = (json['photos'] ?? json['images'] ?? json['photoUrls'])
        as List?;
    return VehicleModel(
      id: json['id']?.toString() ?? '',
      brand: (json['brand'] ?? json['make'] ?? '') as String,
      model: (json['model'] ?? '') as String,
      year: (json['year'] as num?)?.toInt() ?? 0,
      plate: (json['plate'] ?? json['licensePlate'] ?? '') as String,
      category: (json['bodyType'] ?? json['category'] ?? '') as String,
      pricePerDay:
          ((json['pricePerDay'] ?? json['dailyPrice']) as num?)?.toDouble() ??
              0,
      description: (json['description'] ?? '') as String,
      lat: lat,
      lng: lng,
      address: address,
      photos: photos?.cast<String>() ?? const [],
      documents: json['documents'] is Map
          ? (json['documents'] as Map)
              .map((k, v) => MapEntry(k.toString(), v.toString()))
          : const {},
      ownershipStatus:
          (json['ownershipStatus'] as String?) ?? 'not_submitted',
      ownershipRejectionReason: json['ownershipRejectionReason'] as String?,
      status: VehicleStatus.fromString(json['status'] as String?),
      monthReservations: (json['monthReservations'] as num?)?.toInt() ?? 0,
      monthEarnings: (json['monthEarnings'] as num?)?.toDouble() ?? 0,
    );
  }

  /// Cuerpo para POST /vehicles (CreateVehicleResource del backend real).
  ///
  /// El backend exige `ownerId`, `licensePlate`, `dailyPrice`, `images` y un
  /// objeto `location {district,address,lat,lng}`. Los campos que el formulario
  /// no captura (color/transmission/fuelType/seats) se envían con defaults
  /// razonables para que el vehículo quede utilizable.
  Map<String, dynamic> toCreateJson(String ownerId) => {
        'ownerId': int.tryParse(ownerId) ?? ownerId,
        'brand': brand,
        'model': model,
        'year': year,
        'color': 'No especificado',
        'transmission': 'manual',
        'fuelType': 'gasoline',
        'seats': 5,
        'licensePlate': plate,
        'location': {
          'district': address,
          'address': address,
          'lat': lat,
          'lng': lng,
        },
        'dailyPrice': pricePerDay,
        'depositAmount': 0,
        'description': description,
        // Las fotos y documentos locales se suben por multipart después de
        // crear el vehículo (POST /vehicles/{id}/images y /documents); aquí
        // solo van URLs ya públicas.
        'images': photos.where(_isRemoteUrl).toList(),
        'bodyType': category,
      };

  static bool _isRemoteUrl(String value) =>
      value.startsWith('http://') || value.startsWith('https://');
}

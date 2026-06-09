/// Estado del vehículo en la plataforma.
enum VehicleStatus {
  available,
  rented,
  maintenance;

  String get apiValue => switch (this) {
        VehicleStatus.available => 'AVAILABLE',
        VehicleStatus.rented => 'RENTED',
        VehicleStatus.maintenance => 'MAINTENANCE',
      };

  static VehicleStatus fromString(String? value) =>
      switch (value?.toUpperCase()) {
        'RENTED' => VehicleStatus.rented,
        'MAINTENANCE' => VehicleStatus.maintenance,
        _ => VehicleStatus.available,
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
    this.status = VehicleStatus.available,
    this.monthReservations = 0,
    this.monthEarnings = 0,
  });

  String get displayName => '$brand $model $year';

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    final location = json['location'];
    double? lat;
    double? lng;
    String address = '';
    if (location is Map) {
      lat = (location['lat'] as num?)?.toDouble();
      lng = (location['lng'] as num?)?.toDouble();
      address = (location['address'] ?? '') as String;
    } else if (location is String) {
      address = location;
    }
    return VehicleModel(
      id: json['id']?.toString() ?? '',
      brand: (json['brand'] ?? '') as String,
      model: (json['model'] ?? '') as String,
      year: (json['year'] as num?)?.toInt() ?? 0,
      plate: (json['plate'] ?? '') as String,
      category: (json['category'] ?? '') as String,
      pricePerDay: (json['pricePerDay'] as num?)?.toDouble() ?? 0,
      description: (json['description'] ?? '') as String,
      lat: lat,
      lng: lng,
      address: address,
      photos: (json['photos'] as List?)?.cast<String>() ?? const [],
      status: VehicleStatus.fromString(json['status'] as String?),
      monthReservations: (json['monthReservations'] as num?)?.toInt() ?? 0,
      monthEarnings: (json['monthEarnings'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toCreateJson() => {
        'brand': brand,
        'model': model,
        'year': year,
        'plate': plate,
        'category': category,
        'pricePerDay': pricePerDay,
        'description': description,
        'location': {'lat': lat, 'lng': lng, 'address': address},
        'photos': photos,
      };
}

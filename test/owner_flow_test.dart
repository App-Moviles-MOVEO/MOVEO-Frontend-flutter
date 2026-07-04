import 'package:flutter_test/flutter_test.dart';
import 'package:wheelspe_provider/features/auth/data/auth_models.dart';
import 'package:wheelspe_provider/features/fleet/data/reservation_model.dart';
import 'package:wheelspe_provider/features/fleet/data/vehicle_model.dart';
import 'package:wheelspe_provider/features/routes/data/route_model.dart';

void main() {
  group('UserModel.fromJson', () {
    test('arma fullName desde firstName + lastName (contrato real backend)', () {
      final user = UserModel.fromJson({
        'id': 1,
        'firstName': 'Rosa',
        'lastName': 'Martinez',
        'email': 'rosa@moveo.com',
        'role': 'owner',
        'kycStatus': 'not_submitted',
      });
      expect(user.fullName, 'Rosa Martinez');
      expect(user.isOwner, isTrue);
    });

    test('respeta fullName/name si ya viene armado', () {
      final user = UserModel.fromJson({'id': 2, 'name': 'Juan Perez'});
      expect(user.fullName, 'Juan Perez');
    });
  });

  group('KycStatusResult.fromUser', () {
    KycStatusResult resultFor(String kycStatus) => KycStatusResult.fromUser(
          UserModel.fromJson({'id': 1, 'kycStatus': kycStatus}),
        );

    test('not_submitted → pendiente y sin enviar (muestra formulario)', () {
      final r = resultFor('not_submitted');
      expect(r.status, KycStatus.pending);
      expect(r.submitted, isFalse);
    });

    test('pending → pendiente pero ya enviado (en revisión)', () {
      final r = resultFor('pending');
      expect(r.status, KycStatus.pending);
      expect(r.submitted, isTrue);
    });

    test('approved → verificado', () {
      expect(resultFor('approved').status, KycStatus.verified);
    });

    test('rejected → rechazado', () {
      expect(resultFor('rejected').status, KycStatus.rejected);
    });
  });

  group('ForgotPasswordResult.fromJson', () {
    test('lee message y resetToken (dev)', () {
      final r = ForgotPasswordResult.fromJson({
        'message': 'If an account with that email exists...',
        'resetToken': 'tok-123',
      });
      expect(r.resetToken, 'tok-123');
      expect(r.message, contains('account'));
    });

    test('sin resetToken en producción', () {
      final r = ForgotPasswordResult.fromJson({'message': 'ok'});
      expect(r.resetToken, isNull);
    });
  });

  group('RoutePassenger.fromJson', () {
    test('separa id de solicitud (20) del id de usuario/passengerId (3)', () {
      final p = RoutePassenger.fromJson({
        'id': 20,
        'passengerId': 3,
        'fullName': 'Juan Pérez',
        'reputation': 4.8,
        'verificationStatus': 'VERIFIED',
        'status': 'PENDING',
        'seats': 1,
      });
      // El endpoint accept/reject/DELETE usa el id de USUARIO, no el de solicitud.
      expect(p.id, '20');
      expect(p.passengerId, '3');
      expect(p.verified, isTrue);
      expect(p.status, PassengerStatus.pending);
    });

    test('CONFIRMED/REJECTED/CANCELLED se mapean correctamente', () {
      PassengerStatus s(String v) =>
          RoutePassenger.fromJson({'passengerId': 'x', 'status': v}).status;
      expect(s('CONFIRMED'), PassengerStatus.confirmed);
      expect(s('REJECTED'), PassengerStatus.rejected);
      expect(s('CANCELLED'), PassengerStatus.cancelled);
    });
  });

  group('RouteModel filtra pasajeros por estado', () {
    test('pending/confirmed no incluyen rechazados ni cancelados', () {
      final route = RouteModel.fromJson({
        'id': 7,
        'seatsTotal': 4,
        'seatsAvailable': 3,
        'passengers': [
          {'id': 1, 'passengerId': 'a', 'status': 'PENDING'},
          {'id': 2, 'passengerId': 'b', 'status': 'CONFIRMED'},
          {'id': 3, 'passengerId': 'c', 'status': 'REJECTED'},
          {'id': 4, 'passengerId': 'd', 'status': 'CANCELLED'},
        ],
      });
      expect(route.pendingPassengers.length, 1);
      expect(route.confirmedPassengers.length, 1);
      expect(route.confirmedSeats, 1);
    });
  });

  group('RouteModel contador de asientos (seatsTotal/seatsAvailable)', () {
    test('ocupados = total − disponibles aunque no venga passengers', () {
      // Contrato real del listado: passengers null, el backend descuenta
      // seatsAvailable con cada reserva.
      final route = RouteModel.fromJson({
        'id': 2,
        'seatsTotal': 5,
        'seatsAvailable': 2,
        'pricePerSeat': 30,
      });
      expect(route.occupiedSeats, 3);
      expect(route.seatCapacity, 5);
      expect(route.earnings, 90);
    });

    test('sin seatsTotal cae a los confirmados registrados', () {
      final route = RouteModel.fromJson({
        'id': 3,
        'availableSeats': 4,
        'pricePerSeat': 10,
        'passengers': [
          {'id': 1, 'passengerId': 'a', 'status': 'CONFIRMED', 'seats': 2},
        ],
      });
      expect(route.seatCapacity, 4);
      expect(route.occupiedSeats, 2);
    });

    test('detecta asientos reservados sin pasajero registrado', () {
      // Ruta 2 real: 3 ocupados y passengers vacío → 3 sin registro.
      final route = RouteModel.fromJson({
        'id': 2,
        'seatsTotal': 5,
        'seatsAvailable': 2,
        'passengers': <Map<String, dynamic>>[],
      });
      expect(route.unregisteredSeats, 3);

      // Con un confirmado de 1 asiento quedan 2 sin registro.
      final withPassenger = RouteModel.fromJson({
        'id': 2,
        'seatsTotal': 5,
        'seatsAvailable': 2,
        'passengers': [
          {'id': 1, 'passengerId': 'a', 'status': 'CONFIRMED', 'seats': 1},
        ],
      });
      expect(withPassenger.unregisteredSeats, 2);
    });
  });

  group('ReservationModel datos del arrendatario', () {
    test('fromJson del contrato real deja renterName vacío (solo renterId)',
        () {
      final r = ReservationModel.fromJson({
        'id': 1,
        'vehicleId': 2,
        'renterId': 5,
        'totalPrice': 116.0,
        'status': 'completed',
      });
      expect(r.renterId, '5');
      expect(r.renterName, isEmpty);
    });

    test('copyWith enriquece con los datos de GET /users/{id}', () {
      final base = ReservationModel.fromJson({
        'id': 1,
        'vehicleId': 2,
        'renterId': 5,
        'totalPrice': 116.0,
      });
      final enriched = base.copyWith(
        renterName: 'esther abigail',
        renterRating: 4.5,
        renterVerified: true,
      );
      expect(enriched.renterName, 'esther abigail');
      expect(enriched.renterRating, 4.5);
      expect(enriched.renterVerified, isTrue);
      // El resto se conserva.
      expect(enriched.id, base.id);
      expect(enriched.totalAmount, 116.0);
    });
  });

  group('VehicleModel documentos de propiedad (US05)', () {
    test('toCreateJson incluye documents cuando hay documentos', () {
      const vehicle = VehicleModel(
        id: '',
        brand: 'Toyota',
        model: 'Yaris',
        year: 2022,
        plate: 'ABC-123',
        category: 'Sedán',
        pricePerDay: 120,
        documents: {
          'propertyCardFront': '/tmp/front.jpg',
          'propertyCardBack': '/tmp/back.jpg',
          'soat': '/tmp/soat.jpg',
        },
      );
      final json = vehicle.toCreateJson('7');
      expect(json['documents'], {
        'propertyCardFront': '/tmp/front.jpg',
        'propertyCardBack': '/tmp/back.jpg',
        'soat': '/tmp/soat.jpg',
      });
    });

    test('toCreateJson omite documents cuando está vacío', () {
      const vehicle = VehicleModel(
        id: '',
        brand: 'Kia',
        model: 'Rio',
        year: 2021,
        plate: 'XYZ-987',
        category: 'Sedán',
        pricePerDay: 100,
      );
      expect(vehicle.toCreateJson('7').containsKey('documents'), isFalse);
    });

    test('fromJson parsea documents si el backend los devuelve', () {
      final vehicle = VehicleModel.fromJson({
        'id': 5,
        'brand': 'Toyota',
        'model': 'Yaris',
        'documents': {'soat': 'https://cdn/soat.jpg'},
      });
      expect(vehicle.documents['soat'], 'https://cdn/soat.jpg');
    });
  });
}

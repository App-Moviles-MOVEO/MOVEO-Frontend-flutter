import 'package:flutter_test/flutter_test.dart';
import 'package:wheelspe_provider/core/utils/validators.dart';
import 'package:wheelspe_provider/features/auth/data/auth_models.dart';
import 'package:wheelspe_provider/features/fleet/data/reservation_model.dart';
import 'package:wheelspe_provider/features/fleet/data/vehicle_model.dart';
import 'package:wheelspe_provider/features/profile/presentation/profile_providers.dart';
import 'package:wheelspe_provider/features/routes/data/route_model.dart';
import 'package:wheelspe_provider/features/transactions/data/transaction_model.dart';

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

  group('Validators.isInstitutionalEmail (carpooling)', () {
    test('acepta correos del dominio institucional y sus subdominios', () {
      expect(Validators.isInstitutionalEmail('u201812345@upc.edu.pe'), isTrue);
      expect(
        Validators.isInstitutionalEmail('nombre@u.upc.edu.pe'),
        isTrue,
      );
      expect(
        Validators.isInstitutionalEmail('  MAYUS@UPC.EDU.PE  '),
        isTrue,
      );
    });

    test('rechaza correos personales o inválidos', () {
      expect(Validators.isInstitutionalEmail('andreow@123.com'), isFalse);
      expect(Validators.isInstitutionalEmail('abigail@gmail.com'), isFalse);
      expect(
        Validators.isInstitutionalEmail('falso@upc.edu.pe.evil.com'),
        isFalse,
      );
      expect(Validators.isInstitutionalEmail(''), isFalse);
      expect(Validators.isInstitutionalEmail(null), isFalse);
    });
  });

  group('VehicleModel documentos de propiedad (US05)', () {
    test('toCreateJson NO incluye documents (van por multipart)', () {
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
          'soat': '/tmp/soat.jpg',
        },
      );
      // Los documentos se suben aparte (POST /vehicles/{id}/documents).
      expect(vehicle.toCreateJson('7').containsKey('documents'), isFalse);
    });

    test('toCreateJson solo envía imágenes remotas, no rutas locales', () {
      const vehicle = VehicleModel(
        id: '',
        brand: 'Kia',
        model: 'Rio',
        year: 2021,
        plate: 'XYZ-987',
        category: 'Sedán',
        pricePerDay: 100,
        photos: [
          '/data/user/0/local.jpg',
          'https://cdn/remota.jpg',
        ],
      );
      // Las fotos locales se suben por multipart tras crear el vehículo.
      expect(vehicle.toCreateJson('7')['images'], ['https://cdn/remota.jpg']);
    });

    test('fromJson parsea documents y ownershipStatus del backend', () {
      final vehicle = VehicleModel.fromJson({
        'id': 5,
        'brand': 'Toyota',
        'model': 'Yaris',
        'documents': {'soat': 'https://cdn/soat.jpg'},
        'ownershipStatus': 'pending',
      });
      expect(vehicle.documents['soat'], 'https://cdn/soat.jpg');
      expect(vehicle.ownershipStatus, 'pending');
    });
  });

  group('UserModel badges y puntualidad server-side (US36)', () {
    test('usa badges del backend cuando vienen en stats', () {
      final user = UserModel.fromJson({
        'id': 4,
        'stats': {
          'completedRentals': 1,
          'reputation': 3.0,
          'onTimeRate': 0.5,
          'badges': ['VERIFIED', 'PUNCTUAL'],
        },
      });
      final badges = ProviderBadges.fromUser(user);
      // Aunque la reputación/onTime local no calificaría, se respeta el backend.
      expect(badges.verified, isTrue);
      expect(badges.punctual, isTrue);
      expect(badges.topRenter, isFalse);
    });

    test('puntual usa onTimeRate real cuando no hay badges del backend', () {
      final user = UserModel.fromJson({
        'id': 4,
        'stats': {'completedRentals': 5, 'onTimeRate': 0.95},
      });
      expect(ProviderBadges.fromUser(user).punctual, isTrue);
    });
  });

  group('WalletBalance / RefundResult', () {
    test('WalletBalance.fromJson lee balance real', () {
      final w = WalletBalance.fromJson({
        'balance': 350.0,
        'pendingWithdrawals': 50.0,
        'totalEarned': 900.0,
      });
      expect(w.balance, 350.0);
      expect(w.pendingWithdrawals, 50.0);
    });

    test('RefundResult.fromJson lee monto y política', () {
      final r = RefundResult.fromJson({
        'refundedAmount': 58.0,
        'policy': '50%',
        'status': 'refunded',
      });
      expect(r.refundedAmount, 58.0);
      expect(r.policy, '50%');
    });
  });
}

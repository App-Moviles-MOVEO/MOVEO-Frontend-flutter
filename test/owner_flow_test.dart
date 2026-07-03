import 'package:flutter_test/flutter_test.dart';
import 'package:wheelspe_provider/features/auth/data/auth_models.dart';
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
}

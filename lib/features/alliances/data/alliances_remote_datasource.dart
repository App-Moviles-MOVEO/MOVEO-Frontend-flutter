import 'package:dio/dio.dart';
import 'package:wheelspe_provider/core/constants/api_constants.dart';
import 'package:wheelspe_provider/core/network/dio_client.dart';
import 'package:wheelspe_provider/features/alliances/data/alliance_model.dart';

/// El backend no tiene endpoint de alianzas corporativas. La solicitud (US46)
/// se registra como **ticket de soporte** (`/support-tickets`) de tipo
/// `partnership`, que queda trazado para el equipo comercial.
class AlliancesRemoteDataSource {
  final Dio _dio;

  const AlliancesRemoteDataSource(this._dio);

  Future<void> submitPartnership({
    required String requesterId,
    required AlliancePartnership request,
  }) async {
    try {
      await _dio.post<dynamic>(
        ApiConstants.supportTickets,
        data: {
          'userId': requesterId,
          'type': 'partnership',
          'category': 'partnership',
          'subject': 'Alianza corporativa: ${request.companyName}',
          'description': [
            'Empresa: ${request.companyName}',
            'RUC: ${request.taxId}',
            'Contacto: ${request.contactName}',
            'Correo: ${request.email}',
            'Teléfono: ${request.phone}',
            'Flota/colaboradores: ${request.fleetSize}',
            if (request.message.isNotEmpty) 'Mensaje: ${request.message}',
            'Evaluación automática: '
                '${request.status.isApproved ? 'APROBADA' : 'EN REVISIÓN'}',
          ].join('\n'),
        },
      );
    } on DioException catch (e) {
      throwAsAppException(e);
    }
  }
}

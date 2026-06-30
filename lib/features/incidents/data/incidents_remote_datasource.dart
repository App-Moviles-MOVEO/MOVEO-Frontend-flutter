import 'package:dio/dio.dart';
import 'package:wheelspe_provider/core/constants/api_constants.dart';
import 'package:wheelspe_provider/core/network/dio_client.dart';

/// Tipos de incidente soportados por la plataforma.
enum IncidentType {
  damage('damage'),
  accident('accident'),
  lateness('lateness'),
  behavior('behavior'),
  other('other');

  final String apiValue;

  const IncidentType(this.apiValue);
}

/// El backend NO tiene `/incidents`. Se reportan como **tickets de soporte**
/// (`/support-tickets`) de tipo "incident", que sí existe y queda registrado.
/// Las imágenes de evidencia no se suben (no hay endpoint de almacenamiento);
/// se referencian en la descripción.
class IncidentsRemoteDataSource {
  final Dio _dio;

  const IncidentsRemoteDataSource(this._dio);

  Future<void> reportIncident({
    required String reporterId,
    required IncidentType type,
    required String description,
    String? reservationId,
    String? routeId,
    List<String> evidencePaths = const [],
  }) async {
    try {
      final relatedTo = reservationId != null
          ? 'Reserva: $reservationId'
          : routeId != null
              ? 'Ruta: $routeId'
              : null;
      final evidenceNote = evidencePaths.isEmpty
          ? ''
          : '\n\nEvidencia adjunta (${evidencePaths.length} foto(s)).';

      await _dio.post<dynamic>(
        ApiConstants.supportTickets,
        data: {
          'userId': reporterId,
          'type': 'incident',
          'category': type.apiValue,
          'subject': 'Incidente: ${type.apiValue}',
          'description': [
            description,
            ?relatedTo,
          ].join('\n') + evidenceNote,
          'rentalId': ?reservationId,
          'routeId': ?routeId,
        },
      );
    } on DioException catch (e) {
      throwAsAppException(e);
    }
  }
}

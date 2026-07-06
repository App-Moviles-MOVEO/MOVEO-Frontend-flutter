import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheelspe_provider/core/network/dio_client.dart';
import 'package:wheelspe_provider/core/storage/local_storage.dart';
import 'package:wheelspe_provider/features/alliances/data/alliance_model.dart';
import 'package:wheelspe_provider/features/alliances/data/alliances_remote_datasource.dart';
import 'package:wheelspe_provider/shared/providers/user_provider.dart';

final alliancesDataSourceProvider = Provider<AlliancesRemoteDataSource>(
  (ref) => AlliancesRemoteDataSource(ref.watch(dioProvider)),
);

/// Solicitudes de alianza corporativa del proveedor (US46). Persistidas
/// localmente; cada envío además registra un ticket de soporte.
final alliancesProvider =
    NotifierProvider<AlliancesNotifier, List<AlliancePartnership>>(
  AlliancesNotifier.new,
);

class AlliancesNotifier extends Notifier<List<AlliancePartnership>> {
  @override
  List<AlliancePartnership> build() {
    final raw = ref.watch(localStorageProvider).loadAlliances();
    return raw.map(AlliancePartnership.fromJson).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> _persist(List<AlliancePartnership> requests) async {
    await ref
        .read(localStorageProvider)
        .saveAlliances(requests.map((r) => r.toJson()).toList());
    state = requests;
  }

  /// Envía la solicitud: la evalúa automáticamente, registra el ticket de
  /// soporte y guarda la copia local. Devuelve la solicitud creada con su
  /// estado (aprobada / en revisión).
  Future<AlliancePartnership> submit({
    required String companyName,
    required String taxId,
    required String contactName,
    required String email,
    required String phone,
    required int fleetSize,
    required String message,
  }) async {
    final request = AlliancePartnership(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      companyName: companyName,
      taxId: taxId,
      contactName: contactName,
      email: email,
      phone: phone,
      fleetSize: fleetSize,
      message: message,
      status: AlliancePartnership.evaluate(taxId: taxId, fleetSize: fleetSize),
      createdAt: DateTime.now(),
    );

    final requesterId = await ref.read(currentUserIdProvider.future);
    if (requesterId != null && requesterId.isNotEmpty) {
      await ref.read(alliancesDataSourceProvider).submitPartnership(
            requesterId: requesterId,
            request: request,
          );
    }

    await _persist([request, ...state]);
    return request;
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheelspe_provider/core/network/dio_client.dart';
import 'package:wheelspe_provider/core/storage/secure_storage.dart';
import 'package:wheelspe_provider/features/auth/data/auth_models.dart';
import 'package:wheelspe_provider/features/auth/data/auth_remote_datasource.dart';
import 'package:wheelspe_provider/features/auth/data/auth_repository_impl.dart';
import 'package:wheelspe_provider/features/auth/domain/auth_repository.dart';
import 'package:wheelspe_provider/features/auth/domain/login_usecase.dart';
import 'package:wheelspe_provider/features/auth/domain/register_usecase.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>(
  (ref) => AuthRemoteDataSource(ref.watch(dioProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    ref.watch(authRemoteDataSourceProvider),
    ref.watch(secureStorageProvider),
  ),
);

final loginUseCaseProvider = Provider<LoginUseCase>(
  (ref) => LoginUseCase(ref.watch(authRepositoryProvider)),
);

final registerUseCaseProvider = Provider<RegisterUseCase>(
  (ref) => RegisterUseCase(ref.watch(authRepositoryProvider)),
);

/// Estado del KYC del usuario autenticado.
final kycStatusProvider = FutureProvider<KycStatusResult>(
  (ref) => ref.watch(authRepositoryProvider).getKycStatus(),
);

/// Controlador de acciones de autenticación (login / register / logout).
class AuthController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> login(String email, String password) async {
    state = const AsyncLoading();
    try {
      await ref.read(loginUseCaseProvider)(email, password);
      ref.read(sessionNotifierProvider).reset();
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(registerUseCaseProvider)(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      );
      ref.read(sessionNotifierProvider).reset();
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(null);
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AsyncValue<void>>(AuthController.new);

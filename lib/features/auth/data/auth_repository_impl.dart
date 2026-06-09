import 'package:wheelspe_provider/core/storage/secure_storage.dart';
import 'package:wheelspe_provider/features/auth/data/auth_models.dart';
import 'package:wheelspe_provider/features/auth/data/auth_remote_datasource.dart';
import 'package:wheelspe_provider/features/auth/domain/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final SecureStorageService _storage;

  const AuthRepositoryImpl(this._remote, this._storage);

  @override
  Future<LoginResult> login(String email, String password) async {
    final result = await _remote.login(email, password);
    await _storage.saveToken(result.token);
    await _storage.saveUserId(result.userId);
    return result;
  }

  @override
  Future<LoginResult> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    final result = await _remote.register(
      email: email,
      password: password,
      fullName: fullName,
      phone: phone,
    );
    if (result != null) {
      await _storage.saveToken(result.token);
      await _storage.saveUserId(result.userId);
      return result;
    }
    return login(email, password);
  }

  @override
  Future<void> uploadKyc({
    required String documentType,
    required String frontImagePath,
    required String backImagePath,
  }) =>
      _remote.uploadKyc(
        documentType: documentType,
        frontImagePath: frontImagePath,
        backImagePath: backImagePath,
      );

  @override
  Future<KycStatusResult> getKycStatus() => _remote.getKycStatus();

  @override
  Future<UserModel> getUser(String id) => _remote.getUser(id);

  @override
  Future<void> logout() => _storage.clearSession();

  @override
  Future<String?> getStoredToken() => _storage.getToken();

  @override
  Future<String?> getStoredUserId() => _storage.getUserId();
}

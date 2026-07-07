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
    await _persist(result);
    return result;
  }

  @override
  Future<LoginResult> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String gender,
  }) async {
    final result = await _remote.register(
      email: email,
      password: password,
      fullName: fullName,
      phone: phone,
      gender: gender,
    );
    // Si el backend no devolvió id en el registro, autenticamos para obtenerlo.
    if (result.userId.isEmpty) {
      return login(email, password);
    }
    await _persist(result);
    return result;
  }

  Future<void> _persist(LoginResult result) async {
    await _storage.saveUserId(result.userId);
    await _storage.saveRole(result.role);
  }

  Future<String> _requireUserId() async {
    final id = await _storage.getUserId();
    if (id == null || id.isEmpty) {
      throw StateError('No hay sesión activa');
    }
    return id;
  }

  @override
  Future<KycStatus> submitKyc({
    String? dniFrontPath,
    String? dniBackPath,
    String? selfiePath,
  }) async {
    final userId = await _requireUserId();
    return _remote.submitKyc(
      userId: userId,
      dniFrontPath: dniFrontPath,
      dniBackPath: dniBackPath,
      selfiePath: selfiePath,
    );
  }

  @override
  Future<KycStatusResult> getKycStatus() async {
    final userId = await _requireUserId();
    return _remote.getKycStatus(userId);
  }

  @override
  Future<ForgotPasswordResult> forgotPassword(String email) =>
      _remote.forgotPassword(email);

  @override
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) =>
      _remote.resetPassword(token: token, newPassword: newPassword);

  @override
  Future<UserModel> getUser(String id) => _remote.getUser(id);

  @override
  Future<void> updateUser(String id, Map<String, dynamic> changes) =>
      _remote.updateUser(id, changes);

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final userId = await _requireUserId();
    await _remote.changePassword(
      userId: userId,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  @override
  Future<void> deleteAccount() async {
    final userId = await _requireUserId();
    await _remote.deleteUser(userId);
    await _storage.clearSession();
  }

  @override
  Future<void> logout() async {
    await _remote.logout();
    await _storage.clearSession();
  }

  @override
  Future<String?> getStoredUserId() => _storage.getUserId();
}

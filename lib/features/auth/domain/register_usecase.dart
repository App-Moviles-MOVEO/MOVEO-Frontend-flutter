import 'package:wheelspe_provider/features/auth/data/auth_models.dart';
import 'package:wheelspe_provider/features/auth/domain/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _repository;

  const RegisterUseCase(this._repository);

  Future<LoginResult> call({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) =>
      _repository.register(
        email: email.trim(),
        password: password,
        fullName: fullName.trim(),
        phone: phone.trim(),
      );
}

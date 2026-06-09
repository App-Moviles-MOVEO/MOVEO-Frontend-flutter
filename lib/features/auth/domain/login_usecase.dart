import 'package:wheelspe_provider/features/auth/data/auth_models.dart';
import 'package:wheelspe_provider/features/auth/domain/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  const LoginUseCase(this._repository);

  Future<LoginResult> call(String email, String password) =>
      _repository.login(email.trim(), password);
}

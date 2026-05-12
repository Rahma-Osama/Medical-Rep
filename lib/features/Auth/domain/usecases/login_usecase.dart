// domain/usecases/login_usecase.dart
import 'package:medical_rep/features/Auth/domain/entities/user_entity.dart';
import 'package:medical_rep/features/Auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;
  LoginUseCase(this.repository);

  Future<UserEntity> call(String email, String password) {
    return repository.login(email, password);
  }
}
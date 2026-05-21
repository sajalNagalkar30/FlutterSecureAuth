import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<UserEntity> call({
    required String email,
    required String password,
  }) async {
    _validate(email: email, password: password);
    return _repository.login(email: email, password: password);
  }

  void _validate({required String email, required String password}) {
    final emailTrimmed = email.trim();
    final passwordTrimmed = password.trim();

    if (emailTrimmed.isEmpty) {
      throw const ValidationFailure('Email is required.');
    }
    if (!RegExp(r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,}$').hasMatch(emailTrimmed)) {
      throw const ValidationFailure('Enter a valid email address.');
    }
    if (passwordTrimmed.isEmpty) {
      throw const ValidationFailure('Password is required.');
    }
    if (passwordTrimmed.length < 6) {
      throw const ValidationFailure('Password must be at least 6 characters.');
    }
  }
}

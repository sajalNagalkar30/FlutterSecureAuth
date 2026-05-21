import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  Future<UserEntity> call({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    _validate(
      username: username,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );
    return _repository.register(
      username: username.trim(),
      email: email.trim(),
      password: password,
    );
  }

  void _validate({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    final usernameTrimmed = username.trim();
    final emailTrimmed = email.trim();

    if (usernameTrimmed.isEmpty) {
      throw const ValidationFailure('Username is required.');
    }
    if (usernameTrimmed.length < 3) {
      throw const ValidationFailure('Username must be at least 3 characters.');
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(usernameTrimmed)) {
      throw const ValidationFailure('Username can only contain letters, numbers and underscores.');
    }
    if (emailTrimmed.isEmpty) {
      throw const ValidationFailure('Email is required.');
    }
    if (!RegExp(r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,}$').hasMatch(emailTrimmed)) {
      throw const ValidationFailure('Enter a valid email address.');
    }
    if (password.isEmpty) {
      throw const ValidationFailure('Password is required.');
    }
    if (password.length < 6) {
      throw const ValidationFailure('Password must be at least 6 characters.');
    }
    if (!RegExp(r'(?=.*[A-Za-z])(?=.*\d)').hasMatch(password)) {
      throw const ValidationFailure('Password must contain at least one letter and one number.');
    }
    if (confirmPassword.isEmpty) {
      throw const ValidationFailure('Please confirm your password.');
    }
    if (password != confirmPassword) {
      throw const ValidationFailure('Passwords do not match.');
    }
  }
}

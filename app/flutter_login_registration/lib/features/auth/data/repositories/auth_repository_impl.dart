import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _datasource;

  AuthRepositoryImpl(this._datasource);

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    final model = await _datasource.login(email: email, password: password);
    return model.toEntity();
  }

  @override
  Future<UserEntity> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final model = await _datasource.register(
      username: username,
      email: email,
      password: password,
    );
    return model.toEntity();
  }

  @override
  Future<void> logout(String accessToken) => _datasource.logout(accessToken);
}

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;

  AuthBloc({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _logoutUseCase = logoutUseCase,
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    if (await SecureStorage.hasSession()) {
      final userData = await SecureStorage.getUser();
      final accessToken = await SecureStorage.getAccessToken();
      final refreshToken = await SecureStorage.getRefreshToken();
      emit(AuthAuthenticated(UserEntity(
        id: userData['id'] ?? '',
        username: userData['username'] ?? '',
        email: userData['email'] ?? '',
        accessToken: accessToken ?? '',
        refreshToken: refreshToken ?? '',
      )));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _loginUseCase(
        email: event.email,
        password: event.password,
      );
      await _persistUser(user);
      emit(AuthAuthenticated(user));
    } on AppFailure catch (f) {
      emit(AuthError(f.message, failure: f));
    } catch (_) {
      emit(const AuthError('Something went wrong. Please try again.'));
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _registerUseCase(
        username: event.username,
        email: event.email,
        password: event.password,
        confirmPassword: event.confirmPassword,
      );
      await _persistUser(user);
      emit(AuthAuthenticated(user));
    } on AppFailure catch (f) {
      emit(AuthError(f.message, failure: f));
    } catch (_) {
      emit(const AuthError('Something went wrong. Please try again.'));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final token = await SecureStorage.getAccessToken() ?? '';
      await _logoutUseCase(token);
    } catch (_) {
      // best-effort: clear local session regardless
    }
    await SecureStorage.clear();
    emit(const AuthUnauthenticated());
  }

  Future<void> _persistUser(UserEntity user) async {
    await SecureStorage.saveTokens(
      accessToken: user.accessToken,
      refreshToken: user.refreshToken,
    );
    await SecureStorage.saveUser(
      id: user.id,
      username: user.username,
      email: user.email,
    );
  }
}

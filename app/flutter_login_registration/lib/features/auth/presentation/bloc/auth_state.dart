import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// App just launched – not yet checked storage.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Any async operation in progress.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Valid session found / login or register succeeded.
class AuthAuthenticated extends AuthState {
  final UserEntity user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// No session / logged out.
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// A recoverable error (shown as a snackbar / banner in UI).
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

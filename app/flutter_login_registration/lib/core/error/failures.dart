/// Base class for all app-level failures thrown through the layers.
abstract class AppFailure implements Exception {
  final String message;
  const AppFailure(this.message);

  @override
  String toString() => message;
}

/// Field-level validation failed (login / register use-cases).
class ValidationFailure extends AppFailure {
  const ValidationFailure(super.message);
}

/// No internet connection detected.
class NetworkFailure extends AppFailure {
  const NetworkFailure(
      [super.message =
          'No internet connection.\nPlease check your Wi-Fi or mobile data.']);
}

/// Server is unreachable (offline / cold start / wrong URL).
class ServerUnreachableFailure extends AppFailure {
  const ServerUnreachableFailure(
      [super.message =
          'Unable to reach the server.\nIt may be starting up — please try again in a moment.']);
}

/// Request timed out.
class TimeoutFailure extends AppFailure {
  const TimeoutFailure(
      [super.message =
          'The server took too long to respond.\nPlease try again.']);
}

/// 401 – token invalid / expired.
class UnauthorizedFailure extends AppFailure {
  const UnauthorizedFailure(
      [super.message = 'Session expired. Please login again.']);
}

/// 400 – bad request / server-side validation.
class BadRequestFailure extends AppFailure {
  const BadRequestFailure(super.message);
}

/// 409 – conflict (e.g. user already exists).
class ConflictFailure extends AppFailure {
  const ConflictFailure(super.message);
}

/// 404 – resource not found.
class NotFoundFailure extends AppFailure {
  const NotFoundFailure([super.message = 'Resource not found.']);
}

/// 5xx – server error.
class ServerFailure extends AppFailure {
  const ServerFailure([super.message = 'Server error. Please try again later.']);
}

/// SSL certificate verification failed (pinning mismatch).
class SecurityFailure extends AppFailure {
  const SecurityFailure(
      [super.message = 'Security error: SSL certificate mismatch.']);
}

/// Catch-all for unexpected errors.
class UnknownFailure extends AppFailure {
  const UnknownFailure([super.message = 'Something went wrong. Please try again.']);
}

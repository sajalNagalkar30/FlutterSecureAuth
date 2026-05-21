import 'package:dio/dio.dart';
import 'failures.dart';

/// Maps every [DioException] to a typed [AppFailure].
/// Call [DioErrorHandler.handle] in the datasource catch block.
class DioErrorHandler {
  DioErrorHandler._();

  static AppFailure handle(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutFailure();

      case DioExceptionType.connectionError:
        return const NetworkFailure();

      case DioExceptionType.badCertificate:
        return const SecurityFailure();

      case DioExceptionType.badResponse:
        return _fromResponse(e.response);

      case DioExceptionType.cancel:
        return const UnknownFailure('Request was cancelled.');

      case DioExceptionType.unknown:
        // Wrap connection refused / socket errors as network failures
        final msg = e.message ?? '';
        if (msg.contains('SocketException') ||
            msg.contains('Connection refused') ||
            msg.contains('Network is unreachable')) {
          return const NetworkFailure();
        }
        return UnknownFailure(msg.isNotEmpty ? msg : 'Unexpected error.');
    }
  }

  static AppFailure _fromResponse(Response? response) {
    if (response == null) return const UnknownFailure('Empty response from server.');

    final serverMessage = _extractMessage(response.data);

    switch (response.statusCode) {
      case 400:
        return BadRequestFailure(serverMessage ?? 'Bad request.');
      case 401:
        return UnauthorizedFailure(serverMessage ?? 'Unauthorized.');
      case 404:
        return NotFoundFailure(serverMessage ?? 'Not found.');
      case 409:
        return ConflictFailure(serverMessage ?? 'Conflict.');
      default:
        final code = response.statusCode ?? 0;
        if (code >= 500) return ServerFailure(serverMessage ?? 'Server error.');
        return UnknownFailure(serverMessage ?? 'Unknown error ($code).');
    }
  }

  static String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] as String?;
    }
    return null;
  }
}

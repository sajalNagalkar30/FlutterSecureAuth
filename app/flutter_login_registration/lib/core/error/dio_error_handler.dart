import 'dart:io';
import 'package:dio/dio.dart';
import 'failures.dart';

/// Maps every [DioException] to a typed [AppFailure].
class DioErrorHandler {
  DioErrorHandler._();

  static AppFailure handle(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return const ServerUnreachableFailure(
          'Could not connect to the server.\nIt may be starting up — please try again in a moment.',
        );

      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const TimeoutFailure(
          'The server took too long to respond.\nPlease try again.',
        );

      case DioExceptionType.connectionError:
        return _fromConnectionError(e);

      case DioExceptionType.badCertificate:
        return const SecurityFailure();

      case DioExceptionType.badResponse:
        return _fromResponse(e.response);

      case DioExceptionType.cancel:
        return const UnknownFailure('Request was cancelled.');

      case DioExceptionType.unknown:
        return _fromUnknown(e);
    }
  }

  static AppFailure _fromConnectionError(DioException e) {
    final msg = e.message ?? '';
    final inner = e.error;

    // No internet
    if (inner is SocketException) {
      final code = inner.osError?.errorCode;
      // Network unreachable (101) or no route to host (113)
      if (code == 101 || code == 113 || msg.contains('Network is unreachable')) {
        return const NetworkFailure();
      }
      // Connection refused = server down / wrong port
      if (code == 111 || msg.contains('Connection refused')) {
        return const ServerUnreachableFailure(
          'Server is offline or unreachable.\nPlease check the server and try again.',
        );
      }
    }

    if (msg.contains('SocketException')) return const NetworkFailure();

    return const ServerUnreachableFailure();
  }

  static AppFailure _fromUnknown(DioException e) {
    final msg = e.message ?? '';
    final inner = e.error;

    if (inner is SocketException || msg.contains('SocketException')) {
      return const NetworkFailure();
    }
    if (msg.contains('Connection refused')) {
      return const ServerUnreachableFailure(
        'Server is offline or unreachable.\nPlease check the server and try again.',
      );
    }
    if (msg.contains('Network is unreachable') ||
        msg.contains('No address associated with hostname')) {
      return const NetworkFailure();
    }
    if (msg.contains('HandshakeException') || msg.contains('CERTIFICATE')) {
      return const SecurityFailure();
    }

    return UnknownFailure(msg.isNotEmpty ? msg : 'Something went wrong. Please try again.');
  }

  static AppFailure _fromResponse(Response? response) {
    if (response == null) {
      return const ServerUnreachableFailure('No response from server.');
    }

    final serverMessage = _extractMessage(response.data);

    switch (response.statusCode) {
      case 400:
        return BadRequestFailure(serverMessage ?? 'Invalid request. Please check your input.');
      case 401:
        return UnauthorizedFailure(serverMessage ?? 'Invalid credentials.');
      case 404:
        return NotFoundFailure(serverMessage ?? 'Resource not found.');
      case 409:
        return ConflictFailure(serverMessage ?? 'This account already exists.');
      default:
        final code = response.statusCode ?? 0;
        if (code >= 500) {
          return ServerFailure(serverMessage ?? 'Server error. Please try again later.');
        }
        return UnknownFailure(serverMessage ?? 'Something went wrong ($code).');
    }
  }

  static String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] as String?;
    }
    return null;
  }
}

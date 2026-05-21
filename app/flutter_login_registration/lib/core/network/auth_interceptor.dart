import 'package:dio/dio.dart';
import '../storage/secure_storage.dart';

/// Automatically attaches the Bearer access-token to every request.
/// On 401, attempts a silent refresh using the stored refresh-token,
/// then retries the original request once.
class AuthInterceptor extends Interceptor {
  final Dio _dio;

  AuthInterceptor(this._dio);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await SecureStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        // Retry original request with new token
        final newToken = await SecureStorage.getAccessToken();
        err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
        try {
          final response = await _dio.fetch(err.requestOptions);
          handler.resolve(response);
          return;
        } catch (_) {
          // Retry failed – fall through to error
        }
      }
    }
    handler.next(err);
  }

  Future<bool> _tryRefresh() async {
    final refreshToken = await SecureStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return false;

    try {
      final response = await _dio.post(
        '/refresh-token',
        data: {'refreshToken': refreshToken},
        options: Options(headers: {}), // no Authorization header for this call
      );
      if (response.statusCode == 200) {
        await SecureStorage.saveTokens(
          accessToken: response.data['accessToken'] as String,
          refreshToken: response.data['refreshToken'] as String,
        );
        return true;
      }
    } catch (_) {}
    return false;
  }
}

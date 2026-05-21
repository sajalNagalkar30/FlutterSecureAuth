import 'package:dio/dio.dart';
import '../../../../core/error/dio_error_handler.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/error/failures.dart';
import '../models/auth_response_model.dart';

class AuthRemoteDatasource {
  final Dio _dio;

  AuthRemoteDatasource(this._dio);

  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    await _checkConnectivity();
    try {
      final response = await _dio.post(
        '/login',
        data: {'email': email, 'password': password},
      );
      return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  Future<AuthResponseModel> register({
    required String username,
    required String email,
    required String password,
  }) async {
    await _checkConnectivity();
    try {
      final response = await _dio.post(
        '/register',
        data: {'username': username, 'email': email, 'password': password},
      );
      return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  Future<void> logout(String accessToken) async {
    await _checkConnectivity();
    try {
      await _dio.post(
        '/logout',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  Future<void> _checkConnectivity() async {
    if (!await NetworkInfo.isConnected) {
      throw const NetworkFailure();
    }
  }
}

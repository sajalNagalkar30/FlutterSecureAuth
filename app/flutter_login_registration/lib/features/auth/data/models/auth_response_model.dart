import '../../domain/entities/user_entity.dart';

class AuthResponseModel {
  final String id;
  final String username;
  final String email;
  final String accessToken;
  final String refreshToken;

  const AuthResponseModel({
    required this.id,
    required this.username,
    required this.email,
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      AuthResponseModel(
        id: json['id'] as String,
        username: json['username'] as String,
        email: json['email'] as String,
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
      );

  UserEntity toEntity() => UserEntity(
        id: id,
        username: username,
        email: email,
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
}

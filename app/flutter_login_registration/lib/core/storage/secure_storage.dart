import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Encrypted key-value storage backed by Keychain (iOS) / Keystore (Android).
class SecureStorage {
  SecureStorage._();

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const _kAccessToken = 'access_token';
  static const _kRefreshToken = 'refresh_token';
  static const _kUserId = 'user_id';
  static const _kUsername = 'username';
  static const _kEmail = 'email';

  // ── write ──────────────────────────────────────────────────────────────────

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _kAccessToken, value: accessToken),
      _storage.write(key: _kRefreshToken, value: refreshToken),
    ]);
  }

  static Future<void> saveUser({
    required String id,
    required String username,
    required String email,
  }) async {
    await Future.wait([
      _storage.write(key: _kUserId, value: id),
      _storage.write(key: _kUsername, value: username),
      _storage.write(key: _kEmail, value: email),
    ]);
  }

  // ── read ───────────────────────────────────────────────────────────────────

  static Future<String?> getAccessToken() => _storage.read(key: _kAccessToken);
  static Future<String?> getRefreshToken() => _storage.read(key: _kRefreshToken);

  static Future<Map<String, String?>> getUser() async {
    final results = await Future.wait([
      _storage.read(key: _kUserId),
      _storage.read(key: _kUsername),
      _storage.read(key: _kEmail),
    ]);
    return {'id': results[0], 'username': results[1], 'email': results[2]};
  }

  static Future<bool> hasSession() async {
    final token = await _storage.read(key: _kAccessToken);
    return token != null && token.isNotEmpty;
  }

  // ── delete ─────────────────────────────────────────────────────────────────

  static Future<void> clear() => _storage.deleteAll();
}

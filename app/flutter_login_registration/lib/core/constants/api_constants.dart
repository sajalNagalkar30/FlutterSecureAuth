class ApiConstants {
  ApiConstants._();

  // Set per device via --dart-define=BASE_URL=... in .vscode/launch.json
  // Android emulator: https://10.0.2.2:9000/api/auth
  // iOS Simulator:    https://localhost:9000/api/auth
  // Physical device:  https://<your-mac-lan-ip>:9000/api/auth
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://10.45.44.173:9000/api/auth',
  );

  // SSL Pinning — empty string disables pinning (dev with self-signed cert)
  static const String sslPinnedFingerprint = '';

  // HTTPS is active
  static const bool useHttps = true;

  // Dio timeouts (ms)
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;
  static const int sendTimeout = 15000;
}

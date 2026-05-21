class ApiConstants {
  ApiConstants._();

  // Set per device via --dart-define=BASE_URL=... in .vscode/launch.json
  // Android emulator: https://10.0.2.2:9000/api/auth
  // iOS Simulator:    https://localhost:9000/api/auth
  // Physical device:  https://<your-mac-lan-ip>:9000/api/auth
  // static const String baseUrl = String.fromEnvironment(
  //   'BASE_URL',
  //   defaultValue: 'https://10.45.44.173:9000/api/auth',
  // );

  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    // backend routes are mounted at: /api/auth
    defaultValue: 'https://fluttersecureauth.onrender.com/api/auth',
  );

  // SSL Pinning — SHA-256 of public key (SPKI) from fluttersecureauth.onrender.com
  static const String sslPinnedFingerprint = 'T4eoRdbfIYF3G9IOGamqR3Vgye2bNLHQTSCOY8u3y5w=';

  // HTTPS is active
  static const bool useHttps = true;

  // Dio timeouts (ms) — increased for Render free tier cold start (~30-60s)
  static const int connectTimeout = 90000;
  static const int receiveTimeout = 90000;
  static const int sendTimeout = 90000;
}

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import 'auth_interceptor.dart';

/// Singleton Dio client with:
///  • SSL certificate pinning (SHA-256 fingerprint comparison)
///  • Bearer-token injection via [AuthInterceptor]
///  • Automatic silent token refresh on 401
///  • Logging in debug builds only
class DioClient {
  DioClient._();

  static Dio? _instance;

  static Dio get instance {
    _instance ??= _build();
    return _instance!;
  }

  static Dio _build() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeout),
        receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
        sendTimeout: const Duration(milliseconds: ApiConstants.sendTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // Custom header so the server can identify Flutter clients
          'X-Client': 'flutter',
        },
      ),
    );

    // ── SSL Pinning (non-web only) ─────────────────────────────────────────
    if (!kIsWeb && ApiConstants.useHttps) {
      (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          // Disable pinning in dev when no fingerprint is set
          if (ApiConstants.sslPinnedFingerprint.isEmpty) return true;

          // Pin against the public key (SPKI SHA-256) — survives cert renewal
          final spkiFingerprint = _spkiFingerprint(cert.der);
          final trusted = spkiFingerprint == ApiConstants.sslPinnedFingerprint;

          if (!trusted && kDebugMode) {
            debugPrint('[SSL] ⚠️  Public key fingerprint mismatch!');
            debugPrint('[SSL]   expected : ${ApiConstants.sslPinnedFingerprint}');
            debugPrint('[SSL]   received : $spkiFingerprint');
          }
          return trusted;
        };
        return client;
      };
    }

    // ── Interceptors ────────────────────────────────────────────────────────
    dio.interceptors.add(AuthInterceptor(dio));

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          error: true,
          logPrint: (o) => debugPrint('[DIO] $o'),
        ),
      );
    }

    return dio;
  }

  /// Extracts the SubjectPublicKeyInfo (SPKI) from a DER cert and returns
  /// its SHA-256 as base64 — matches `openssl x509 -pubkey | openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | base64`
  static String _spkiFingerprint(Uint8List der) {
    final spki = _extractSpki(der);
    final digest = _sha256(spki ?? der);
    return base64.encode(digest);
  }

  /// Parses the DER-encoded certificate and extracts the raw SPKI bytes.
  /// Returns null if parsing fails (falls back to full DER hash).
  static Uint8List? _extractSpki(Uint8List der) {
    try {
      // DER structure: SEQUENCE { SEQUENCE { ... tbsCertificate ... } ... }
      // tbsCertificate SEQUENCE contains subjectPublicKeyInfo at a known offset
      // Walk the ASN.1 to find the SPKI field
      int i = 0;

      // Outer SEQUENCE (certificate)
      if (der[i++] != 0x30) return null;
      i += _skipLength(der, i);

      // tbsCertificate SEQUENCE
      if (der[i++] != 0x30) return null;
      final tbsLenBytes = _readLength(der, i);
      final tbsStart = i + tbsLenBytes.$2;
      final tbsEnd = tbsStart + tbsLenBytes.$1;
      i = tbsStart;

      // Skip version [0] EXPLICIT if present
      if (der[i] == 0xa0) { i++; i += _skipLength(der, i); }
      // Skip serialNumber INTEGER
      if (der[i] == 0x02) { i++; i += _skipLength(der, i); }
      // Skip signature AlgorithmIdentifier SEQUENCE
      if (der[i] == 0x30) { i++; i += _skipLength(der, i); }
      // Skip issuer Name SEQUENCE
      if (der[i] == 0x30) { i++; i += _skipLength(der, i); }
      // Skip validity SEQUENCE
      if (der[i] == 0x30) { i++; i += _skipLength(der, i); }
      // Skip subject Name SEQUENCE
      if (der[i] == 0x30) { i++; i += _skipLength(der, i); }

      if (i >= tbsEnd) return null;

      // Next field is subjectPublicKeyInfo SEQUENCE
      if (der[i] != 0x30) return null;
      final spkiStart = i;
      i++;
      final spkiLen = _readLength(der, i);
      final spkiEnd = i + spkiLen.$2 + spkiLen.$1;

      return Uint8List.fromList(der.sublist(spkiStart, spkiEnd));
    } catch (_) {
      return null;
    }
  }

  static int _skipLength(Uint8List der, int i) {
    final r = _readLength(der, i);
    return r.$2 + r.$1;
  }

  static (int, int) _readLength(Uint8List der, int i) {
    if (der[i] & 0x80 == 0) return (der[i], 1);
    final numBytes = der[i] & 0x7f;
    int len = 0;
    for (int j = 1; j <= numBytes; j++) { len = (len << 8) | der[i + j]; }
    return (len, 1 + numBytes);
  }

  // Minimal pure-Dart SHA-256 to avoid adding the `crypto` package.
  // Implements FIPS PUB 180-4.
  static List<int> _sha256(Uint8List data) {
    // Initial hash values
    final h = [
      0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a,
      0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19,
    ];

    // Round constants
    const k = [
      0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5,
      0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
      0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
      0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
      0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc,
      0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
      0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7,
      0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
      0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
      0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
      0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3,
      0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
      0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5,
      0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
      0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
      0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
    ];

    int rotr(int x, int n) => ((x >>> n) | (x << (32 - n))) & 0xFFFFFFFF;
    int add(int a, int b) => (a + b) & 0xFFFFFFFF;

    // Pre-processing: padding
    final msgLen = data.length;
    final bitLen = msgLen * 8;
    final padded = <int>[...data, 0x80];
    while (padded.length % 64 != 56) { padded.add(0); }
    for (var i = 7; i >= 0; i--) { padded.add((bitLen >> (i * 8)) & 0xff); }

    // Process each 512-bit (64-byte) block
    for (var i = 0; i < padded.length; i += 64) {
      final w = List<int>.filled(64, 0);
      for (var j = 0; j < 16; j++) {
        w[j] = (padded[i + j * 4] << 24) |
            (padded[i + j * 4 + 1] << 16) |
            (padded[i + j * 4 + 2] << 8) |
            padded[i + j * 4 + 3];
      }
      for (var j = 16; j < 64; j++) {
        final s0 = rotr(w[j - 15], 7) ^ rotr(w[j - 15], 18) ^ (w[j - 15] >>> 3);
        final s1 = rotr(w[j - 2], 17) ^ rotr(w[j - 2], 19) ^ (w[j - 2] >>> 10);
        w[j] = add(add(add(w[j - 16], s0), w[j - 7]), s1);
      }

      var a = h[0], b = h[1], c = h[2], d = h[3];
      var e = h[4], f = h[5], g = h[6], hh = h[7];

      for (var j = 0; j < 64; j++) {
        final s1 = rotr(e, 6) ^ rotr(e, 11) ^ rotr(e, 25);
        final ch = (e & f) ^ (~e & g) & 0xFFFFFFFF;
        final temp1 = add(add(add(add(hh, s1), ch), k[j]), w[j]);
        final s0 = rotr(a, 2) ^ rotr(a, 13) ^ rotr(a, 22);
        final maj = (a & b) ^ (a & c) ^ (b & c);
        final temp2 = add(s0, maj);
        hh = g; g = f; f = e; e = add(d, temp1);
        d = c; c = b; b = a; a = add(temp1, temp2);
      }

      h[0] = add(h[0], a); h[1] = add(h[1], b);
      h[2] = add(h[2], c); h[3] = add(h[3], d);
      h[4] = add(h[4], e); h[5] = add(h[5], f);
      h[6] = add(h[6], g); h[7] = add(h[7], hh);
    }

    return h.expand((word) => [
          (word >> 24) & 0xff,
          (word >> 16) & 0xff,
          (word >> 8) & 0xff,
          word & 0xff,
        ]).toList();
  }
}

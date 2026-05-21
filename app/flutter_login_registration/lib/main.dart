import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'app.dart';
import 'core/di/injection.dart';
import 'core/security/device_security.dart';

void main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);

  // ── Reverse Engineering Protection ───────────────────────────────────────
  // Disable screenshots and screen recording on Android
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));

  // ── Root / Jailbreak Detection ────────────────────────────────────────────
  final isCompromised = await DeviceSecurity.isDeviceCompromised();
  if (isCompromised) {
    // Show blocking UI and prevent app from loading
    runApp(const _BlockedApp());
    return;
  }

  // ── Dependency Injection ──────────────────────────────────────────────────
  setupDependencies();

  runApp(const App());
}

/// Shown when root/jailbreak is detected — blocks all app functionality.
class _BlockedApp extends StatelessWidget {
  const _BlockedApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF0F0E17),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF5252).withAlpha(25),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: const Color(0xFFFF5252).withAlpha(100)),
                  ),
                  child: const Icon(Icons.security,
                      color: Color(0xFFFF5252), size: 40),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Security Alert',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'This app cannot run on a rooted or jailbroken device. '
                  'Your device security has been compromised.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFB0B3C6),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

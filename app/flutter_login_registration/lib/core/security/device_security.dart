import 'package:flutter/material.dart';
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';

/// Checks if the device is rooted (Android) or jailbroken (iOS).
/// Call once at app startup before running the app.
class DeviceSecurity {
  DeviceSecurity._();

  static Future<bool> isDeviceCompromised() async {
    try {
      final isJailbroken = await FlutterJailbreakDetection.jailbroken;
      final isDeveloperMode = await FlutterJailbreakDetection.developerMode;
      return isJailbroken || isDeveloperMode;
    } catch (_) {
      return false;
    }
  }

  /// Shows a blocking dialog and exits the app if device is compromised.
  static Future<void> enforceDeviceSecurity(BuildContext context) async {
    final compromised = await isDeviceCompromised();
    if (!compromised) return;

    if (!context.mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor: const Color(0xFF16213E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFFF5252)),
          ),
          title: const Row(
            children: [
              Icon(Icons.security, color: Color(0xFFFF5252)),
              SizedBox(width: 10),
              Text(
                'Security Alert',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          content: const Text(
            'This app cannot run on a rooted or jailbroken device. '
            'Your device security has been compromised.',
            style: TextStyle(color: Color(0xFFB0B3C6)),
          ),
          actions: [
            TextButton(
              onPressed: () => _exitApp(),
              child: const Text(
                'Exit App',
                style: TextStyle(color: Color(0xFFFF5252)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _exitApp() {
    // Gracefully exit the app
    WidgetsBinding.instance.handleAppLifecycleStateChanged(
      AppLifecycleState.detached,
    );
  }
}

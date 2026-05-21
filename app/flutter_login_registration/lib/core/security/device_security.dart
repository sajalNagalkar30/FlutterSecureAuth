import 'dart:io';
import 'package:flutter/foundation.dart';

/// Pure Dart/Flutter root & jailbreak detection — no third-party package.
/// Uses file system and process checks that work on both Android and iOS.
class DeviceSecurity {
  DeviceSecurity._();

  // ── iOS jailbreak indicators ─────────────────────────────────────────────
  static const _jailbreakPaths = [
    '/Applications/Cydia.app',
    '/Applications/blackra1n.app',
    '/Applications/FakeCarrier.app',
    '/Applications/Icy.app',
    '/Applications/IntelliScreen.app',
    '/Applications/SBSettings.app',
    '/Library/MobileSubstrate/MobileSubstrate.dylib',
    '/Library/MobileSubstrate/DynamicLibraries/Veency.plist',
    '/bin/bash',
    '/bin/sh',
    '/usr/sbin/sshd',
    '/usr/libexec/sftp-server',
    '/etc/apt',
    '/private/var/lib/apt',
    '/private/var/lib/cydia',
    '/private/var/stash',
    '/private/var/mobile/Library/SBSettings/Themes',
  ];

  // ── Android root indicators ───────────────────────────────────────────────
  static const _rootPaths = [
    '/system/app/Superuser.apk',
    '/system/app/SuperSU.apk',
    '/system/xbin/su',
    '/system/bin/su',
    '/system/bin/.ext/.su',
    '/system/bin/failsafe/su',
    '/system/sd/xbin/su',
    '/sbin/su',
    '/su/bin/su',
    '/data/local/su',
    '/data/local/bin/su',
    '/data/local/xbin/su',
    '/data/adb/magisk',
    '/sbin/.magisk',
    '/cache/.disable_selinux',
    '/system/xbin/busybox',
  ];

  /// Returns true if device is rooted (Android) or jailbroken (iOS).
  /// Always returns false in debug mode to allow dev testing.
  static Future<bool> isDeviceCompromised() async {
    if (kDebugMode) return false;

    try {
      if (Platform.isIOS) return await _checkIOS();
      if (Platform.isAndroid) return await _checkAndroid();
      return false;
    } catch (_) {
      return false;
    }
  }

  // ── iOS checks ────────────────────────────────────────────────────────────

  static Future<bool> _checkIOS() async {
    // 1. Check for known jailbreak files
    for (final path in _jailbreakPaths) {
      try {
        if (File(path).existsSync()) return true;
        if (Directory(path).existsSync()) return true;
      } catch (_) {}
    }

    // 2. Try writing outside app sandbox — only possible on jailbroken device
    try {
      const testPath = '/private/jailbreak_test_flutter.txt';
      final file = File(testPath);
      file.writeAsStringSync('test');
      file.deleteSync();
      return true; // write succeeded → jailbroken
    } catch (_) {
      // Expected on a clean device
    }

    // 3. Check if Cydia URL scheme is accessible
    try {
      final result = await Process.run('ls', ['/Applications']);
      if (result.stdout.toString().contains('Cydia')) return true;
    } catch (_) {}

    return false;
  }

  // ── Android checks ────────────────────────────────────────────────────────

  static Future<bool> _checkAndroid() async {
    // 1. Check for known root binaries/files
    for (final path in _rootPaths) {
      try {
        if (File(path).existsSync()) return true;
      } catch (_) {}
    }

    // 2. Try executing su — succeeds only on rooted devices
    try {
      final result = await Process.run('su', ['-c', 'id'])
          .timeout(const Duration(seconds: 2));
      if (result.exitCode == 0) return true;
    } catch (_) {}

    // 3. Check build tags for test-keys (common on rooted ROMs)
    try {
      final result = await Process.run('getprop', ['ro.build.tags'])
          .timeout(const Duration(seconds: 2));
      final tags = result.stdout.toString().toLowerCase();
      if (tags.contains('test-keys')) return true;
    } catch (_) {}

    return false;
  }
}

import 'package:safe_device/safe_device.dart';

class DeviceSecurity {
  DeviceSecurity._();

  /// Returns true if device is rooted (Android) or jailbroken (iOS).
  static Future<bool> isDeviceCompromised() async {
    try {
      final isJailBroken = await SafeDevice.isJailBroken;
      final isRealDevice = await SafeDevice.isRealDevice;
      return isJailBroken || !isRealDevice;
    } catch (_) {
      return false;
    }
  }
}

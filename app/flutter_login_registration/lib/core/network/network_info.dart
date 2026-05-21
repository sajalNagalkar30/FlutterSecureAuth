import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkInfo {
  NetworkInfo._();

  /// Returns true when at least one active connection is available.
  static Future<bool> get isConnected async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }
}

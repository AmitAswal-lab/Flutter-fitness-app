import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

class DeviceUtils {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  static bool? _isSimulator;

  /// Check if running on simulator/emulator
  static Future<bool> isSimulator() async {
    if (_isSimulator != null) return _isSimulator!;

    if (Platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      _isSimulator = !iosInfo.isPhysicalDevice;
    } else if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      _isSimulator = !androidInfo.isPhysicalDevice;
    } else {
      _isSimulator = false;
    }

    return _isSimulator!;
  }

  /// Cached value for sync access after initial check
  static bool get isSimulatorSync => _isSimulator ?? false;
}

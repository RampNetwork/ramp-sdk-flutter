
import 'dart:async';

import 'package:flutter/services.dart';

class RampFlutter {
  static const MethodChannel _channel = MethodChannel('ramp_flutter');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}

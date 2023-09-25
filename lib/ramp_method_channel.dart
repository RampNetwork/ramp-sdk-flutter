import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'ramp_platform_interface.dart';

/// An implementation of [RampPlatform] that uses method channels.
class MethodChannelRamp extends RampPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('ramp');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}

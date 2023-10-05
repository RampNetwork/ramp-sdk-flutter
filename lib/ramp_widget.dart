import 'package:flutter/widgets.dart';
import 'package:ramp/controller/ramp_controller.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'ramp_platform_interface.dart';

class Ramp {
  Future<String?> getPlatformVersion() {
    return RampPlatform.instance.getPlatformVersion();
  }
}

class RampWidget extends StatelessWidget {
  final RampController controller;

  const RampWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: controller.webViewController);
  }
}

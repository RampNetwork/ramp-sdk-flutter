import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'ramp_webview_controller.dart';

/// Fullscreen page that hosts the Ramp widget WebView.
class RampWebViewPage extends StatelessWidget {
  const RampWebViewPage({super.key, required this.controller});

  final RampWebViewController controller;

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: controller.webViewController);
  }
}

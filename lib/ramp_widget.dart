import 'package:flutter/widgets.dart';
import 'package:ramp/model/configuration.dart';
import 'package:ramp/controller/event_delegate.dart';
import 'package:ramp/controller/ramp_controller.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'ramp_platform_interface.dart';

class Ramp {
  Future<String?> getPlatformVersion() {
    return RampPlatform.instance.getPlatformVersion();
  }
}

class RampWidget2 extends StatelessWidget {
  RampController controller;

  RampWidget2({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: controller.webViewController);
  }

  void setController(RampController controller) {
    this.controller = controller;
  } 
}

class RampWidget extends StatefulWidget {
  Configuration? configuration;
  EventDelegate? eventDelegate;

  RampWidget({super.key, this.configuration, this.eventDelegate});

  @override
  State<RampWidget> createState() => _RampWidgetState();
}

class _RampWidgetState extends State<RampWidget> {
  late WebViewController _controller;

  @override
  void initState() {
    super.initState();
    onOnrampPurchaseCreated = widget.onOnrampPurchaseCreated;
    onSendCryptoRequested = widget.onSendCryptoRequested;
    onOfframpSaleCreated = widget.onOfframpSaleCreated;
    onRampClosed = widget.onRampClosed;
    initPlatformState();
  }

  Future<void> initPlatformState() async {

    PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }
    _controller = WebViewController.fromPlatformCreationParams(params)
    ..setNavigationDelegate(delegate)
    // if (_controller.platform is AndroidWebViewController) {
    //   (_controller.platform as AndroidWebViewController)
    //       .setMediaPlaybackRequiresUserGesture(false);
    // }
    _controller.addJavaScriptChannel(
      'RampInstantMobile',
      onMessageReceived: _handleJavaScriptMessage,
    );
    _controller.loadRequest(rampUrl);
  }

  @override
  Widget build(BuildContext context) {
  }


}

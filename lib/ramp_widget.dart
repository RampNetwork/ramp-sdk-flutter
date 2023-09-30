import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/widgets.dart';
import 'package:ramp/model/configuration.dart';
import 'package:ramp/controller/event_delegate.dart';
import 'package:ramp/model/offramp_sale.dart';
import 'package:ramp/model/onramp_purchase.dart';
import 'package:ramp/model/send_crypto_payload.dart';
import 'package:ramp/controller/ramp_controller.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'ramp_platform_interface.dart';

// import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class Ramp {
  Future<String?> getPlatformVersion() {
    return RampPlatform.instance.getPlatformVersion();
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
  final JsonDecoder _jsonDecoder = const JsonDecoder();

  late WebViewController _controller;
  late Function(OnrampPurchase, String, Uri)? onOnrampPurchaseCreated;
  late Function(OfframpSale, String, Uri)? onOfframpSaleCreated;
  late Function(SendCryptoPayload)? onSendCryptoRequested;
  late Function()? onRampClosed;

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
    return WebViewWidget(controller: _controller);
  }


}

import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/widgets.dart';
import 'package:ramp/models/offramp_sale.dart';
import 'package:ramp/models/onramp_purchase.dart';
import 'package:ramp/models/send_crypto_payload.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'ramp_platform_interface.dart';

// import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class Ramp {
  Future<String?> getPlatformVersion() {
    return RampPlatform.instance.getPlatformVersion();
  }
}

class RampWidget extends StatefulWidget {
  final Function(OnrampPurchase purchase, String purchaseViewToken, Uri apiUrl)?
      onOnrampPurchaseCreated;
  final Function(SendCryptoPayload payload)? onSendCryptoRequested;
  final Function(OfframpSale sale, String saleViewToken, Uri apiUrl)?
      onOfframpSaleCreated;
  final Function()? onRampClosed;

  const RampWidget({
    super.key,
    this.onOnrampPurchaseCreated,
    this.onSendCryptoRequested,
    this.onOfframpSaleCreated,
    this.onRampClosed,
  });

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
    var rampUrl = Uri(
      scheme: 'https',
      host: 'app.dev.ramp-network.org',
      queryParameters: {
        'hostAppName': 'Flutter App',
        'hostApiKey': '3qncr4yvxfpro6endeaeu6npkh8qc23e9uadtazq',
        'variant': 'sdk-mobile',
        'enabledFlows': 'ONRAMP,OFFRAMP',
        'defaultFlow': 'ONRAMP',
        'userEmailAddress': 'mateusz.jablonski@ramp.network',
        'fiatCurrency': 'EUR',
        'fiatValue': '2',
        'swapAsset': 'GOERLI_ETH',
        'userAddress': '0x71C7656EC7ab88b098defB751B7401B5f6d8976F',
        'useSendCryptoCallbackVersion': '1',
      },
    );
    PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }
    _controller = WebViewController.fromPlatformCreationParams(params);
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

  void _handleJavaScriptMessage(JavaScriptMessage message) {
    Map<String, dynamic> messageJson;
    try {
      messageJson = _jsonDecoder.convert(message.message);
    } catch (_) {
      // if decoding JS message into map fails, just ignore it
      return;
    }
    String type = messageJson['type'];
    switch (type) {
      case "WIDGET_CONFIG_DONE":
        developer.log('🟢 widget configuration done');

      case "WIDGET_CONFIG_FAILED":
        developer.log('🔴 widget configuration failed');

      case "PURCHASE_CREATED":
        developer.log('🟢 purchase created');
        Map<String, dynamic> payloadJson = messageJson['payload'];
        Map<String, dynamic> purchaseJson = payloadJson['purchase'];
        String purchaseViewToken = payloadJson['purchaseViewToken'];
        String apiUrlString = payloadJson['apiUrl'];
        Uri apiUrl = Uri.parse(apiUrlString);
        OnrampPurchase purchase = OnrampPurchase.fromJson(purchaseJson);
        developer.inspect(purchase);
        if (onOnrampPurchaseCreated != null) {
          onOnrampPurchaseCreated!(purchase, purchaseViewToken, apiUrl);
        }

      case "WIDGET_CLOSE":
        developer.log('🟢 widget close requested');

      case "CLOSE":
        developer.log('🟡 widget close request duplicate');

      default:
        developer.log('🔵 unhandled JS message');
        developer.log(messageJson.toString());
    }
  }
}

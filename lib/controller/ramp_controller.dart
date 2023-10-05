import 'dart:convert';
import 'dart:developer' as developer;

import 'package:ramp/model/configuration.dart';
import 'package:ramp/controller/event_delegate.dart';
import 'package:ramp/model/offramp_sale.dart';
import 'package:ramp/model/onramp_purchase.dart';
import 'package:ramp/model/send_crypto_payload.dart';

import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class RampController {
  late final WebViewController webViewController;
  Configuration? configuration;
  EventDelegate? eventDelegate;

  final JsonDecoder _jsonDecoder = const JsonDecoder();
  static const jsMessageChannelName = "RampInstantMobile";

  RampController() {
    PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }
    webViewController = WebViewController.fromPlatformCreationParams(params);
    if (webViewController.platform is AndroidWebViewController) {
      (webViewController.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    webViewController.addJavaScriptChannel(
      RampController.jsMessageChannelName,
      onMessageReceived: _handleJavaScriptMessage,
    );
  }

  void start() {
    Configuration configuration = this.configuration ?? Configuration();
    developer.log('🟣 ramp controller started');
    developer.inspect(configuration);
    Uri configurationUri = configuration.configurationUrl();
    webViewController.loadRequest(configurationUri);
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
        developer.log('🟢 onramp purchase created');
        _handlePurchaseCreatedEvent(messageJson);

      case "OFFRAMP_SALE_CREATED":
        developer.log('🟢 offramp sale created');
        _handleOfframpSaleCreatedEvent(messageJson);

      case "SEND_CRYPTO":
        developer.log('🟢 send crypto');
        _handleSendCryptoEvent(messageJson);

      case "WIDGET_CLOSE":
        developer.log('🟢 widget close requested');
        _handleWidgetCloseEvent(messageJson);

      case "CLOSE":
        developer.log('🟡 widget close request duplicate');

      default:
        developer.log('🔵 unhandled JS message');
        developer.log(messageJson.toString());
    }
  }

  void _handlePurchaseCreatedEvent(Map<String, dynamic> messageJson) {
    Map<String, dynamic> payloadJson = messageJson['payload'];
    Map<String, dynamic> purchaseJson = payloadJson['purchase'];
    String purchaseViewToken = payloadJson['purchaseViewToken'];
    String apiUrlString = payloadJson['apiUrl'];
    Uri apiUrl = Uri.parse(apiUrlString);
    OnrampPurchase purchase = OnrampPurchase.fromMap(purchaseJson);

    developer.inspect(purchase);

    if (eventDelegate != null &&
        eventDelegate!.onOnrampPurchaseCreated != null) {
      eventDelegate!.onOnrampPurchaseCreated!(
          purchase, purchaseViewToken, apiUrl);
    }
  }

  void _handleOfframpSaleCreatedEvent(Map<String, dynamic> messageJson) {
    Map<String, dynamic> payloadJson = messageJson['payload'];
    Map<String, dynamic> saleJson = payloadJson['sale'];
    String saleViewToken = payloadJson['saleViewToken'];
    String apiUrlString = payloadJson['apiUrl'];
    Uri apiUrl = Uri.parse(apiUrlString);
    OfframpSale sale = OfframpSale.fromMap(saleJson);

    developer.inspect(sale);

    if (eventDelegate != null && eventDelegate!.onOfframpSaleCreated != null) {
      eventDelegate!.onOfframpSaleCreated!(sale, saleViewToken, apiUrl);
    }
  }

  void _handleSendCryptoEvent(Map<String, dynamic> messageJson) {
    Map<String, dynamic> payloadJson = messageJson['payload'];
    SendCryptoPayload sendCryptoRequest =
        SendCryptoPayload.fromMap(payloadJson);

    developer.inspect(sendCryptoRequest);

    if (eventDelegate != null && eventDelegate!.onSendCryptoRequested != null) {
      eventDelegate!.onSendCryptoRequested!(sendCryptoRequest);
    }
  }

  void _handleWidgetCloseEvent(Map<String, dynamic> messageJson) {
    if (eventDelegate != null && eventDelegate!.onRampClosed != null) {
      eventDelegate!.onRampClosed!();
    }
  }
}

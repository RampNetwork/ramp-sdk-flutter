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
  late WebViewController _controller;
  Configuration? _configuration;
  EventDelegate? _eventDelegate;

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
    _controller = WebViewController.fromPlatformCreationParams(params);
    if (_controller.platform is AndroidWebViewController) {
      (_controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    _controller.addJavaScriptChannel(
      RampController.jsMessageChannelName,
      onMessageReceived: _handleJavaScriptMessage,
    );
  }

  void setConfiguration(Configuration configuration) {
    _configuration = configuration;
  }

  void setEventDeletage(EventDelegate eventDelegate) {
    _eventDelegate = eventDelegate;
  }

  void start() {
    Configuration configuration = _configuration ?? Configuration();
    Uri configurationUri = configuration.configurationUrl();
    _controller.loadRequest(configurationUri);
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
        _handleWidgetCloseEvent();

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

    if (_eventDelegate != null &&
        _eventDelegate!.onOnrampPurchaseCreated != null) {
      _eventDelegate!.onOnrampPurchaseCreated!(
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

    if (_eventDelegate != null &&
        _eventDelegate!.onOfframpSaleCreated != null) {
      _eventDelegate!.onOfframpSaleCreated!(sale, saleViewToken, apiUrl);
    }
  }

  void _handleSendCryptoEvent(Map<String, dynamic> messageJson) {
    Map<String, dynamic> payloadJson = messageJson['payload'];
    SendCryptoPayload sendCryptoRequest =
        SendCryptoPayload.fromMap(payloadJson);

    developer.inspect(sendCryptoRequest);

    if (_eventDelegate != null &&
        _eventDelegate!.onSendCryptoRequested != null) {
      _eventDelegate!.onSendCryptoRequested!(sendCryptoRequest);
    }
  }

  void _handleWidgetCloseEvent() {
    if (_eventDelegate != null && _eventDelegate!.onRampClosed != null) {
      _eventDelegate!.onRampClosed!();
    }
  }
}

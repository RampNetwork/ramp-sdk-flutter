import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import '../offramp_sale.dart';
import '../onramp_purchase.dart';
import '../send_crypto_payload.dart';

/// Owns the widget WebView and forwards Ramp Instant JS events to Dart callbacks.
class RampWebViewController {
  RampWebViewController(this._widgetUrl);

  static const _channelName = 'RampInstantMobile';

  final Uri _widgetUrl;
  WebViewController? _webView;

  Function(OnrampPurchase, String, String)? onOnrampPurchaseCreated;
  Function(OfframpSale, String, String)? onOfframpSaleCreated;
  Function(SendCryptoPayload)? onSendCryptoRequested;
  Function()? onClosed;

  WebViewController get webViewController =>
      _webView ??= _createWebViewController();

  WebViewController _createWebViewController() {
    final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) => _onNavigationRequest(request),
        ),
      )
      ..addJavaScriptChannel(
        _channelName,
        onMessageReceived: (message) => handleJavaScriptMessage(message.message),
      )
      ..setOnPlatformPermissionRequest((request) {
        final onlyCamera = request.types.every(
          (type) => type == WebViewPermissionResourceType.camera,
        );
        if (onlyCamera) {
          request.grant();
        } else {
          request.deny();
        }
      });

    final platform = controller.platform;
    if (platform is AndroidWebViewController) {
      platform.setMediaPlaybackRequiresUserGesture(false);
      // Document upload on Android needs a host-provided file picker; not wired
      // here. KYC camera is handled via setOnPlatformPermissionRequest.
    }

    controller.loadRequest(_widgetUrl);
    return controller;
  }

  Future<NavigationDecision> _onNavigationRequest(
    NavigationRequest request,
  ) async {
    final uri = Uri.tryParse(request.url);
    if (uri == null) {
      return NavigationDecision.prevent;
    }

    if (_isWidgetNavigation(uri)) {
      return NavigationDecision.navigate;
    }

    await _openExternal(uri);
    return NavigationDecision.prevent;
  }

  bool _isWidgetNavigation(Uri uri) {
    if (uri.scheme == 'about') return true;
    if (uri.host.isEmpty) return true;
    if (uri.host == _widgetUrl.host) return true;
    // Allow same-site Ramp hosts during widget redirects.
    return _trustedRampHost.hasMatch(uri.host);
  }

  Future<void> _openExternal(Uri uri) async {
    try {
      if (uri.scheme == 'intent') {
        final fallback = _intentFallbackUrl(uri);
        if (fallback != null) {
          await launchUrl(fallback, mode: LaunchMode.externalApplication);
        }
        return;
      }
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (error, stackTrace) {
      debugPrint('RampFlutter: failed to open $uri: $error\n$stackTrace');
    }
  }

  /// Extracts a browser URL from an Android `intent://` URI when present.
  static Uri? _intentFallbackUrl(Uri intentUri) {
    final browserFallback = intentUri.queryParameters['browser_fallback_url'];
    if (browserFallback != null && browserFallback.isNotEmpty) {
      return Uri.tryParse(browserFallback);
    }
    return null;
  }

  Future<void> sendCrypto(String? transactionHash) {
    final webView = _webView;
    if (webView == null) {
      return Future.value();
    }
    final message = jsonEncode({
      'type': 'SEND_CRYPTO_RESULT',
      'eventVersion': 1,
      'payload': {'txHash': transactionHash},
    });
    return webView.runJavaScript(
      'window.postMessage($message, "${_widgetUrl.origin}");',
    );
  }

  /// Stops the page and releases capture. Call when the route is dismissed.
  void dispose() {
    _webView
      ?..removeJavaScriptChannel(_channelName)
      ..loadRequest(Uri.parse('about:blank'));
    _webView = null;
  }

  @visibleForTesting
  void handleJavaScriptMessage(String message) {
    final dynamic event;
    try {
      event = jsonDecode(message);
    } on FormatException {
      return;
    }
    if (event is! Map) return;
    final eventMap = Map<String, dynamic>.from(event);

    final payload = eventMap['payload'];
    switch (eventMap['type']) {
      case 'PURCHASE_CREATED':
        if (payload is! Map) return;
        final payloadMap = Map<String, dynamic>.from(payload);
        onOnrampPurchaseCreated?.call(
          OnrampPurchase.fromArguments(payloadMap['purchase']),
          payloadMap['purchaseViewToken'] as String? ?? '',
          payloadMap['apiUrl'] as String? ?? '',
        );
        break;
      case 'OFFRAMP_SALE_CREATED':
        if (payload is! Map) return;
        final payloadMap = Map<String, dynamic>.from(payload);
        onOfframpSaleCreated?.call(
          OfframpSale.fromArguments(payloadMap['sale']),
          payloadMap['saleViewToken'] as String? ?? '',
          payloadMap['apiUrl'] as String? ?? '',
        );
        break;
      case 'SEND_CRYPTO':
        onSendCryptoRequested?.call(
          SendCryptoPayload.fromArguments(payload),
        );
        break;
      case 'CLOSE':
      case 'WIDGET_CLOSE':
        onClosed?.call();
        break;
    }
  }
}

final _trustedRampHost = RegExp(
  r'^([a-z0-9-]+\.)*(ramp\.network|rampnetwork\.com|ramp-network\.org)$',
);

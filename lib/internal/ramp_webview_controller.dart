import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

/// Owns the widget WebView and forwards Ramp Instant JS events to Dart.
class RampWebViewController {
  RampWebViewController(this._widgetUrl);

  static const _channelName = 'RampInstantMobile';

  final Uri _widgetUrl;
  WebViewController? _webView;

  /// Called for every widget JS message.
  Function(Map<String, dynamic> event)? onWidgetEvent;

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

    debugPrint('RampFlutter: loading $_widgetUrl');

    final controller = WebViewController.fromPlatformCreationParams(
      params,
      onPermissionRequest: (request) {
        final onlyCamera = request.types.every(
          (type) => type == WebViewPermissionResourceType.camera,
        );
        if (onlyCamera) {
          request.grant();
        } else {
          request.deny();
        }
      },
    )
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) => _onNavigationRequest(request),
          onPageStarted: (url) => debugPrint('RampFlutter: page started $url'),
          onPageFinished: (url) => debugPrint('RampFlutter: page finished $url'),
          onWebResourceError: (error) {
            debugPrint(
              'RampFlutter: resource error '
              'code=${error.errorCode} type=${error.errorType} '
              'desc=${error.description} url=${error.url}',
            );
          },
          onHttpError: (error) {
            debugPrint(
              'RampFlutter: HTTP error '
              'status=${error.response?.statusCode} uri=${error.request?.uri}',
            );
          },
        ),
      )
      ..addJavaScriptChannel(
        _channelName,
        onMessageReceived: (message) => handleJavaScriptMessage(message.message),
      );

    final platform = controller.platform;
    if (platform is AndroidWebViewController) {
      platform.setMediaPlaybackRequiresUserGesture(false);
      // Document upload on Android needs a host-provided file picker; not wired
      // here. KYC camera is handled via onPermissionRequest.
    }

    controller.loadRequest(_widgetUrl);
    return controller;
  }

  Future<NavigationDecision> _onNavigationRequest(
    NavigationRequest request,
  ) async {
    final uri = Uri.tryParse(request.url);
    if (uri == null) {
      debugPrint('RampFlutter: blocking invalid navigation ${request.url}');
      return NavigationDecision.prevent;
    }

    if (_isWidgetNavigation(uri)) {
      debugPrint('RampFlutter: allow navigation $uri');
      return NavigationDecision.navigate;
    }

    debugPrint('RampFlutter: open external $uri');
    await _openExternal(uri);
    return NavigationDecision.prevent;
  }

  bool _isWidgetNavigation(Uri uri) {
    if (uri.scheme == 'about') return true;
    if (uri.host.isEmpty) return true;
    if (uri.host == _widgetUrl.host) return true;
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
      onWidgetEvent?.call({
        'type': 'RAW',
        'payload': message,
      });
      return;
    }
    if (event is! Map) {
      onWidgetEvent?.call({
        'type': 'RAW',
        'payload': event,
      });
      return;
    }
    onWidgetEvent?.call(Map<String, dynamic>.from(event));
  }
}

final _trustedRampHost = RegExp(
  r'^([a-z0-9-]+\.)*(ramp\.network|rampnetwork\.com|ramp-network\.org)$',
);

import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:ramp_flutter/configuration.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

/// Flutter API for embedding the Ramp Network widget.
///
/// The SDK provides the widget [view]; the host app owns presentation
/// (route, bottom sheet, dialog, etc.) and must call [dispose] when done.
class RampFlutter {
  RampFlutter(Configuration configuration)
      : this._(configuration.buildWidgetUrl());

  /// Test-only: load a concrete widget URL without going through [Configuration].
  @visibleForTesting
  RampFlutter.withWidgetUrl(Uri widgetUrl) : this._(widgetUrl);

  RampFlutter._(this._widgetUrl);

  static const _channelName = 'RampInstantMobile';

  final Uri _widgetUrl;
  WebViewController? _webView;

  /// Fires for every widget JS event.
  void Function(Map<String, dynamic> event)? onWidgetEvent;

  /// WebView that loads the Ramp widget. Embed this in your own UI.
  Widget get view => WebViewWidget(controller: _ensureWebView());

  WebViewController _ensureWebView() => _webView ??= _createWebView();

  WebViewController _createWebView() {
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
          // In-WebView navigations stay in the WebView.
          onNavigationRequest: (request) {
            debugPrint('RampFlutter: allow navigation ${request.url}');
            return NavigationDecision.navigate;
          },
          // New windows (`target=_blank` / `window.open`) open externally —
          // same idea as native createWebView / onCreateWindow handlers.
          onCreateWindow: (url) {
            debugPrint('RampFlutter: open external (create window) $url');
            final uri = Uri.tryParse(url);
            if (uri != null) {
              _openExternal(uri);
            }
          },
          onPageStarted: (url) => debugPrint('RampFlutter: page started $url'),
          onPageFinished: (url) =>
              debugPrint('RampFlutter: page finished $url'),
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
        onMessageReceived: (message) =>
            handleJavaScriptMessage(message.message),
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

  /// Completes an off-ramp send-crypto request with an optional [transactionHash].
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

  /// Releases the WebView. Call when your presentation is dismissed.
  void dispose() {
    _webView
      ?..removeJavaScriptChannel(_channelName)
      ..loadRequest(Uri.parse('about:blank'));
    _webView = null;
  }

  @visibleForTesting
  void handleJavaScriptMessage(String message) {
    // The widget posts to both Android (`RampInstantMobile` + JSON.stringify)
    // and iOS (`webkit.messageHandlers` + JS object). Flutter's channel
    // receives both; the object path arrives as a non-JSON Map-style string.
    // Prefer valid JSON event maps and ignore the rest.
    final dynamic event;
    try {
      event = jsonDecode(message);
    } on FormatException {
      return;
    }
    if (event is! Map) {
      return;
    }
    onWidgetEvent?.call(Map<String, dynamic>.from(event));
  }
}

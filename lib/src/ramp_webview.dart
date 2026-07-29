import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:ramp_flutter/host_event.dart';
import 'package:ramp_flutter/widget_event.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class RampWebView {
  RampWebView(this._widgetUrl);

  static const _channelName = 'RampInstantMobile';

  final Uri _widgetUrl;
  WebViewController? _controller;

  void Function(WidgetEvent event)? onWidgetEvent;

  Widget get view => WebViewWidget(controller: _ensureController());

  WebViewController _ensureController() => _controller ??= _createController();

  WebViewController _createController() {
    final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(allowsInlineMediaPlayback: true);
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    debugPrint('RampFlutter: loading $_widgetUrl');

    final controller =
        WebViewController.fromPlatformCreationParams(
            params,
            onPermissionRequest: (request) {
              final onlyCamera = request.types.every((type) => type == WebViewPermissionResourceType.camera);
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
              onNavigationRequest: (request) {
                debugPrint('RampFlutter: allow navigation ${request.url}');
                return NavigationDecision.navigate;
              },
              onCreateWindow: (url) {
                debugPrint('RampFlutter: open external (create window) $url');
                final uri = Uri.tryParse(url);
                if (uri != null) {
                  _openExternal(uri);
                }
              },
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

  Future<void> postHostEvent(HostEvent event) {
    final webView = _controller;
    if (webView == null) {
      return Future.value();
    }
    final message = jsonEncode(event.toJson());
    return webView.runJavaScript('window.postMessage($message, "${_widgetUrl.origin}");');
  }

  Future<void> sendCrypto(String? transactionHash) =>
      postHostEvent(SendCryptoResult.txHash(transactionHash));

  void dispose() {
    _controller
      ?..removeJavaScriptChannel(_channelName)
      ..loadRequest(Uri.parse('about:blank'));
    _controller = null;
  }

  void handleJavaScriptMessage(String message) {
    final dynamic decoded;
    try {
      decoded = jsonDecode(message);
    } on FormatException {
      return;
    }
    if (decoded is! Map) {
      return;
    }
    final event = WidgetEvent.tryParse(Map<String, dynamic>.from(decoded));
    if (event == null) {
      return;
    }
    onWidgetEvent?.call(event);
  }
}

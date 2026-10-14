import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:ramp_flutter/src/android_file_selector.dart';
import 'package:ramp_flutter/src/external_navigation.dart';
import 'package:ramp_flutter/src/host_event.dart';
import 'package:ramp_flutter/src/widget_event.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class RampWebView {
  RampWebView(this._widgetUrl);

  static const _channelName = 'RampInstantMobile';

  final Uri _widgetUrl;
  WebViewController? _controller;
  var _pageReady = false;
  final _pendingHostEvents = <({HostEvent event, Completer<void> done})>[];

  void Function(WidgetEvent event)? onWidgetEvent;

  Widget get view => WebViewWidget(controller: _ensureController());

  WebViewController _ensureController() => _controller ??= _createController();

  WebViewController _createController() {
    final controller =
        WebViewController.fromPlatformCreationParams(_platformParams(), onPermissionRequest: _onPermissionRequest)
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(_navigationDelegate())
          ..addJavaScriptChannel(
            _channelName,
            onMessageReceived: (message) => handleJavaScriptMessage(message.message),
          );

    _configureAndroid(controller);
    controller.loadRequest(_widgetUrl);
    return controller;
  }

  PlatformWebViewControllerCreationParams _platformParams() {
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      return WebKitWebViewControllerCreationParams(allowsInlineMediaPlayback: true);
    }
    return const PlatformWebViewControllerCreationParams();
  }

  NavigationDelegate _navigationDelegate() {
    return NavigationDelegate(
      onNavigationRequest: _onNavigationRequest,
      onCreateWindow: _onCreateWindow,
      onPageStarted: (_) => _pageReady = false,
      onPageFinished: (_) {
        _pageReady = true;
        _flushPendingHostEvents();
      },
      onWebResourceError: _onWebResourceError,
      onHttpError: _onHttpError,
    );
  }

  void _onPermissionRequest(WebViewPermissionRequest request) {
    final onlyCamera = request.types.every((type) => type == WebViewPermissionResourceType.camera);
    if (onlyCamera) {
      request.grant();
      return;
    }
    debugPrint('RampFlutter: deny WebView permission types=${request.types}');
    request.deny();
  }

  NavigationDecision _onNavigationRequest(NavigationRequest request) {
    final uri = Uri.tryParse(request.url);
    if (uri == null) {
      debugPrint('RampFlutter: block navigation — invalid URL ${request.url}');
      return NavigationDecision.prevent;
    }
    if (shouldOpenExternally(uri, _widgetUrl)) {
      openExternalUrl(uri);
      return NavigationDecision.prevent;
    }
    return NavigationDecision.navigate;
  }

  void _onCreateWindow(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      debugPrint('RampFlutter: create window ignored — invalid URL $url');
      return;
    }
    openExternalUrl(uri);
  }

  void _onWebResourceError(WebResourceError error) {
    debugPrint(
      'RampFlutter: resource error '
      'code=${error.errorCode} type=${error.errorType} '
      'desc=${error.description} url=${error.url}',
    );
  }

  void _onHttpError(HttpResponseError error) {
    debugPrint(
      'RampFlutter: HTTP error '
      'status=${error.response?.statusCode} uri=${error.request?.uri}',
    );
  }

  void _configureAndroid(WebViewController controller) {
    final platform = controller.platform;
    if (platform is! AndroidWebViewController) {
      return;
    }
    platform.setMediaPlaybackRequiresUserGesture(false);
    platform.setOnShowFileSelector(showAndroidFileSelector);
  }

  Future<void> postHostEvent(HostEvent event) {
    _ensureController();
    if (_pageReady) {
      return _sendHostEvent(event);
    }
    final done = Completer<void>();
    _pendingHostEvents.add((event: event, done: done));
    return done.future;
  }

  Future<void> _sendHostEvent(HostEvent event) {
    final webView = _controller;
    if (webView == null) {
      return Future.value();
    }
    final message = jsonEncode(event.toJson());
    return webView.runJavaScript('window.postMessage($message, "${_widgetUrl.origin}");');
  }

  Future<void> _flushPendingHostEvents() async {
    if (_pendingHostEvents.isEmpty) {
      return;
    }
    final pending = List.of(_pendingHostEvents);
    _pendingHostEvents.clear();
    for (final item in pending) {
      try {
        await _sendHostEvent(item.event);
        if (!item.done.isCompleted) {
          item.done.complete();
        }
      } catch (error, stackTrace) {
        if (!item.done.isCompleted) {
          item.done.completeError(error, stackTrace);
        }
      }
    }
  }

  void dispose() {
    for (final item in _pendingHostEvents) {
      if (!item.done.isCompleted) {
        item.done.complete();
      }
    }
    _pendingHostEvents.clear();
    _pageReady = false;
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

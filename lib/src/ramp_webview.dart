import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
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
  var _pageReady = false;
  final _pendingHostEvents = <({HostEvent event, Completer<void> done})>[];

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
                debugPrint('RampFlutter: deny WebView permission types=${request.types}');
                request.deny();
              }
            },
          )
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onNavigationRequest: (request) {
                final uri = Uri.tryParse(request.url);
                if (uri == null) {
                  debugPrint('RampFlutter: block navigation — invalid URL ${request.url}');
                  return NavigationDecision.prevent;
                }
                if (_shouldOpenExternally(uri)) {
                  debugPrint('RampFlutter: open external (navigation) ${request.url}');
                  _openExternal(uri);
                  return NavigationDecision.prevent;
                }
                debugPrint('RampFlutter: allow navigation ${request.url}');
                return NavigationDecision.navigate;
              },
              onCreateWindow: (url) {
                debugPrint('RampFlutter: open external (create window) $url');
                final uri = Uri.tryParse(url);
                if (uri == null) {
                  debugPrint('RampFlutter: create window ignored — invalid URL $url');
                  return;
                }
                _openExternal(uri);
              },
              onPageStarted: (url) {
                _pageReady = false;
                debugPrint('RampFlutter: page started $url');
              },
              onPageFinished: (url) {
                debugPrint('RampFlutter: page finished $url');
                _pageReady = true;
                _flushPendingHostEvents();
              },
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
      platform.setOnShowFileSelector(_androidFileSelector);
    }

    controller.loadRequest(_widgetUrl);
    return controller;
  }

  Future<List<String>> _androidFileSelector(FileSelectorParams params) async {
    try {
      if (params.isCaptureEnabled) {
        final photo = await ImagePicker().pickImage(source: ImageSource.camera);
        if (photo == null) {
          return const [];
        }
        return [Uri.file(photo.path).toString()];
      }

      final fileType = _fileTypeForAcceptTypes(params.acceptTypes);
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: params.mode == FileSelectorMode.openMultiple,
        type: fileType,
        allowedExtensions: fileType == FileType.custom ? _extensionsForAcceptTypes(params.acceptTypes) : null,
      );
      if (result == null) {
        return const [];
      }
      return [
        for (final file in result.files)
          if (file.path != null) Uri.file(file.path!).toString(),
      ];
    } catch (error, stackTrace) {
      debugPrint('RampFlutter: file selection failed: $error\n$stackTrace');
      return const [];
    }
  }

  static FileType _fileTypeForAcceptTypes(List<String> acceptTypes) {
    if (acceptTypes.isEmpty) {
      return FileType.any;
    }
    final normalized = acceptTypes.map((type) => type.toLowerCase().trim()).toList();
    final onlyImages = normalized.every((type) => type.startsWith('image/'));
    if (onlyImages) {
      return FileType.image;
    }
    final onlyVideos = normalized.every((type) => type.startsWith('video/'));
    if (onlyVideos) {
      return FileType.video;
    }
    final extensions = _extensionsForAcceptTypes(acceptTypes);
    final allMappedToExtensions = normalized.every(
      (type) => type.startsWith('.') || type == 'application/pdf',
    );
    if (allMappedToExtensions && extensions != null && extensions.isNotEmpty) {
      return FileType.custom;
    }
    return FileType.any;
  }

  static List<String>? _extensionsForAcceptTypes(List<String> acceptTypes) {
    final extensions = <String>{};
    for (final type in acceptTypes) {
      final value = type.trim().toLowerCase();
      if (value.startsWith('.')) {
        extensions.add(value.substring(1));
        continue;
      }
      if (value == 'application/pdf') {
        extensions.add('pdf');
      }
    }
    if (extensions.isEmpty) {
      return null;
    }
    return extensions.toList();
  }

  bool _shouldOpenExternally(Uri uri) {
    final scheme = uri.scheme.toLowerCase();
    final isHttp = scheme == 'http' || scheme == 'https';
    if (!isHttp) {
      return true;
    }
    return uri.host.toLowerCase() != _widgetUrl.host.toLowerCase();
  }

  Future<void> _openExternal(Uri uri) async {
    try {
      if (uri.scheme == 'intent') {
        final fallback = _intentFallbackUrl(uri);
        if (fallback != null) {
          await launchUrl(fallback, mode: LaunchMode.externalApplication);
        } else {
          debugPrint('RampFlutter: intent URL has no browser_fallback_url: $uri');
        }
        return;
      }
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('RampFlutter: cannot launch URL $uri');
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
    _ensureController();
    if (_pageReady) {
      return _sendHostEvent(event);
    }
    debugPrint('RampFlutter: queue postHostEvent ${event.type} until page ready');
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
    debugPrint('RampFlutter: postHostEvent ${event.type}');
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
    } on FormatException catch (error) {
      debugPrint('RampFlutter: drop JS message — invalid JSON: $error');
      return;
    }
    if (decoded is! Map) {
      debugPrint('RampFlutter: drop JS message — expected Map, got ${decoded.runtimeType}');
      return;
    }
    final event = WidgetEvent.tryParse(Map<String, dynamic>.from(decoded));
    if (event == null) {
      return;
    }
    onWidgetEvent?.call(event);
  }
}

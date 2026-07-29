import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

bool shouldOpenExternally(Uri uri, Uri widgetUrl) {
  final scheme = uri.scheme.toLowerCase();
  final isHttp = scheme == 'http' || scheme == 'https';
  if (!isHttp) {
    return true;
  }
  return uri.host.toLowerCase() != widgetUrl.host.toLowerCase();
}

Future<void> openExternalUrl(Uri uri) async {
  try {
    if (uri.scheme == 'intent') {
      final fallback = intentFallbackUrl(uri);
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

@visibleForTesting
Uri? intentFallbackUrl(Uri intentUri) {
  final browserFallback = intentUri.queryParameters['browser_fallback_url'];
  if (browserFallback != null && browserFallback.isNotEmpty) {
    return Uri.tryParse(browserFallback);
  }
  return null;
}

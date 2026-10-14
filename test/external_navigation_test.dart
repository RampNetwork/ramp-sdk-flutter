import 'package:flutter_test/flutter_test.dart';
import 'package:ramp_flutter/src/external_navigation.dart';

void main() {
  final widgetUrl = Uri.parse('https://app.rampnetwork.com/');

  group('shouldOpenExternally', () {
    test('keeps about and empty schemes in the WebView', () {
      expect(shouldOpenExternally(Uri.parse('about:blank'), widgetUrl), isFalse);
      expect(shouldOpenExternally(Uri.parse('/relative'), widgetUrl), isFalse);
    });

    test('keeps same-host https navigations in the WebView', () {
      expect(shouldOpenExternally(Uri.parse('https://app.rampnetwork.com/checkout'), widgetUrl), isFalse);
      expect(shouldOpenExternally(Uri.parse('https://APP.RAMPNETWORK.COM/path'), widgetUrl), isFalse);
    });

    test('opens other https hosts externally unless allowlisted', () {
      expect(shouldOpenExternally(Uri.parse('https://example.com/pay'), widgetUrl), isTrue);
    });

    test('opens non-http schemes externally', () {
      expect(shouldOpenExternally(Uri.parse('mailto:test@example.com'), widgetUrl), isTrue);
      expect(shouldOpenExternally(Uri.parse('ramp://return'), widgetUrl), isTrue);
      expect(shouldOpenExternally(Uri.parse('intent://pay#Intent;scheme=https;end'), widgetUrl), isTrue);
    });
  });

  group('staysInWebView', () {
    test('allows reCAPTCHA hosts', () {
      expect(staysInWebView(Uri.parse('https://www.recaptcha.net/recaptcha')), isTrue);
      expect(staysInWebView(Uri.parse('https://www.google.com/recaptcha/api.js')), isTrue);
      expect(staysInWebView(Uri.parse('https://www.gstatic.com/recaptcha/releases/x')), isTrue);
    });

    test('rejects unrelated google hosts and paths', () {
      expect(staysInWebView(Uri.parse('https://www.google.com/maps')), isFalse);
      expect(staysInWebView(Uri.parse('https://accounts.google.com/')), isFalse);
      expect(staysInWebView(Uri.parse('https://example.com/')), isFalse);
    });
  });

  group('intentFallbackUrl', () {
    test('parses browser_fallback_url query param', () {
      expect(
        intentFallbackUrl(
          Uri.parse('intent://pay/?browser_fallback_url=https%3A%2F%2Fexample.com%2Ffallback#Intent;end'),
        ),
        Uri.parse('https://example.com/fallback'),
      );
    });

    test('returns null when fallback is missing or empty', () {
      expect(intentFallbackUrl(Uri.parse('intent://pay#Intent;scheme=https;end')), isNull);
      expect(intentFallbackUrl(Uri.parse('intent://pay/?browser_fallback_url=#Intent;end')), isNull);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:ramp_flutter/ramp_flutter.dart';
import 'package:ramp_flutter/src/signed_url.dart';

void main() {
  const signedUrl = 'https://app.ramp.network/?hostApiKey=key&timestamp=123&signature=a%2Bb%3D%3D';

  test('preserves the signed URL', () {
    expect(validateRampSignedUrl(signedUrl).toString(), signedUrl);
  });

  test('rejects an incomplete signed URL', () {
    expect(() => validateRampSignedUrl('https://app.ramp.network/?hostApiKey=key&timestamp=123'), throwsArgumentError);
  });

  test('rejects an untrusted origin', () {
    expect(
      () => validateRampSignedUrl(
        'https://app.ramp.network.evil.example/'
        '?hostApiKey=key&timestamp=123&signature=value',
      ),
      throwsArgumentError,
    );
  });

  test('accepts trusted Ramp hosts', () {
    expect(
      validateRampSignedUrl('https://app.dev.ramp-network.org/?hostApiKey=key&timestamp=123&signature=sig').host,
      'app.dev.ramp-network.org',
    );
    expect(
      validateRampSignedUrl('https://app.rampnetwork.com/?hostApiKey=key&timestamp=123&signature=sig').host,
      'app.rampnetwork.com',
    );
  });

  test('signed constructs RampFlutter', () {
    final ramp = RampFlutter.signed(signedUrl);
    expect(ramp, isA<RampFlutter>());
    ramp.dispose();
  });

  test('buildWidgetUrl rejects signed base URLs', () {
    expect(() => Configuration(url: signedUrl).buildWidgetUrl(), throwsStateError);
  });
}

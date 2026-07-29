final _trustedRampHost = RegExp(
  r'^([a-z0-9-]+\.)*(ramp\.network|rampnetwork\.com|ramp-network\.org)$',
);

Uri validateRampSignedUrl(String value) {
  final url = Uri.tryParse(value);
  final parameters = url?.queryParameters ?? const <String, String>{};
  const requiredParameters = ['hostApiKey', 'timestamp', 'signature'];
  if (url == null ||
      url.scheme != 'https' ||
      !_trustedRampHost.hasMatch(url.host) ||
      !requiredParameters.every((parameter) => parameters[parameter]?.isNotEmpty == true)) {
    throw ArgumentError.value(value, 'url', 'Invalid signed Ramp Network URL');
  }
  return url;
}

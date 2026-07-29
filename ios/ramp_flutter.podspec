Pod::Spec.new do |s|
  s.name             = 'ramp_flutter'
  s.version          = '5.0.0'
  s.summary          = 'Ramp Network Flutter SDK.'
  s.description      = <<-DESC
  Ramp Network for Flutter loads the Ramp widget in a Flutter WebView with a
  unified Dart API for iOS and Android.
                       DESC
  s.homepage         = 'https://docs.ramp.network/mobile/flutter-sdk/'
  s.license          = 'MIT'
  s.author           = { 'Ramp Network' => 'dev@ramp.network' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end

Pod::Spec.new do |s|
  s.name             = 'ramp_flutter'
  s.version          = '1.0.1'
  s.summary          = 'Ramp Network iOS wrapper for Flutter.'
  s.description      = <<-DESC
  Ramp Network for Flutter is a simple wrapper for native iOS and Android Ramp Networkn SDKs.
  Unified API lets you write code once and use on any of the platforms.
  Ramp Network Flutter SDK supports iOS and Android platforms.
                       DESC
  s.homepage         = 'https://docs.ramp.network/mobile/flutter-sdk/'
  s.license          = 'MIT'
  s.author           = { 'Ramp Network' => 'dev@ramp.network' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'Ramp'
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end

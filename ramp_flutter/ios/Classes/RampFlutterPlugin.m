#import "RampFlutterPlugin.h"
#if __has_include(<ramp_flutter/ramp_flutter-Swift.h>)
#import <ramp_flutter/ramp_flutter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "ramp_flutter-Swift.h"
#endif

@implementation RampFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftRampFlutterPlugin registerWithRegistrar:registrar];
}
@end

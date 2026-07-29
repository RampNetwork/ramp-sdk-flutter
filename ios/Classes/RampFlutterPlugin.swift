import Flutter
import UIKit

/// No-op plugin registration; widget flow is implemented in Dart via WebView.
public class RampFlutterPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {}
}

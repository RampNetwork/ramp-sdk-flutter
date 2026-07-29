package network.ramp.ramp_flutter

import io.flutter.embedding.engine.plugins.FlutterPlugin

/** No-op plugin registration; widget flow is implemented in Dart via WebView. */
class RampFlutterPlugin : FlutterPlugin {
    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {}

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {}
}

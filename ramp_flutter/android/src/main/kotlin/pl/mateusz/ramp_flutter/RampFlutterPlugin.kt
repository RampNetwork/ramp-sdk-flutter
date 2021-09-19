package pl.mateusz.ramp_flutter

import android.app.Activity
import android.content.Context
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

import network.ramp.sdk.events.model.Purchase
import network.ramp.sdk.facade.Config
import network.ramp.sdk.facade.RampCallback
import network.ramp.sdk.facade.RampSDK

/** RampFlutterPlugin */
class RampFlutterPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  private lateinit var channel : MethodChannel
  private lateinit var context : Context
  private lateinit var activity : Activity
  private lateinit var rampSdk: RampSDK

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "ramp_flutter")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "showRamp") {
      showRamp()
      result.success(null)
    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onDetachedFromActivity() {
    TODO("Not yet implemented")
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    TODO("Not yet implemented")
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity;
  }

  override fun onDetachedFromActivityForConfigChanges() {
    TODO("Not yet implemented")
  }

  private fun showRamp() {
    rampSdk = RampSDK()
    val config = Config(
      hostLogoUrl = "https://example.com/logo.png",
      hostAppName = "My App",
      userAddress = "user_blockchain_address",
      // optional, skip this param to use the production URL
      url = "https://ri-widget-staging.firebaseapp.com/",
      swapAsset = "ETH",
      fiatCurrency = "USD",
      fiatValue = "10",
      userEmailAddress = "test@example.com"
    )
    val callback = object : RampCallback {
      override fun onPurchaseFailed() {
        // ...
      }

      override fun onPurchaseCreated(
        purchase: Purchase,
        purchaseViewToken: String,
        apiUrl: String
      ) {
        // ...
      }

      override fun onWidgetClose() {
        // ...
      }
    }
    rampSdk.startTransaction(activity, config, callback)
  }
}

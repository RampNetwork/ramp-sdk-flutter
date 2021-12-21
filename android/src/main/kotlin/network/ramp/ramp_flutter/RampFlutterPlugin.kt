package network.ramp.ramp_flutter

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
class RampFlutterPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private lateinit var activity: Activity
    private lateinit var rampSdk: RampSDK
    private lateinit var callback: RampCallback

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "ramp_flutter")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
        rampSdk = RampSDK()
        callback = object : RampCallback {
            override fun onPurchaseFailed() {
                channel.invokeMethod("onRampFailed", null)
            }

            override fun onPurchaseCreated(
                purchase: Purchase,
                purchaseViewToken: String,
                apiUrl: String
            ) {
                val purchaseMap = serializePurchase(purchase)
                channel.invokeMethod("onPurchaseCreated", purchaseMap)
            }

            override fun onWidgetClose() {
                channel.invokeMethod("onRampClosed", null)

            }
        }
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        if (call.method == "showRamp") {
            showRamp(call.arguments)
            result.success(null)
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onDetachedFromActivity() {
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

    private fun showRamp(arguments: Any) {
        val config = makeConfiguration(arguments) ?: return
        rampSdk.startTransaction(activity, config, callback)
    }
}

private fun makeConfiguration(arguments: Any): Config? {
    val map = arguments as? Map<*, *> ?: return null
    val hostAppName = map["hostAppName"] as? String ?: "Ramp Integration"
    val hostLogoUrl = map["hostLogoUrl"] as? String ?: "https://ramp.network/assets/images/Logo.svg"
    val url = map["url"] as? String ?: "https://buy.ramp.network"
    val config = Config(hostAppName, hostLogoUrl, url)

    config.swapAsset = map["swapAsset"] as? String ?: ""
    config.swapAmount = map["swapAmount"] as? String ?: ""
    config.fiatCurrency = map["fiatCurrency"] as? String ?: ""
    config.fiatValue = map["fiatValue"] as? String ?: ""
    config.userAddress = map["userAddress"] as? String ?: ""
    config.userEmailAddress = map["userEmailAddress"] as? String ?: ""
    config.selectedCountryCode = map["selectedCountryCode"] as? String ?: ""
    config.defaultAsset = map["defaultAsset"] as? String ?: ""
    config.webhookStatusUrl = map["webhookStatusUrl"] as? String ?: ""
    config.hostApiKey = map["hostApiKey"] as? String ?: ""

    return config
}

private fun serializePurchase(purchase: Purchase): Map<String, Any?> {
    return mapOf(
        "id" to purchase.id,
        "endTime" to purchase.endTime,
        "asset" to mapOf(
            "address" to purchase.asset.address,
            "decimals" to purchase.asset.decimals,
            "name" to purchase.asset.name,
            "symbol" to purchase.asset.symbol,
            "type" to purchase.asset.type,
        ),
        "receiverAddress" to purchase.receiverAddress,
        "cryptoAmount" to purchase.cryptoAmount,
        "fiatCurrency" to purchase.fiatCurrency,
        "fiatValue" to purchase.fiatValue,
        "assetExchangeRate" to purchase.assetExchangeRate,
        "baseRampFee" to purchase.baseRampFee,
        "networkFee" to purchase.networkFee,
        "appliedFee" to purchase.appliedFee,
        "paymentMethodType" to purchase.paymentMethodType,
        "createdAt" to purchase.createdAt,
        "updatedAt" to purchase.updatedAt,
        "status" to purchase.status,
        "escrowAddress" to purchase.escrowAddress,
    )
}
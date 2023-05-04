package network.ramp.ramp_flutter

import android.app.Activity
import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import network.ramp.sdk.events.model.Asset
import network.ramp.sdk.events.model.OfframpSale
import network.ramp.sdk.events.model.Purchase
import network.ramp.sdk.facade.Config
import network.ramp.sdk.facade.Flow
import network.ramp.sdk.facade.RampCallback
import network.ramp.sdk.facade.RampSDK

/** RampFlutterPlugin */
class RampFlutterPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private lateinit var activity: Activity
    private lateinit var rampSdk: RampSDK
    private lateinit var callback: RampCallback

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "ramp_flutter")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext

        rampSdk = RampSDK()
        callback = object : RampCallback {
            override fun onPurchaseFailed() {
            }
            override fun onPurchaseCreated(purchase: Purchase, purchaseViewToken: String, apiUrl: String) {
                val purchaseMap = serializePurchase(purchase)
                val arguments = listOf(purchaseMap, purchaseViewToken, apiUrl)
                channel.invokeMethod("onOnrampPurchaseCreated", arguments)
            }

            override fun offrampSendCrypto(assetInfo: Asset, amount: String, address: String) {
                val assetMap = serializeAsset(assetInfo)
                val arguments = listOf(mapOf("address" to address, "amount" to amount, "assetInfo" to assetMap))
                channel.invokeMethod("onSendCryptoRequested", arguments)
            }

            override fun onOfframpSaleCreated(sale: OfframpSale, saleViewToken: String, apiUrl: String) {
                val saleMap = serializeOfframpSale(sale)
                val arguments = listOf(saleMap, saleViewToken, apiUrl)
                channel.invokeMethod("onOfframpSaleCreated", arguments)
            }

            override fun onWidgetClose() {
                channel.invokeMethod("onRampClosed", null)
            }
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "showRamp" -> {
                showRamp(call.arguments)
                result.success(null)
            }
            "sendCrypto" -> {
                sendCrypto(call.arguments)
                result.success(null)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
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

    private fun sendCrypto(arguments: Any) {
        val txHash = arguments as? String
        rampSdk.onOfframpCryptoSent(txHash)
    }
}

private fun makeConfiguration(arguments: Any): Config? {
    val map = arguments as? Map<*, *> ?: return null
    val hostAppName = map["hostAppName"] as? String ?: "Ramp Integration"
    val hostLogoUrl = map["hostLogoUrl"] as? String ?: "https://ramp.network/assets/images/Logo.svg"
    val url = map["url"] as? String ?: "https://buy.ramp.network"
    val config = Config(hostAppName, hostLogoUrl, url)

    config.defaultAsset = map["defaultAsset"] as? String ?: ""
    val rawDefaultFlow = map["defaultFlow"] as? String ?: ""
    unwrapFlow(rawDefaultFlow)?.let { flow -> config.defaultFlow = flow }

    val rawEnabledFlows = map["enabledFlows"] as? List<String> ?: listOf()
    val enabledFlows = rawEnabledFlows.mapNotNull { unwrapFlow(it) }
    if (enabledFlows.isNotEmpty()) {
        config.enabledFlows = HashSet(enabledFlows)
    }

    config.fiatCurrency = map["fiatCurrency"] as? String ?: ""
    config.fiatValue = map["fiatValue"] as? String ?: ""
    config.hostApiKey = map["hostApiKey"] as? String ?: ""
    config.selectedCountryCode = map["selectedCountryCode"] as? String ?: ""
    config.swapAmount = map["swapAmount"] as? String ?: ""
    config.swapAsset = map["swapAsset"] as? String ?: ""
    config.userAddress = map["userAddress"] as? String ?: ""
    config.userEmailAddress = map["userEmailAddress"] as? String ?: ""
    config.useSendCryptoCallback = map["useSendCryptoCallback"] as? Boolean ?: false
    config.webhookStatusUrl = map["webhookStatusUrl"] as? String ?: ""

    return config
}

private fun unwrapFlow(rawFlow: String): Flow? {
    return when(rawFlow) {
        "ONRAMP" -> Flow.ONRAMP
        "OFFRAMP" -> Flow.OFFRAMP
        else -> null
    }
}

private fun serializePurchase(purchase: Purchase): Map<String, Any?> {
    return mapOf(
        "id" to purchase.id,
        "endTime" to purchase.endTime,
        "asset" to serializeAsset(purchase.asset),
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
    )
}

private fun serializeAsset(asset: Asset): Map<String, Any?> {
    return mapOf(
        "address" to asset.address,
        "decimals" to asset.decimals,
        "name" to asset.name,
        "symbol" to asset.symbol,
        "type" to asset.type,
    )
}

private fun serializeOfframpSale(offrampSale: OfframpSale): Map<String, Any?> {
    return mapOf(
        "id" to offrampSale.id,
        "createdAt" to offrampSale.createdAt,
        "crypto" to mapOf(
                "amount" to offrampSale.crypto.amount,
                "assetInfo" to serializeAsset(offrampSale.crypto.assetInfo),
            ),
        "fiat" to mapOf(
            "amount" to offrampSale.fiat.amount,
            "currencySymbol" to offrampSale.fiat.currencySymbol,
        )
    )
}

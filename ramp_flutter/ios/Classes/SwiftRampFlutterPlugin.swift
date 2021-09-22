import Flutter
import UIKit
import Ramp

public class SwiftRampFlutterPlugin: NSObject {
    let channel: FlutterMethodChannel
    
    init(channel: FlutterMethodChannel) {
        self.channel = channel
    }
    
    private func showRamp(arguments: Any?) throws {
        guard let delegate = UIApplication.shared.delegate,
              let window = delegate.window,
              let flutterViewController = window?.rootViewController as? FlutterViewController
        else { throw NSError()  }
        guard let configurationArguments = arguments as? [String: Any],
              let configuration = Configuration(flutterMethodCallArguments: configurationArguments)
        else { throw NSError() }
        let rampViewController = try RampViewController.init(configuration: configuration)
        rampViewController.delegate = self
        flutterViewController.present(rampViewController, animated: true)
    }
}

extension SwiftRampFlutterPlugin: FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "ramp_flutter", binaryMessenger: registrar.messenger())
        let instance = SwiftRampFlutterPlugin(channel: channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "showRamp":
            guard let viewController = UIApplication.shared.keyWindow?.rootViewController
            else { result(FlutterError()) ; return }
            guard let configuration = Configuration(flutterMethodCallArguments: call.arguments)
            else { result(FlutterError()) ; return }
            let ramp: RampViewController
            do { ramp = try RampViewController(configuration: configuration) }
            catch { result(FlutterError()) ; return }
            ramp.delegate = self
            viewController.present(ramp, animated: true)
            result(nil)
        default:
            result(FlutterError())
        }
    }
}

extension SwiftRampFlutterPlugin: RampDelegate {
    public func ramp(_ rampViewController: RampViewController, didCreatePurchase purchase: RampPurchase) {
        channel.invokeMethod("onPurchaseCreated", arguments: purchase.toDictionary())
    }
    
    public func rampPurchaseDidFail(_ rampViewController: RampViewController) {
        channel.invokeMethod("onRampFailed", arguments: nil)
    }
    
    public func rampDidClose(_ rampViewController: RampViewController) {
        channel.invokeMethod("onRampClosed", arguments: nil)
    }
}

private extension Configuration {
    init?(flutterMethodCallArguments arguments: Any?) {
        guard let arguments = arguments as? [String: Any] else { return nil }
        self.init()
        self.swapAsset = arguments["swapAsset"] as? String
        self.swapAmount = arguments["swapAmount"] as? String
        self.fiatCurrency = arguments["fiatCurrency"] as? String
        self.fiatValue = arguments["fiatValue"] as? String
        self.userAddress = arguments["userAddress"] as? String
        self.hostLogoUrl = arguments["hostLogoUrl"] as? String
        self.hostAppName = arguments["hostAppName"] as? String
        self.userEmailAddress = arguments["userEmailAddress"] as? String
        self.selectedCountryCode = arguments["selectedCountryCode"] as? String
        self.defaultAsset = arguments["defaultAsset"] as? String
        self.url = arguments["url"] as? String
        self.webhookStatusUrl = arguments["webhookStatusUrl"] as? String
        self.finalUrl = arguments["finalUrl"] as? String
        self.containerNode = arguments["containerNode"] as? String
        self.hostApiKey = arguments["hostApiKey"] as? String
        self.deepLinkScheme = arguments["deepLinkScheme"] as? String
    }
}

private extension RampPurchase {
    func toDictionary() -> [String: Any?] {
        return [
            "id": id,
            "endTime": endTime,
            "asset": [
                "address": asset.address,
                "decimals": asset.decimals,
                "name": asset.name,
                "symbol": asset.symbol,
                "type": asset.type,
            ] as [String: Any?],
            "receiverAddress": receiverAddress,
            "cryptoAmount": cryptoAmount,
            "fiatCurrency": fiatCurrency,
            "fiatValue": fiatValue,
            "assetExchangeRate": assetExchangeRate,
            "baseRampFee": baseRampFee,
            "networkFee": networkFee,
            "appliedFee": appliedFee,
            "paymentMethodType": paymentMethodType,
            "finalTxHash": finalTxHash,
            "createdAt": createdAt,
            "updatedAt": updatedAt,
            "status": status,
            "escrowAddress": escrowAddress,
            "escrowDetailsHash": escrowDetailsHash,
        ]
    }
}

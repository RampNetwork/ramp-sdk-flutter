import Flutter
import UIKit
import Ramp

public class SwiftRampFlutterPlugin: NSObject {
    private let channel: FlutterMethodChannel
    private var sendCryptoResponseHandler: ((SendCryptoResultPayload) -> Void)?
    
    init(channel: FlutterMethodChannel) {
        self.channel = channel
    }
    
    private func showRamp(arguments: Any?) throws {
        guard let delegate = UIApplication.shared.delegate,
              let window = delegate.window,
              let flutterViewController = window?.rootViewController as? FlutterViewController
        else {
            throw RampFlutterError.flutterViewControllerUnavailable
        }
        
        guard let configurationArguments = arguments as? [String: Any],
              let configuration = try? Configuration.from(configurationArguments)
        else {
            throw RampFlutterError.unableToDecodeConfiguration
        }
        
        let rampViewController = try RampViewController(configuration: configuration)
        rampViewController.delegate = self
        flutterViewController.present(rampViewController, animated: true)
    }
    
    private func sendCrypto(arguments: Any?) throws {
        fatalError()
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
            do {
                try showRamp(arguments: call.arguments)
                result(nil)
            }
            catch {
                result(error.flutterError)
            }
            
        case "sendCrypto":
            do {
                try sendCrypto(arguments: call.arguments)
                result(nil)
            }
            catch {
                result(error.flutterError)
            }
            
        default:
            let error = RampFlutterError.unknownCallMethod
            result(error.flutterError)
        }
    }
}

extension SwiftRampFlutterPlugin: RampDelegate {
    public func ramp(_ rampViewController: RampViewController,
                     didCreateOnrampPurchase purchase: OnrampPurchase,
                     _ purchaseViewToken: String,
                     _ apiUrl: URL) {
        guard let purchase = try? purchase.toDictionary() else { return }
        let apiUrl = apiUrl.absoluteString
        channel.invokeMethod("onOnrampPurchaseCreated",
                             arguments: [purchase, purchaseViewToken, apiUrl])

    }
    
    public func ramp(_ rampViewController: RampViewController,
                     didRequestSendCrypto payload: SendCryptoPayload,
                     responseHandler: @escaping (SendCryptoResultPayload) -> Void) {
        guard let payload = try? payload.toDictionary() else { return }
        self.sendCryptoResponseHandler = responseHandler
        channel.invokeMethod("onSendCryptoRequested",
                             arguments: [payload])
    }
    
    public func ramp(_ rampViewController: RampViewController,
                     didCreateOfframpSale sale: OfframpSale,
                     _ saleViewToken: String,
                     _ apiUrl: URL) {
        guard let sale = try? sale.toDictionary() else { return }
        let url = apiUrl.absoluteString
        channel.invokeMethod("onOfframpSaleCreated",
                             arguments: [sale, saleViewToken, url])
    }
    
    public func rampDidClose(_ rampViewController: RampViewController) {
        channel.invokeMethod("onRampClosed", arguments: nil)
    }
}

private extension Configuration {
    static func from(_ dictionary: [String: Any]) throws -> Configuration {
        let data = try JSONSerialization.data(withJSONObject: dictionary)
        let configuration = try JSONDecoder().decode(Configuration.self, from: data)
        return configuration
    }
}

private extension OnrampPurchase {
    func toDictionary() throws -> Any {
        let data = try JSONEncoder().encode(self)
        let dictionary = try JSONSerialization.jsonObject(with: data)
        return dictionary
    }
}

private extension OfframpSale {
    func toDictionary() throws -> Any {
        let data = try JSONEncoder().encode(self)
        let dictionary = try JSONSerialization.jsonObject(with: data)
        return dictionary
    }
}

private extension SendCryptoPayload {
    func toDictionary() throws -> Any {
        let data = try JSONEncoder().encode(self)
        let dictionary = try JSONSerialization.jsonObject(with: data)
        return dictionary
    }
}

private enum RampFlutterError: Error {
    case flutterViewControllerUnavailable
    case unableToDecodeConfiguration
    case unknownCallMethod
}

private extension Error {
    var flutterError: FlutterError {
        switch self as? RampFlutterError {
        case .flutterViewControllerUnavailable:
            return FlutterError(code: "flutterViewControllerUnavailable",
                                message: "FlutterViewController unavailable",
                                details: nil)
        case .unableToDecodeConfiguration:
            return FlutterError(code: "unableToDecodeConfiguration",
                                message: "Unable to decode Configuration",
                                details: nil)
        case .unknownCallMethod:
            return FlutterError(code: "unknownCallMethod",
                                message: "Unknown call method",
                                details: nil)
        case .none:
            let nsError = self as NSError
            return FlutterError(code: String(nsError.code),
                                message: nsError.description,
                                details: nsError.userInfo)
        }
    }
}

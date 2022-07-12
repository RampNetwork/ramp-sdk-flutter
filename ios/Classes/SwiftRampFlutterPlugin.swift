import Flutter
import UIKit
import Ramp

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
        else { throw RampFlutterError.flutterViewControllerUnavailable  }
        guard let configurationArguments = arguments as? [String: Any],
              let configuration = try? Configuration.from(configurationArguments)
        else { throw RampFlutterError.unableToDecodeConfiguration }
        let rampViewController = try RampViewController.init(configuration: configuration)
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
    public func rampWidgetConfigDone(_ rampViewController: RampViewController) {
        channel.invokeMethod("onWidgetConfigDone", arguments: nil)
    }
    
    public func ramp(_ rampViewController: RampViewController, didCreatePurchase purchase: Purchase, _ purchaseViewToken: String, _ apiUrl: URL) {
        guard let purchase = try? purchase.toDictionary() else { return }
        let url = apiUrl.absoluteString;
        channel.invokeMethod("onPurchaseCreated",
                             arguments: [purchase, purchaseViewToken, url])
    }
    
    public func ramp(_ rampViewController: RampViewController, didRequestOfframp payload: SendCryptoPayload, responseHandler: @escaping (SendCryptoResultPayload) -> Void) {
        self.sendCryptoResponseHandler = responseHandler
        channel.invokeMethod("onOfframpRequested", arguments: nil)
    }
    
    public func ramp(_ rampViewController: RampViewController, didCreateOfframpPurchase purchase: OfframpPurchase, _ purchaseViewToken: String, _ apiUrl: URL) {
       guard let purchase = try? purchase.toDictionary() else { return }
       let url = apiUrl.absoluteString;
       channel.invokeMethod("onOfframpPurchaseCreated",
                            arguments: [purchase, purchaseViewToken, url])
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

private extension Purchase {
    func toDictionary() throws -> Any {
        let data = try JSONEncoder().encode(self)
        let dictionary = try JSONSerialization.jsonObject(with: data)
        return dictionary
    }
}

private extension OfframpPurchase {
    func toDictionary() throws -> Any {
        let data = try JSONEncoder().encode(self)
        let dictionary = try JSONSerialization.jsonObject(with: data)
        return dictionary
    }
}

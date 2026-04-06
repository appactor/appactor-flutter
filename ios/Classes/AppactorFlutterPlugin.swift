import Flutter
import AppActorPlugin

public class AppActorFlutterPlugin: NSObject, FlutterPlugin {
    private static var channel: FlutterMethodChannel?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "appactor_flutter", binaryMessenger: registrar.messenger())
        let instance = AppActorFlutterPlugin()
        Self.channel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
        AppActorPlugin.shared.delegate = instance
        MainActor.assumeIsolated {
            AppActorPlugin.shared.startEventListening()
        }
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard call.method == "execute",
              let args = call.arguments as? [String: Any],
              let method = args["method"] as? String else {
            result(FlutterMethodNotImplemented)
            return
        }
        let json = args["json"] as? String ?? "{}"
        AppActorPlugin.shared.execute(method: method, withJsonString: json) { response in
            DispatchQueue.main.async {
                result(response)
            }
        }
    }

    public static func detachFromEngine(for registrar: FlutterPluginRegistrar) {
        MainActor.assumeIsolated {
            AppActorPlugin.shared.stopEventListening()
        }
        AppActorPlugin.shared.delegate = nil
        Self.channel = nil
    }
}

extension AppActorFlutterPlugin: AppActorPluginDelegate {
    public func appActorPlugin(
        _ plugin: AppActorPlugin,
        didReceiveEvent eventName: String,
        withJson jsonString: String
    ) {
        DispatchQueue.main.async {
            Self.channel?.invokeMethod("event", arguments: ["name": eventName, "json": jsonString])
        }
    }
}

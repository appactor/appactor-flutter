import Flutter
import AppActorPlugin

public class AppActorFlutterPlugin: NSObject, FlutterPlugin {
    // The native SDK has one delegate per process, but an app can run several engines:
    // flutter_local_notifications starts a background one for notification actions, which
    // registers every plugin again. Each event goes to every attached engine, so a second
    // engine can't take the events away from the app's own. Only touched on the main thread.
    private static var attached: [AppActorFlutterPlugin] = []
    // The SDK holds its delegate weakly.
    private static let eventRelay = EventRelay()

    private let channel: FlutterMethodChannel

    private init(channel: FlutterMethodChannel) {
        self.channel = channel
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "appactor_flutter", binaryMessenger: registrar.messenger())
        let instance = AppActorFlutterPlugin(channel: channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
        // The engine calls detachFromEngine(for:) only on published objects.
        registrar.publish(instance)
        attached.append(instance)
        if attached.count == 1 {
            AppActorPlugin.shared.delegate = eventRelay
            MainActor.assumeIsolated {
                AppActorPlugin.shared.startEventListening()
            }
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

    public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
        Self.attached.removeAll { $0 === self }
        guard Self.attached.isEmpty else { return }
        MainActor.assumeIsolated {
            AppActorPlugin.shared.stopEventListening()
        }
        AppActorPlugin.shared.delegate = nil
    }

    private final class EventRelay: NSObject, AppActorPluginDelegate {
        func appActorPlugin(
            _ plugin: AppActorPlugin,
            didReceiveEvent eventName: String,
            withJson jsonString: String
        ) {
            DispatchQueue.main.async {
                for plugin in AppActorFlutterPlugin.attached {
                    plugin.channel.invokeMethod("event", arguments: ["name": eventName, "json": jsonString])
                }
            }
        }
    }
}

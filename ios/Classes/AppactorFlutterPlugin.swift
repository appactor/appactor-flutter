import Flutter
import AppActorPlugin

public class AppActorFlutterPlugin: NSObject, FlutterPlugin {
    // The SDK has one delegate per process; flutter_local_notifications' background actions
    // start a second engine that registers this plugin again. Main thread only.
    private static var engines: [AppActorFlutterPlugin] = []
    // The SDK holds its delegate weakly.
    private static let eventRelay = EventRelay()

    private var channel: FlutterMethodChannel?

    // An engine that never uses AppActor gets no events: they would pile up in its channel
    // buffer, and a message to an engine that isn't running yet asserts.
    private var receivesEvents = false

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "appactor_flutter", binaryMessenger: registrar.messenger())
        let instance = AppActorFlutterPlugin()
        instance.channel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
        // The engine calls detachFromEngine(for:) only on published objects.
        registrar.publish(instance)
        engines.append(instance)
        if engines.count == 1 {
            AppActorPlugin.shared.delegate = eventRelay
            MainActor.assumeIsolated {
                AppActorPlugin.shared.startEventListening()
            }
        }
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "listen":
            receivesEvents = true
            result(nil)
        case "execute":
            guard let args = call.arguments as? [String: Any],
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
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
        // The engine calls this from its dealloc, on whichever thread drops the last reference.
        guard Thread.isMainThread else {
            DispatchQueue.main.async { self.detach() }
            return
        }
        detach()
    }

    private func detach() {
        Self.engines.removeAll { $0 === self }
        guard Self.engines.isEmpty else { return }
        MainActor.assumeIsolated {
            AppActorPlugin.shared.stopEventListening()
        }
        AppActorPlugin.shared.delegate = nil
    }

    private static func deliver(_ name: String, _ json: String) {
        let event = ["name": name, "json": json]
        for engine in engines where engine.receivesEvents {
            engine.channel?.invokeMethod("event", arguments: event)
        }
    }

    private final class EventRelay: NSObject, AppActorPluginDelegate {
        func appActorPlugin(
            _ plugin: AppActorPlugin,
            didReceiveEvent eventName: String,
            withJson jsonString: String
        ) {
            DispatchQueue.main.async {
                AppActorFlutterPlugin.deliver(eventName, jsonString)
            }
        }
    }
}

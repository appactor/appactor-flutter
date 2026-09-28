package com.appactor.appactor_flutter

import android.os.Handler
import android.os.Looper
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import com.appactor.plugin.AppActorPlugin
import com.appactor.plugin.events.PluginEventListener

class AppActorFlutterPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {
    private var channel: MethodChannel? = null

    // Set when the engine's Dart side registers its handler ("listen"). An engine that
    // never uses AppActor (firebase_messaging's background isolate, say) gets no events:
    // they would only pile up in its channel buffer, and log a warning for each one in
    // debug builds.
    private var receivesEvents = false

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        val channel = MethodChannel(binding.binaryMessenger, "appactor_flutter")
        channel.setMethodCallHandler(this)
        this.channel = channel
        AppActorPlugin.setContext(binding.applicationContext)
        engines.add(this)
        if (engines.size == 1) {
            AppActorPlugin.eventListener = eventListener
            AppActorPlugin.startEventListening()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        channel = null
        engines.remove(this)
        if (engines.isEmpty()) {
            AppActorPlugin.stopEventListening()
            AppActorPlugin.eventListener = null
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "listen" -> {
                receivesEvents = true
                result.success(null)
            }
            "execute" -> {
                val method = call.argument<String>("method")
                    ?: return result.error("MISSING_METHOD", "method argument is required", null)
                val json = call.argument<String>("json") ?: "{}"
                AppActorPlugin.execute(method, json) { response ->
                    mainHandler.post { result.success(response) }
                }
            }
            else -> result.notImplemented()
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        AppActorPlugin.setActivity(binding.activity)
    }

    override fun onDetachedFromActivity() {
        AppActorPlugin.setActivity(null)
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        AppActorPlugin.setActivity(binding.activity)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        AppActorPlugin.setActivity(null)
    }

    companion object {
        private val mainHandler by lazy { Handler(Looper.getMainLooper()) }

        // The native SDK has one event listener per process, but an app can run several
        // engines: firebase_messaging's background handler starts a second one, which
        // registers every plugin again. Each event goes to every engine that uses AppActor,
        // so a second engine can't take the events away from the app's own. Only touched
        // on the main thread: engines attach and detach there, and events are posted to it.
        private val engines = mutableListOf<AppActorFlutterPlugin>()

        private val eventListener = PluginEventListener { name: String, json: String ->
            mainHandler.post { deliver(name, json) }
        }

        internal fun deliver(name: String, json: String) {
            val event = mapOf<String, Any>("name" to name, "json" to json)
            engines.forEach { engine ->
                if (engine.receivesEvents) engine.channel?.invokeMethod("event", event)
            }
        }
    }
}

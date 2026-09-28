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

    // An engine that never uses AppActor (firebase_messaging's background isolate) gets no
    // events: they would pile up in its channel buffer and log a warning each in debug.
    private var receivesEvents = false

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "appactor_flutter").also {
            it.setMethodCallHandler(this)
        }
        AppActorPlugin.setContext(binding.applicationContext)
        engines.add(this)
        if (engines.size == 1) {
            AppActorPlugin.eventListener = eventListener
            AppActorPlugin.startEventListening()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
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

        // The SDK has one event listener per process; firebase_messaging's background
        // handler starts a second engine that registers this plugin again. Main thread only.
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

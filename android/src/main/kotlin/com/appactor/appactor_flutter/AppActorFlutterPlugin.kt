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

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        val channel = MethodChannel(binding.binaryMessenger, "appactor_flutter")
        channel.setMethodCallHandler(this)
        this.channel = channel
        AppActorPlugin.setContext(binding.applicationContext)
        channels.add(channel)
        if (channels.size == 1) {
            AppActorPlugin.eventListener = eventListener
            AppActorPlugin.startEventListening()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.let {
            it.setMethodCallHandler(null)
            channels.remove(it)
        }
        channel = null
        if (channels.isEmpty()) {
            AppActorPlugin.stopEventListening()
            AppActorPlugin.eventListener = null
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
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

    private companion object {
        private val mainHandler by lazy { Handler(Looper.getMainLooper()) }

        // The native SDK has one event listener per process, but an app can run several
        // engines: firebase_messaging's background handler starts a second one, which
        // registers every plugin again. Each event goes to every attached engine, so a
        // second engine can't take the events away from the app's own. Only touched on
        // the main thread: engines attach and detach there, and events are posted to it.
        private val channels = mutableListOf<MethodChannel>()

        private val eventListener = PluginEventListener { name: String, json: String ->
            mainHandler.post {
                val event = mapOf<String, Any>("name" to name, "json" to json)
                channels.forEach { it.invokeMethod("event", event) }
            }
        }
    }
}

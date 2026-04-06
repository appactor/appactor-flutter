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
    private lateinit var channel: MethodChannel
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "appactor_flutter")
        channel.setMethodCallHandler(this)
        AppActorPlugin.setContext(binding.applicationContext)
        AppActorPlugin.eventListener = PluginEventListener { name: String, json: String ->
            mainHandler.post {
                channel.invokeMethod("event", mapOf<String, Any>("name" to name, "json" to json))
            }
        }
        AppActorPlugin.startEventListening()
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        AppActorPlugin.stopEventListening()
        AppActorPlugin.eventListener = null
        channel.setMethodCallHandler(null)
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
}

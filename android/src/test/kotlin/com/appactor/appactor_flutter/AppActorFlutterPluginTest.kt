package com.appactor.appactor_flutter

import android.content.Context
import com.appactor.plugin.AppActorPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.StandardTestDispatcher
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.setMain
import org.mockito.Mockito
import kotlin.test.AfterTest
import kotlin.test.BeforeTest
import kotlin.test.Test
import kotlin.test.assertNotNull
import kotlin.test.assertNull

@OptIn(ExperimentalCoroutinesApi::class)
internal class AppActorFlutterPluginTest {
    private val mainDispatcher = StandardTestDispatcher()

    @BeforeTest
    fun setUp() {
        Dispatchers.setMain(mainDispatcher)
    }

    @AfterTest
    fun tearDown() {
        Dispatchers.resetMain()
    }

    @Test
    fun secondEngine_detaching_keepsEventsForTheFirst() {
        val app = AppActorFlutterPlugin()
        val background = AppActorFlutterPlugin()
        val appBinding = pluginBinding()
        val backgroundBinding = pluginBinding()

        app.onAttachedToEngine(appBinding)
        background.onAttachedToEngine(backgroundBinding)
        background.onDetachedFromEngine(backgroundBinding)
        assertNotNull(AppActorPlugin.eventListener)

        app.onDetachedFromEngine(appBinding)
        assertNull(AppActorPlugin.eventListener)
    }

    private fun pluginBinding(): FlutterPlugin.FlutterPluginBinding {
        val binding = Mockito.mock(FlutterPlugin.FlutterPluginBinding::class.java)
        Mockito.`when`(binding.binaryMessenger).thenReturn(Mockito.mock(BinaryMessenger::class.java))
        Mockito.`when`(binding.applicationContext).thenReturn(Mockito.mock(Context::class.java))
        return binding
    }

    @Test
    fun onMethodCall_execute_delegatesToPlugin() {
        val plugin = AppActorFlutterPlugin()
        val mockResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)

        val call = MethodCall("execute", mapOf(
            "method" to "get_sdk_version",
            "json" to "{}"
        ))
        plugin.onMethodCall(call, mockResult)

        // Plugin is not attached to engine so AppActorPlugin.execute won't resolve,
        // but the method call should not return notImplemented.
        Mockito.verify(mockResult, Mockito.never()).notImplemented()
    }

    @Test
    fun onMethodCall_unknownMethod_returnsNotImplemented() {
        val plugin = AppActorFlutterPlugin()
        val mockResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)

        val call = MethodCall("getPlatformVersion", null)
        plugin.onMethodCall(call, mockResult)

        Mockito.verify(mockResult).notImplemented()
    }

    @Test
    fun onMethodCall_execute_missingMethod_returnsError() {
        val plugin = AppActorFlutterPlugin()
        val mockResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)

        val call = MethodCall("execute", mapOf("json" to "{}"))
        plugin.onMethodCall(call, mockResult)

        Mockito.verify(mockResult).error(
            Mockito.eq("MISSING_METHOD"),
            Mockito.anyString(),
            Mockito.isNull()
        )
    }
}

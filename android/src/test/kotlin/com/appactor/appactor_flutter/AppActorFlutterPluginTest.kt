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
import kotlin.test.assertEquals
import kotlin.test.assertNotNull
import kotlin.test.assertNull

@OptIn(ExperimentalCoroutinesApi::class)
internal class AppActorFlutterPluginTest {
    private val mainDispatcher = StandardTestDispatcher()

    private val attached = mutableListOf<AppActorFlutterPlugin>()

    @BeforeTest
    fun setUp() {
        Dispatchers.setMain(mainDispatcher)
    }

    @AfterTest
    fun tearDown() {
        attached.toList().forEach(::detach)
        Dispatchers.resetMain()
    }

    private fun attach(
        messenger: BinaryMessenger = Mockito.mock(BinaryMessenger::class.java),
    ): AppActorFlutterPlugin {
        val binding = Mockito.mock(FlutterPlugin.FlutterPluginBinding::class.java)
        Mockito.`when`(binding.binaryMessenger).thenReturn(messenger)
        Mockito.`when`(binding.applicationContext).thenReturn(Mockito.mock(Context::class.java))
        return AppActorFlutterPlugin().also {
            it.onAttachedToEngine(binding)
            attached += it
        }
    }

    private fun detach(plugin: AppActorFlutterPlugin) {
        attached.remove(plugin)
        plugin.onDetachedFromEngine(Mockito.mock(FlutterPlugin.FlutterPluginBinding::class.java))
    }

    private fun listen(plugin: AppActorFlutterPlugin) {
        plugin.onMethodCall(MethodCall("listen", null), Mockito.mock(MethodChannel.Result::class.java))
    }

    private fun BinaryMessenger.eventsSent(): Int = Mockito.mockingDetails(this).invocations
        .count { it.method.name == "send" && it.arguments[0] == "appactor_flutter" }

    @Test
    fun events_reachEveryEngineThatListens_andOnlyThose() {
        val appMessenger = Mockito.mock(BinaryMessenger::class.java)
        val secondMessenger = Mockito.mock(BinaryMessenger::class.java)
        val idleMessenger = Mockito.mock(BinaryMessenger::class.java)
        listen(attach(appMessenger))
        listen(attach(secondMessenger))
        attach(idleMessenger)

        AppActorFlutterPlugin.deliver("customer_info_updated", "{}")

        assertEquals(1, appMessenger.eventsSent())
        assertEquals(1, secondMessenger.eventsSent())
        assertEquals(0, idleMessenger.eventsSent())
    }

    @Test
    fun secondEngine_detaching_keepsEventsForTheFirst() {
        val appMessenger = Mockito.mock(BinaryMessenger::class.java)
        val app = attach(appMessenger)
        val second = attach()
        listen(app)

        detach(second)
        assertNotNull(AppActorPlugin.eventListener)
        AppActorFlutterPlugin.deliver("customer_info_updated", "{}")
        assertEquals(1, appMessenger.eventsSent())

        detach(app)
        assertNull(AppActorPlugin.eventListener)
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

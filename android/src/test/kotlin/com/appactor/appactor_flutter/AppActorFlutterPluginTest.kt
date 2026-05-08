package com.appactor.appactor_flutter

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

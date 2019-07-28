package nl.littlerobots.flutter.native_state

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

class FlutterNativeStatePlugin() : MethodCallHandler {
    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "nl.littlerobots.flutter/native_state")
            channel.setMethodCallHandler(FlutterNativeStatePlugin())

        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when {
            call.method == "getState" -> {
                val state = StateRegistry.getState()
                result.success(state)
            }
            call.method == "setState" -> {
                val state: Map<String, Any?>? = call.argument("state")
                StateRegistry.setState(state)
                result.success(StateRegistry.getState())
            }
            else -> result.notImplemented()
        }
    }
}


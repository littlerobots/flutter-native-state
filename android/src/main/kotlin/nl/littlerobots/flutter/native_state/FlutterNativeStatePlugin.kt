package nl.littlerobots.flutter.native_state

import android.os.Bundle
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class FlutterNativeStatePlugin : MethodCallHandler, FlutterPlugin, ActivityAware, ActivityPluginBinding.OnSaveInstanceStateListener {
    private var channel: MethodChannel? = null
    private var activityPluginBinding: ActivityPluginBinding? = null
        set(value) {
            field?.removeOnSaveStateListener(this)
            field = value
            value?.addOnSaveStateListener(this)
        }

    override fun onMethodCall(call: MethodCall, result: Result) {
        val activity = activityPluginBinding?.activity
                ?: throw IllegalStateException("Not attached to activity")

        when (call.method) {
            "getState" -> {
                val state = StateRegistry.getState(activity)
                result.success(state)
            }
            "setState" -> {
                val state: Map<String, Any?>? = call.argument("state")
                StateRegistry.setState(activity, state)
                result.success(StateRegistry.getState(activity))
            }
            else -> result.notImplemented()
        }
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "nl.littlerobots.flutter/native_state").also {
            it.setMethodCallHandler(this)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        channel = null
    }

    override fun onDetachedFromActivity() {
        activityPluginBinding?.activity?.let {
            StateRegistry.clear(it)
        }
        activityPluginBinding = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activityPluginBinding = binding
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityPluginBinding = binding
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activityPluginBinding = null
    }

    override fun onRestoreInstanceState(bundle: Bundle?) {
        StateRegistry.onRestoreInstanceState(activityPluginBinding!!.activity, bundle)
    }

    override fun onSaveInstanceState(bundle: Bundle) {
        StateRegistry.onSaveInstanceState(activityPluginBinding!!.activity, bundle)
    }
}


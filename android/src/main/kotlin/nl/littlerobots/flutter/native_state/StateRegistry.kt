package nl.littlerobots.flutter.native_state

import android.app.Activity
import android.app.Application
import android.os.Bundle

/**
 * Holder for state that will be saved to a bundle when [Activity.onSaveInstanceState] is called.
 */
object StateRegistry {
    private val state = mutableMapOf<String, Any?>()

    fun onSaveInstanceState(outState: Bundle) {
        outState.putBundle("flutter_state", state.toBundle())
    }

    fun onRestoreInstanceState(savedInstanceState: Bundle?) {
        state.clear()
        val flutterState = savedInstanceState?.getBundle("flutter_state")
        flutterState?.let { state.putAll(it.toMap()) }
    }

    fun setState(stateMap: Map<String, Any?>?) {
        stateMap?.let { validateStateMap(it) }
        state.clear()
        stateMap?.let { state.putAll(stateMap) }
    }

    private fun validateStateMap(stateMap: Map<String, Any?>) {
        if (!stateMap.all { entry ->
                    valueAllowed(entry.value)
                }) {
            throw IllegalArgumentException("Values must be null, Boolean, Int, Long, Double, String or Map")
        }
    }

    private fun valueAllowed(value: Any?): Boolean {
        return when (value) {
            null,
            is Boolean,
            is Int,
            is Long,
            is Double,
            is String -> true
            is Map<*, *> -> {
                validateStateMap(value as Map<String, Any?>)
                true
            }
            else -> false
        }
    }

    fun getState(): Map<String, Any?> {
        return state
    }

    fun registerCallbacks(application: Application) {
        application.registerActivityLifecycleCallbacks(LifecycleCallbacks())
    }
}

private class LifecycleCallbacks : Application.ActivityLifecycleCallbacks {
    override fun onActivityPaused(activity: Activity?) {
    }

    override fun onActivityResumed(activity: Activity?) {
    }

    override fun onActivityStarted(activity: Activity?) {
    }

    override fun onActivityDestroyed(activity: Activity?) {
    }

    override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) {
        StateRegistry.onSaveInstanceState(outState)
    }

    override fun onActivityStopped(activity: Activity?) {
    }

    override fun onActivityCreated(activity: Activity?, savedInstanceState: Bundle?) {
        StateRegistry.onRestoreInstanceState(savedInstanceState)
    }
}

private fun Bundle.toMap(): Map<String, Any?> {
    val result = mutableMapOf<String, Any?>()
    for (key in keySet()) {
        when (val value = get(key)) {
            null,
            is Boolean,
            is Int,
            is Long,
            is Double,
            is String -> result[key] = value
            is Bundle -> result[key] = value.toMap()
        }
    }
    return result
}

@Suppress("UNCHECKED_CAST")
private fun Map<String, Any?>.toBundle(): Bundle {
    val bundle = Bundle()
    for (entry in entries) {
        when (val value = entry.value) {
            null -> bundle.putString(entry.key, null)
            is Boolean -> bundle.putBoolean(entry.key, value)
            is Int -> bundle.putInt(entry.key, value)
            is Long -> bundle.putLong(entry.key, value)
            is Double -> bundle.putDouble(entry.key, value)
            is String -> bundle.putString(entry.key, value)
            is Map<*, *> -> bundle.putBundle(entry.key, (value as Map<String, Any?>).toBundle())
            else -> throw IllegalArgumentException("Cannot convert ${value::class.java} to bundle value")
        }
    }
    return bundle
}
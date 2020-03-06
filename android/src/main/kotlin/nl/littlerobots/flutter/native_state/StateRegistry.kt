package nl.littlerobots.flutter.native_state

import android.app.Activity
import android.os.Bundle

/**
 * Holder for state that will be saved to a bundle when [Activity.onSaveInstanceState] is called.
 */
object StateRegistry {
    private val activityState = mutableMapOf<String, MutableMap<String, Any?>>()

    fun onSaveInstanceState(activity: Activity, outState: Bundle) {
        val state = activityState[activity.javaClass.name]
        state?.let {
            outState.putBundle("flutter_state", it.toBundle())
        }
    }

    fun onRestoreInstanceState(activity: Activity, savedInstanceState: Bundle?) {
        val state = activityState.getOrPut(activity.javaClass.name) { mutableMapOf() }
        val flutterState = savedInstanceState?.getBundle("flutter_state")
        flutterState?.let { state.putAll(it.toMap()) }
    }

    fun setState(activity: Activity, stateMap: Map<String, Any?>?) {
        val state = activityState.getOrPut(activity.javaClass.name) { mutableMapOf() }
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
                @Suppress("UNCHECKED_CAST")
                validateStateMap(value as Map<String, Any?>)
                true
            }
            else -> false
        }
    }

    fun clear(activity: Activity) {
        activityState.remove(activity.javaClass.name)
    }

    fun getState(activity: Activity): Map<String, Any?> {
        return activityState[activity.javaClass.name] ?: emptyMap()
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
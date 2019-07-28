package nl.littlerobots.flutter.native_state

import io.flutter.app.FlutterApplication

class FlutterNativeStateApplication : FlutterApplication() {
    override fun onCreate() {
        StateRegistry.registerCallbacks(this)
        super.onCreate()
    }
}
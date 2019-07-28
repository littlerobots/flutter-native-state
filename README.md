# Flutter `native_state` plugin

This plugin allows for restoring state after the app process is killed while in the background.

## What this plugin is for
Since mobile devices are resource constrained, both Android and iOS use a trick to make it look like apps like always running in
the background: whenever the app is killed in the background, an app has an opportunity to save a small amount of data 
that can be used to restore the app to a state, so that it _looks_ like the app was never killed.

For example, consider a sign up form that a user is filling in. When the user is filling in this form, and a phone call comes in,
the OS may decide that there's not enough resources to keep the app running and will kill the app. By default, Flutter does not 
restore any state when relaunching the app after that phone call, which means that whatever the user has entered has now been lost. 
Worse yet, the app will just restart and show the home screen which can be confusing to the user as well.

## Saving state using `native_state`
First of all: the term "state" may be confusing, since it can mean many things. In this case _state_ means: the *bare minimum* 
amount of data you need to make it appear that the app was never killed. Generally this means that you should only persist things like
data being entered by the user, or an id that identifies whatever was displayed on the screen. For example, if your app is showing 
a shopping cart, only the shopping cart id should be persisted using this plugin, the shopping cart contents related to this id 
should be loaded by other means (from disk, or from the network).

### Integrating `native_state` for Flutter projects on Android
This plugin uses Kotlin, make sure your Flutter project has Kotlin configured for that reason.

Find the `AndroidManifest.xml` file in `app/src/main` of your Flutter project. Then *remove* the `name` attribute from the 
`<application>` tag:

>  <application ~~android:name="io.flutter.app.FlutterApplication"~~ ...>

When not removed, you'll get a compilation error similar like this:

> Attribute application@name value=(io.flutter.app.FlutterApplication) from AndroidManifest.xml:10:9-57
>  	is also present at [:native_state] AndroidManifest.xml:7:18-99 value=(nl.littlerobots.flutter.native_state.FlutterNativeStateApplication).
>  	Suggestion: add 'tools:replace="android:name"' to <application> element at AndroidManifest.xml:9:5-32:19 to override.

### Integrating `native_state` for Flutter project on iOS
This plugin uses Swift, make sure your project is configured to use Swift for that reason.

Your `AppDelegate.swift` in the `ios/Runner` directory should look like this:

```import UIKit
   import Flutter
   // add this line
   import native_state
   
   @UIApplicationMain
   @objc class AppDelegate: FlutterAppDelegate {
     override func application(
       _ application: UIApplication,
       didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
     ) -> Bool {
       GeneratedPluginRegistrant.register(with: self)
       return super.application(application, didFinishLaunchingWithOptions: launchOptions)
     }

     // add these methods       
     override func application(_ application: UIApplication, didDecodeRestorableStateWith coder: NSCoder) {
         StateStorage.instance.restore(coder: coder)
     }

     override func application(_ application: UIApplication, willEncodeRestorableStateWith coder: NSCoder) {
         StateStorage.instance.save(coder: coder)
     }
   
     override func application(_ application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
         return true
     }
   
     override func application(_ application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
         return true
     }
   }
```

## Using `native_state`
The `SavedStateData` class allows for storing data by key and value. To get access to `SavedStateData` wrap your 
main application in a `SavedState` widget; this is the global application `SavedState` widget. To retrieve the `SavedStateData` 
use `SavedState.of(BuildContext)` or use the `SavedState.builder()` to get the data in a builder.

`SavedState` widgets manage the saved state. When they are disposed, the associated state is also cleared. Usually you want to 
wrap each page in your application that needs to restore some state in a `SavedState` widget. When the page is no longer displayed, the
`SavedState` associated with the page is automatically cleared.

## Saving and Restoring state in `StatefulWidgets`
Most of the time, you'd want your `StatefulWidget`s to update the `SavedState`. Use `SavedState.of(context)` then call `state.putXXX(key, value)` to
update the state.

To restore state in your `StatefulWidget` add the `SavedStateHandler` mixin to your `State` class. Then implement the `restoreState(SavedState)` 
method this will be called once when your widget is mounted.

## Restoring navigation state
Restoring the page state is one part of the equation, but when the app is restarted, by default it will start with the default route, 
which is probably not what you want. The plugin provides the `SavedStateNavigationObserver` that will save the route to the 
`SavedState` automatically. The saved route can then be retrieved using `restoreRoute(SavedState)` static method. *Important note:* for
this to work you need to setup your routes in such a way that the `Navigator` will restore then when you [set the `initialRoute` property](https://api.flutter.dev/flutter/widgets/Navigator/initialRoute.html).

## FAQ
### Why do I need this at all? My apps never get killed in the background
Lucky you! Your phone must have infinite memory :)

### Why not save _all_ state to a file
Two reasons: you are wasting resources (disk and battery) when saving all app state, using `native_state` is more efficient as it only saves the bare 
minimum amount of data and only when the OS requests it. State is kept in memory so there are no disk writes at all.

Secondly, even though the app state might have saved, the OS might 
choose not to restore it. For example, when the user has killed your app from the task switcher, or after some amount of time when 
it doesn't really make sense any more to restore the app state. This is up to the discretion of the OS, and it is good practice 
to respect that, in stead of _always_ restoring the app state.

### How do I test this is working?
For both Android and iOS: start your app and send it to the background by pressing the home button or using a gesture. Then 
from XCode or Android Studio, kill the app process and restart the app from the launcher. The app should resume from the same 
state as when it was killed.

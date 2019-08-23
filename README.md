# Flutter native_state plugin

This plugin allows for restoring state after the app process is killed while in the background.

## What this plugin is for
Since mobile devices are resource constrained, both Android and iOS use a trick to make it look like apps like always running in
the background: whenever the app is killed in the background, an app has an opportunity to save a small amount of data 
that can be used to restore the app to a state, so that it _looks_ like the app was never killed.

For example, consider a sign up form that a user is filling in. When the user is filling in this form, and a phone call comes in,
the OS may decide that there's not enough resources to keep the app running and will kill the app. By default, Flutter does not 
restore any state when relaunching the app after that phone call, which means that whatever the user has entered has now been lost. 
Worse yet, the app will just restart and show the home screen which can be confusing to the user as well.

## Saving state
First of all: the term "state" may be confusing, since it can mean many things. In this case _state_ means: the *bare minimum* 
amount of data you need to make it appear that the app was never killed. Generally this means that you should only persist things like
data being entered by the user, or an id that identifies whatever was displayed on the screen. For example, if your app is showing 
a shopping cart, only the shopping cart id should be persisted using this plugin, the shopping cart contents related to this id 
should be loaded by other means (from disk, or from the network).

### Integrating with Flutter projects on Android
This plugin uses Kotlin, make sure your Flutter project has Kotlin configured for that reason.

Find the `AndroidManifest.xml` file in `app/src/main` of your Flutter project. Then *remove* the `name` attribute from the 
`<application>` tag:

>  <application ~~android:name="io.flutter.app.FlutterApplication"~~ ...>

When not removed, you'll get a compilation error similar like this:

> Attribute application@name value=(io.flutter.app.FlutterApplication) from AndroidManifest.xml:10:9-57
>  	is also present at [:native_state] AndroidManifest.xml:7:18-99 value=(nl.littlerobots.flutter.native_state.FlutterNativeStateApplication).
>  	Suggestion: add 'tools:replace="android:name"' to <application> element at AndroidManifest.xml:9:5-32:19 to override.

If you prefer to use your own application class, add the `tools:replace="android:name"` attribute to `AndroidManifest.xml` as suggested in the error message, 
and call `StateRegistry.registerCallbacks()` from your `Application` class.

### Integrating with Flutter project on iOS
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

## Using the plugin
The `SavedStateData` class allows for storing data by key and value. To get access to `SavedStateData` wrap your 
main application in a `SavedState` widget; this is the global application `SavedState` widget. To retrieve the `SavedStateData` 
use `SavedState.of(BuildContext)` or use the `SavedState.builder()` to get the data in a builder.

`SavedState` widgets manage the saved state. When they are disposed, the associated state is also cleared. Usually you want to 
wrap each page in your application that needs to restore some state in a `SavedState` widget. When the page is no longer displayed, the
`SavedState` associated with the page is automatically cleared. `SavedState` widgets can be nested multiple times, creating nested 
`SavedStateData` that will be cleared when a parent of the `SavedStateData` is cleared, for example, when the `SavedState` widget is removed
from the widget tree.

## Saving and Restoring state in `StatefulWidgets`
Most of the time, you'd want your `StatefulWidget`s to update the `SavedState`. Use `SavedState.of(context)` then call `state.putXXX(key, value)` to
update the state.

To restore state in your `StatefulWidget` add the `StateRestoration` mixin to your `State` class. Then implement the `restoreState(SavedState)` 
method. This method will be called once when your widget is mounted.

## Restoring navigation state
Restoring the page state is one part of the equation, but when the app is restarted, by default it will start with the default route, 
which is probably not what you want. The plugin provides the `SavedStateRouteObserver` that will save the route to the 
`SavedState` automatically. The saved route can then be retrieved using `restoreRoute(SavedState)` static method. *Important note:* for
this to work you need to setup your routes in such a way that the `Navigator` will restore them when you [set the `initialRoute` property](https://api.flutter.dev/flutter/widgets/Navigator/initialRoute.html).

Another requirement is that you set a `navigatorKey` on the `MaterialApp`. This is because the tree is rebuilt after the `SavedState` is initialised. When
rebuilding, the Flutter needs to reuse the existing `Navigator` that receives the `initialRoute`.  

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

### When is state cleared by the OS
For Android: when the user "exits" the app by pressing back, and at the discretion of the OS when the app is in the background.

For iOS: users cannot really "exit" an app on iOS, but state is cleared when the user swipes away the app in the app switcher.

## License
```Copyright 2019 Little Robots

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
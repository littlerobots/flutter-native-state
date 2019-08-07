# Example

Demonstrates how to use the native_state plugin.

`main.dart` shows an example where the main app is a child of a `SavedState` widget and each 
route that needs to be able to restore state is a child of another `SavedState`. The home page 
stores the state of the counter in the "root" `SavedState`. The active route is also stored, using
a `SavedStateRouteObserver`.

`single_screen.dart` shows an example where only a part of an application will use `SavedStateData` 
to retain it's state, this is a less common scenario vs having a `SavedState` widget that is the parent 
of the whole application, but could be useful in some cases.

`self_managed.dart` shows an example where a flow of multiple screens share the same `SavedStateData` instance.
In this case the state is cleared by the widgets when either going back from the first page in the flow, or when 
the flow completes. Navigational state is also restored in this example.

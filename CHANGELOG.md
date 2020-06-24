# next
* Define iOS module to ensure static & framework builds work

# 1.1.1
* Fixes a potential null pointer exception in `SavedStateRouteObserver`

## 1.1.0
* Switches to the new Android plugin API and requires Flutter 1.12 and up, removes the requirement for additional
setup for Android. Make sure you [migrate your project](https://flutter.dev/go/android-project-migration) 
before using this version.
* State is now recorded per activity on Android to better support embedding.

## 1.0.2
* Use `dependOnInheritedWidgetOfExactType` in stead of the deprecated `inheritFromWidgetOfExactType`

## 1.0.1
* Added `SavedStateData.remove()` to remove values by key

## 1.0.0
* No changes from rc01

## 1.0.0-rc01
* Added `SavedState.value` for passing down `SavedStateData` without automatically clearing it.
* Added new sample for `SavedState.value`

## 0.0.2
* Removed non-essential public methods from `SavedStateData`
* Added an explicit `name` parameter to `SavedState` and removed getting the name from the key if supplied.
* Added dart doc

## 0.0.1

* Initial version


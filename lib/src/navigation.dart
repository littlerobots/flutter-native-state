import 'package:flutter/widgets.dart';
import 'package:native_state/native_state.dart';

class SavedStateRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  final SavedStateData savedState;

  SavedStateRouteObserver({@required this.savedState})
      : assert(savedState != null);

  @override
  void didPop(Route route, Route previousRoute) {
    savedState.putString("_current_route", previousRoute?.settings?.name);
  }

  @override
  void didPush(Route route, Route previousRoute) {
    if(route?.isCurrent == true){
      savedState.putString("_current_route", route?.settings?.name);
    }
  }

  @override
  void didRemove(Route route, Route previousRoute) {
    if(previousRoute?.isCurrent == true){
      savedState.putString("_current_route", previousRoute?.settings?.name);
    }
  }

  /// Returns the saved route name or null
  static String restoreRoute(SavedStateData savedState) {
    return savedState.getString("_current_route");
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_state/native_state.dart';

void main() {
  final List<MethodCall> methodChannelCalls = <MethodCall>[];
  Map<dynamic, dynamic> savedState = {};

  setUpAll(() {
    WidgetsFlutterBinding.ensureInitialized();
    savedState.clear();
    MethodChannel('nl.littlerobots.flutter/native_state').setMockMethodCallHandler((MethodCall methodCall) async {
      methodChannelCalls.add(methodCall);
      switch (methodCall.method) {
        case 'getState':
          return savedState;
        case 'setState':
          savedState = methodCall.arguments['state'];
          return savedState;
      }
      return null;
    });
  });

  tearDown(() {
    savedState.clear();
    methodChannelCalls.clear();
  });

  group("SavedStateRouteObserver saves current route", () {
    test('didPop saves route correctly', () async {
      var state = await SavedStateData.restore();
      var observer = SavedStateRouteObserver(savedState: state);

      observer.didPop(_MockRoute("old"), null);
      expect(SavedStateRouteObserver.restoreRoute(state), null);

      observer.didPop(_MockRoute("old"), _MockRoute("new"));
      expect(SavedStateRouteObserver.restoreRoute(state), "new");
    });

    test('didPush saves route correctly', () async {
      var state = await SavedStateData.restore();
      var observer = SavedStateRouteObserver(savedState: state);

      observer.didPush(null, _MockRoute("old"));
      expect(SavedStateRouteObserver.restoreRoute(state), null);

      observer.didPush(_MockRoute("new"), _MockRoute("old"), );
      expect(SavedStateRouteObserver.restoreRoute(state), "new");
    });

    test('didRemove saves route correctly', () async {
      var state = await SavedStateData.restore();
      var observer = SavedStateRouteObserver(savedState: state);

      observer.didRemove(_MockRoute("old"), null);
      expect(SavedStateRouteObserver.restoreRoute(state), null);

      observer.didRemove(_MockRoute("old"), _MockRoute("new"));
      expect(SavedStateRouteObserver.restoreRoute(state), "new");
    });

    test('didReplace saves route correctly', () async {
      var state = await SavedStateData.restore();
      var observer = SavedStateRouteObserver(savedState: state);

      observer.didReplace(oldRoute: _MockRoute("old"), newRoute: null);
      expect(SavedStateRouteObserver.restoreRoute(state), null);

      observer.didReplace(oldRoute: _MockRoute("old"), newRoute: _MockRoute("new"));
      expect(SavedStateRouteObserver.restoreRoute(state), "new");
    });
  });
}

class _MockRoute extends PageRoute {
  _MockRoute(String name) : super(settings: RouteSettings(name: name));

  @override
  Color get barrierColor => throw UnimplementedError();

  @override
  String get barrierLabel => throw UnimplementedError();

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {}

  @override
  bool get maintainState => throw UnimplementedError();

  @override
  Duration get transitionDuration => throw UnimplementedError();
}

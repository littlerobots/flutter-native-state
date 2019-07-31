import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_state/native_state.dart';

void main() {
  final List<MethodCall> methodChannelCalls = <MethodCall>[];
  Map<dynamic, dynamic> savedState = {};

  setUpAll(() {
    savedState.clear();
    MethodChannel('nl.littlerobots.flutter/native_state')
        .setMockMethodCallHandler((MethodCall methodCall) async {
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

  test('should load the state data', () async {
    savedState['vtest'] = 'test-value';
    var state = await SavedStateData.restore();
    expect(methodChannelCalls, [isMethodCall('getState', arguments: null)]);
    expect(state.getString('test'), equals('test-value'));
  });

  test('should save state data when updated', () async {
    var state = await SavedStateData.restore();
    methodChannelCalls.clear();

    state.putString('testkey', 'testvalue');
    expect(state.getString('testkey'), equals('testvalue'));
    expect(methodChannelCalls, [
      isMethodCall('setState', arguments: {
        'state': {'vtestkey': 'testvalue'}
      })
    ]);
  });

  group('nested state', () {
    test('should write parent state when updated', () async {
      var state = await SavedStateData.restore();
      methodChannelCalls.clear();

      var child = state.child('sub-state');

      child.putString('testkey', 'testvalue');

      expect(methodChannelCalls, [
        isMethodCall('setState', arguments: {
          'state': {
            'ssub-state': {'vtestkey': 'testvalue'}
          }
        })
      ]);
    });

    test('should restore nested state', () async {
      savedState = {
        'ssub-state': {'vtestkey': 'testvalue'}
      };

      var state = await SavedStateData.restore();
      var child = state.child('sub-state');

      expect(child.getString('testkey'), equals('testvalue'));
    });

    test('value keys should not clash with child keys', () async {
      var state = (await SavedStateData.restore())
        ..putString('sub-state', 'myvalue');
      var child = state.child('sub-state')..putString('testkey', 'somevalue');

      expect(state.getString('sub-state'), equals('myvalue'));
      expect(child.getString('testkey'), equals('somevalue'));

      await child.clear();
      expect(state.getString('sub-state'), equals('myvalue'));
      expect(child.getString('testkey'), isNull);

      expect(methodChannelCalls, [
        isMethodCall('getState', arguments: null),
        isMethodCall('setState', arguments: {
          'state': {'vsub-state': 'myvalue'}
        }),
        isMethodCall('setState', arguments: {
          'state': {
            'vsub-state': 'myvalue',
            'ssub-state': {'vtestkey': 'somevalue'}
          }
        }),
        isMethodCall('setState', arguments: {
          'state': {'vsub-state': 'myvalue'}
        })
      ]);
    });

    test('parent state clears child state', () async {
      var state = await SavedStateData.restore();
      var nested = state.child('nested');
      var nestedNested = nested.child('n2');

      nestedNested.putInt("test", 1);
      nested.clear();

      expect(nestedNested.getInt('test'), isNull);

      nestedNested.putInt("test", 1);
      nested.putBool("nested-test", true);

      state.clear();

      expect(nested.getBool("nested-test"), isNull);
      expect(nestedNested.getInt("test"), isNull);
    });
  });
}

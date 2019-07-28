import 'package:flutter/cupertino.dart';
import 'package:native_state/src/platform.dart';

class SavedStateData {
  final Map<dynamic, dynamic> _data;
  final String _scope;
  var _initialised = false;

  Map<dynamic, dynamic> get _scopedData =>
      _scope == "" ? _data : (_data[_scope]);

  bool get initialised => _initialised;

  SavedStateData._()
      : this._data = {},
        this._scope = "";

  SavedStateData._withScope(this._data, this._scope, this._initialised);

  SavedStateData.initial()
      : this._data = {},
        this._scope = "",
        this._initialised = false;

  bool get isEmpty => _data.isEmpty;

  SavedStateData child(String name) {
    assert(name != null);
    var key = "$_scope.s$name";
    _data[key] = _data[key] ?? Map<dynamic, dynamic>();
    return SavedStateData._withScope(_data, "$_scope.s$name", _initialised);
  }

  dynamic _getValue(String key) {
    return _scopedData[key];
  }

  Future<void> _putValue(String key, dynamic value) {
    if (!_initialised) {
      // when not loaded, writing is a noop
      return Future.value(null);
    }
    var valueKey = key;
    if (value == null) {
      _scopedData.remove(valueKey);
    } else {
      _scopedData[valueKey] = value;
    }
    return _write();
  }

  String getString(String key) {
    return _getValue(key) as String;
  }

  Future<void> putString(String key, String value) async {
    return _putValue(key, value);
  }

  int getInt(String key) {
    return _getValue(key) as int;
  }

  Future<void> putInt(String key, int value) async {
    return _putValue(key, value);
  }

  double getDouble(String key) {
    return _getValue(key) as double;
  }

  Future<void> putDouble(String key, double value) async {
    return _putValue(key, value);
  }

  bool getBool(String key) {
    return (_getValue(key) as bool) ?? false;
  }

  Future<void> putBool(String key, bool value) async {
    return _putValue(key, value);
  }

  void activate() {
    _initialised = true;
  }

  Future<void> clear() {
    if (_scope == "") {
      _data.clear();
    } else {
      _data.remove(_scope);
    }
    return _write();
  }

  Future<void> _write() async {
    return FlutterNativeState.set(_data);
  }

  Future<SavedStateData> _load() async {
    var data = await FlutterNativeState.get();
    debugPrint("Restore from OS: $data");
    _data.addAll(data);
    _initialised = true;
    return this;
  }

  static Future<SavedStateData> restore() async {
    var data = SavedStateData._();
    await data._load();
    return data;
  }
}

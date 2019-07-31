part of native_state;

class SavedStateData {
  final Map<dynamic, dynamic> _data;
  final String _parentKey;
  final SavedStateData _parent;

  var _rootRestored = false;

  bool get _restored => _parent?._restored ?? _rootRestored;

  SavedStateData._withParent(this._parent, this._data, this._parentKey)
      : this._rootRestored = null;

  SavedStateData._()
      : this._data = {},
        this._parentKey = null,
        this._rootRestored = false,
        this._parent = null;

  /// Create an empty [SavedStateData] as a child. The child state will be cleared
  /// when [clear] is called on the parent, which is the main purpose for this.
  /// A child [SavedStateData] does not inherit any of the parent values and cannot access them.
  SavedStateData child(String name) {
    assert(name != null);

    var key = "s$name";
    return SavedStateData._withParent(
        this, _data[key] ?? Map<dynamic, dynamic>(), key);
  }

  dynamic _getValue(String key, {String prefix = "v"}) {
    return _data["$prefix$key"];
  }

  Future<void> _putValue(String key, dynamic value, {String prefix = "v"}) {
    if (!_restored) {
      // when not loaded, writing is a noop
      return Future.value(null);
    }
    var valueKey = "$prefix$key";
    if (value == null) {
      _data.remove(valueKey);
    } else {
      _data[valueKey] = value;
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
    return (_getValue(key) as bool);
  }

  Future<void> putBool(String key, bool value) async {
    return _putValue(key, value);
  }

  /// Clear all data. [SavedStateData]s can be nested when created using [child]. Calling [clear] on
  /// any parent, will clear all children data.
  Future<void> clear() {
    _collectChildren(_data).forEach((child) => child.clear());
    _data.clear();
    return _write();
  }

  List<Map<dynamic, dynamic>> _collectChildren(Map<dynamic, dynamic> map) {
    List<Map<dynamic, dynamic>> children = map.values.where((v) =>
    v is Map<
        dynamic,
        dynamic>).toList().cast();
    List<Map<dynamic, dynamic>> nested = [];
    children.forEach((child) {
      nested.addAll(_collectChildren(child));
    });
    return children..addAll(nested);
  }

  Future<void> _write() async {
    if (_parent == null) {
      return _FlutterNativeState.set(_data);
    } else {
      if (_data.isEmpty) {
        return _parent._putValue(_parentKey, null, prefix: "");
      } else {
        return _parent._putValue(_parentKey, _data, prefix: "");
      }
    }
  }

  Future<SavedStateData> _load() async {
    assert(_parent == null);

    var data = await _FlutterNativeState.get();
    _data.addAll(data);
    _rootRestored = true;
    return this;
  }

  /// Restore and return a [SavedStateData]
  /// It's usually more convenient to use a [SavedState] widget to
  /// get access to the [SavedStateData]
  static Future<SavedStateData> restore() async {
    var data = SavedStateData._();
    await data._load();
    return data;
  }
}

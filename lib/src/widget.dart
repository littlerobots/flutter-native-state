import 'package:flutter/widgets.dart';
import 'package:native_state/src/data.dart';

typedef WidgetStateBuilder = Widget Function(
    BuildContext context, SavedStateData savedState);

class SavedState extends StatelessWidget {
  final Widget child;

  String get _name =>
      key is ValueKey<String> ? (key as ValueKey<String>).value : null;

  SavedState({Key key, @required this.child}) : super(key: key);

  SavedState.builder({Key key, @required WidgetStateBuilder builder})
      : child = LayoutBuilder(
          builder: (context, _) => builder(context, SavedState.of(context)),
        ),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    var parent = _InheritedSavedState.of(context);
    // we are the root and need to load the state before exposing it.
    if (parent == null) {
      return _RootSavedState(
        child: child,
      );
    } else {
      // scope the state using the name if a key is supplied, or by the route name otherwise
      var name = _name ?? ModalRoute.of(context).settings.name;
      assert(name != null);

      return _SavedStateDisposer(
        child: child,
        savedState: parent.child(name),
      );
    }
  }

  static SavedStateData of(BuildContext context) {
    return _InheritedSavedState.of(context);
  }
}

/// Constructs and loads the saved state
class _RootSavedState extends StatelessWidget {
  final Widget child;

  _RootSavedState({@required this.child}) : super(key: ValueKey("root"));

  @override
  Widget build(BuildContext context) {
    var initial = SavedStateData.initial();
    return FutureBuilder(
      future: SavedStateData.restore(),
      initialData: initial,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          SavedStateData result = snapshot.data;
          if (result.isEmpty) {
            // return the initial empty state, this prevents a rebuild
            initial.activate();
            return _SavedStateDisposer(child: child, savedState: initial);
          }
        }
        return _SavedStateDisposer(child: child, savedState: snapshot.data);
      },
    );
  }
}

mixin StateRestoration<T extends StatefulWidget> on State<T> {
  bool _didRestoreState = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    var state = SavedState.of(context);

    assert(state != null);

    if (state.initialised && !_didRestoreState) {
      restoreState(state);
      _didRestoreState = true;
    }
  }

  /// Will be called once to restore the state. This method will always be
  /// called after the state restoration has completed, even if there's no
  /// previously saved state.
  void restoreState(SavedStateData savedState);
}

/// holds and clears the state when disposed
class _SavedStateDisposer extends StatefulWidget {
  final Widget child;
  final SavedStateData savedState;

  _SavedStateDisposer(
      {Key key, @required this.child, @required this.savedState})
      : super(key: key);

  @override
  _SavedStateDisposerState createState() => _SavedStateDisposerState();
}

class _SavedStateDisposerState extends State<_SavedStateDisposer> {
  @override
  Widget build(BuildContext context) {
    return _InheritedSavedState(
        child: widget.child, savedState: widget.savedState);
  }

  @override
  void dispose() {
    widget.savedState.clear();
    super.dispose();
  }
}

class _InheritedSavedState extends InheritedWidget {
  final Widget child;
  final SavedStateData savedState;

  _InheritedSavedState({this.child, this.savedState});

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    var widget = oldWidget as _InheritedSavedState;
    // Only notify when the state has been initialised (restored)
    var shouldNotify = !widget.savedState.initialised && savedState.initialised;
    debugPrint("Should notify = $shouldNotify");
    return shouldNotify;
  }

  static SavedStateData of(BuildContext context) {
    _InheritedSavedState widget =
        context.inheritFromWidgetOfExactType(_InheritedSavedState);
    return widget?.savedState;
  }
}

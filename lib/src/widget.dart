part of native_state;

typedef WidgetStateBuilder = Widget Function(
    BuildContext context, SavedStateData savedState);

/// Provides the [SavedStateData] to the widget tree.
///
/// When the widget is removed from the tree, the associated [SavedStateData]
/// will be cleared using it's `clear()` method.
///
/// [SavedState] widgets can be nested each widget that is not the root creates a
/// named nested [SavedStateData] using [SavedStateData.child].
/// By the default, the name associated with the child will be the current route name.
/// A name can also be supplied by setting the [name] property.
///
class SavedState extends StatelessWidget {
  final Widget child;
  final String name;

  SavedState({Key key, this.name, @required this.child}) : super(key: key);

  SavedState.builder({Key key, this.name, @required WidgetStateBuilder builder})
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
      var name = this.name ?? ModalRoute
          .of(context)
          .settings
          .name;
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
    return FutureBuilder(
      future: SavedStateData.restore(),
      initialData: SavedStateData._(),
      builder: (context, snapshot) {
        return _SavedStateDisposer(child: child, savedState: snapshot.data);
      },
    );
  }
}

/// Mixin that supplies [SavedStateData] to a [StatefulWidget]s [State] class.
/// The widget tree must contain a [SavedState] widget that is a parent of the [StatefulWidget]
/// to locate the [SavedStateData].
mixin StateRestoration<T extends StatefulWidget> on State<T> {
  bool _didRestoreState = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    var state = SavedState.of(context);

    assert(state != null);

    if (state._restored && !_didRestoreState) {
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
    // Only notify when the state has been restored
    return !widget.savedState._restored && savedState._restored;
  }

  static SavedStateData of(BuildContext context) {
    _InheritedSavedState widget =
        context.inheritFromWidgetOfExactType(_InheritedSavedState);
    return widget?.savedState;
  }
}

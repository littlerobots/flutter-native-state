import 'package:flutter/material.dart';
import 'package:native_state/native_state.dart';

/// Demo to show that you can apply [SavedState] to a single widget.
/// In the more common case, you'd want to wrap [MaterialApp] in [SavedState] too
/// so that navigation can also be restored.
void main() => runApp(MaterialApp(
      routes: {
        AnotherCounter.route: (context) => SavedState(child: AnotherCounter())
      },
      home: HomePage(),
    ));

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Column(
        children: <Widget>[
          RaisedButton(
            child: Text("Navigate"),
            onPressed: () {
              Navigator.of(context).pushNamed(AnotherCounter.route);
            },
          ),
        ],
      ),
    );
  }
}

class AnotherCounter extends StatefulWidget {
  static final route = "/counter";

  @override
  _AnotherCounterState createState() => _AnotherCounterState();
}

class _AnotherCounterState extends State<AnotherCounter> with StateRestoration {
  int _count = 0;

  void _increment() {
    setState(() {
      _count++;
      SavedState.of(context).putInt("counter", _count);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Make it count"),
      ),
      body: Column(
        children: <Widget>[
          Text("The count is $_count"),
          SizedBox(
            height: 16,
          ),
          RaisedButton(
            child: Text("Increment"),
            onPressed: () => _increment(),
          )
        ],
      ),
    );
  }

  @override
  void restoreState(SavedStateData savedState) {
    debugPrint("restoreState");
    setState(() {
      _count = savedState.getInt("counter") ?? 0;
    });
  }
}

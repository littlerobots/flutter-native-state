import 'package:flutter/material.dart';
import 'package:native_state/native_state.dart';

void main() => runApp(SavedState(child: MyApp()));

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var registrationState = SavedState.of(context).child('registration');
    debugPrint(
        'Initial route: ${SavedStateRouteObserver.restoreRoute(SavedState.of(context))}');
    return MaterialApp(
      // Note that you need a navigator key set for the state restoration to work!
      // The "old" navigator needs to be used when the tree rebuilds.
      navigatorKey: GlobalKey(),
      navigatorObservers: [
        SavedStateRouteObserver(savedState: SavedState.of(context))
      ],
      routes: {
        // Wrap in a SavedState.value to make sure SavedState.of() returns the correct
        // state. The StateRestoration mixin also uses this.
        '/registration': (context) => SavedState.value(
            savedState: registrationState,
            // manually clear the state when we back out of the first step
            child: WillPopScope(
              onWillPop: () async {
                registrationState.clear();
                return true;
              },
              child: RegistrationStep(
                  hint: 'Your name',
                  stateKey: 'name',
                  nextRoute: '/registration/step2'),
            )),
        '/registration/step2': (context) => SavedState.value(
            savedState: registrationState,
            child: RegistrationStep(
                hint: 'Your favorite food',
                stateKey: 'food',
                nextRoute: '/registration/step2/final')),
        // We can pass in the state directly here, since we don't use StateRestoration
        '/registration/step2/final': (context) => Summary(
              state: registrationState,
            )
      },
      initialRoute:
          SavedStateRouteObserver.restoreRoute(SavedState.of(context)) ?? '/',
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  const Home({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: RaisedButton(
          child: Text('START'),
          onPressed: () => Navigator.of(context).pushNamed('/registration'),
        ),
      ),
    );
  }
}

class Summary extends StatelessWidget {
  final SavedStateData state;

  Summary({@required this.state});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('The last step!'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Text('Name: ${state.getString('name')}'),
            Text('Food: ${state.getString('food')}'),
            SizedBox(
              height: 16,
            ),
            RaisedButton(
              child: Text('SIGN ME UP'),
              onPressed: () {
                // insert your registration code here

                // Since we're done, clear the state
                state.clear();
                // Navigate back home (or anywhere you want)
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            )
          ],
        ),
      ),
    );
  }
}

class RegistrationStep extends StatefulWidget {
  final String hint;
  final String stateKey;
  final String nextRoute;

  RegistrationStep(
      {@required this.hint, @required this.stateKey, @required this.nextRoute});

  @override
  _RegistrationStepState createState() => _RegistrationStepState();
}

class _RegistrationStepState extends State<RegistrationStep>
    with StateRestoration {
  TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(() {
      // Save state as the user types
      SavedState.of(context).putString(widget.stateKey, _controller.text);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registration step ${widget.stateKey}'),
      ),
      body: Center(
          child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: widget.hint,
              ),
              controller: _controller,
            ),
          ),
          SizedBox(
            height: 16,
          ),
          RaisedButton(
            child: Text("NEXT"),
            onPressed: () {
              Navigator.of(context).pushNamed(widget.nextRoute);
            },
          )
        ],
      )),
    );
  }

  @override
  void restoreState(SavedStateData savedState) {
    // restore previous value and init with a default value
    _controller.text = savedState.getString(widget.stateKey) ?? "";
  }
}

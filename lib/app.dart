import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_reframe_sample_app/counter/counter_event.dart';
import 'package:flutter_reframe_sample_app/counter/counter_state.dart';
import 'package:flutter_reframe_sample_app/reframe/event.dart';
import 'package:flutter_reframe_sample_app/reframe/state.dart';
import 'package:redux/redux.dart';

class App extends StatelessWidget {
  final Store<AppState> store;

  const App(this.store);

  /* App serves as our 'root' widget, which we wrap in `StoreProvider`
  and whose child widget we re-render via `StoreBuilder`.

  For simplicity's sake in a small app like this, we're using `StoreBuilder`
     high up in the widget tree, rather than e.g. `StoreConnector` lower down.*/
  @override
  Widget build(BuildContext context) => StoreProvider<AppState>(
      store: store,
      child: new MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: StoreBuilder<AppState>(
            builder: (_, store) =>
                Counter(state: store.state.counter, dispatch: store.dispatch),
          )));
}

class Counter extends StatelessWidget {
  final void Function(Event) dispatch;
  final CounterState state;

  const Counter({
    @required this.dispatch,
    @required this.state,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => new Scaffold(
        appBar: AppBar(
          title: Text("Flutter Reframe Sample App"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'You have pushed the button this many times:',
              ),
              Text(
                '${state.count}',
                style: Theme.of(context).textTheme.headline4,
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // An action without a payload:
            dispatch(IncrementEvent());

            // An action with a payload:
//          dispatch(SetCountEvent(3));

            // An async action (sends request):
//          dispatch(AsyncSetCountEvent());
          },
          tooltip: 'Increment',
          child: Icon(Icons.add),
        ),
      );
}

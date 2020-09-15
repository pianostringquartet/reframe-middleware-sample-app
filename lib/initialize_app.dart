import 'package:flutter/material.dart';
import 'package:flutter_redux_dev_tools/flutter_redux_dev_tools.dart';
import 'package:flutter_reframe_sample_app/app.dart';
import 'package:flutter_reframe_sample_app/reframe/handler.dart';
import 'package:flutter_reframe_sample_app/reframe/side_effects.dart';
import 'package:flutter_reframe_sample_app/reframe/state.dart';
import 'package:http/http.dart';
import 'package:redux/redux.dart';
import 'package:redux_dev_tools/redux_dev_tools.dart';


Widget devToolsApp({DevToolsStore<AppState> store}) {
  return ReduxDevToolsContainer(
      store: store,
      child: App(
          store,
          (context) {
            return Drawer(
              child: Padding(
                padding: EdgeInsets.only(top: 24.0),
                child: ReduxDevTools(store),
              ),
            );
          }));
}

Widget initializeApp({
  @required Client client,
}) {

  final middleware = [
    /* Although Reframe uses only a single 'middleware',
     we can still add 3rd party, non-Reframe middleware to this list,
     e.g. redux-devtools or redux-persist*/
//    reframeMiddleware(Effects(client: client)),
    reframeMiddleware<AppState, Effects>(Effects(client: client)),
  ];
  final store = Store<AppState>(
      reframeReducer, // does this really pick up the type information?
//      reframeReducer<AppState>,
      initialState: AppState(), middleware: middleware,);


//  return App(store, null);

  final devtoolsStore = DevToolsStore<AppState>(
    reframeReducer,
    initialState: AppState(),
    middleware: middleware,
  );
  return devToolsApp(store: devtoolsStore);
}



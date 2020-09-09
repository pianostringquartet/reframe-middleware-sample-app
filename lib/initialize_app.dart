import 'package:flutter/material.dart';
import 'package:flutter_reframe_sample_app/app.dart';
import 'package:flutter_reframe_sample_app/reframe/handler.dart';
import 'package:flutter_reframe_sample_app/reframe/side_effects.dart';
import 'package:flutter_reframe_sample_app/reframe/state.dart';
import 'package:http/http.dart';
import 'package:redux/redux.dart';

Widget initializeApp({
  @required Client client,
}) {
  final middleware = [
    /* Although Reframe uses only a single 'middleware',
     we can still add 3rd party, non-Reframe middleware to this list,
     e.g. redux-devtools or redux-persist*/
    reframeMiddleware(Effects(client: client)),
  ];
  final store = Store<AppState>(reframeReducer,
      initialState: AppState(), middleware: middleware);
  return App(store);
}

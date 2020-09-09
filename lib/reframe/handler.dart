import 'dart:core';

import 'package:flutter_reframe_sample_app/reframe/side_effects.dart';
import 'package:quiver/core.dart';
import 'package:meta/meta.dart';
import 'package:redux/redux.dart';

import 'package:flutter_reframe_sample_app/reframe/state.dart';
import 'package:flutter_reframe_sample_app/reframe/event.dart';

// A side-effect asynchronously resolves to a list of additional Events.
typedef SideEffect = Future<List<Event>> Function();

// A HandlerResponse is a description of how the app changes due to an event,
// i.e. (1) how the state changes and/or (2) which side-effects to run.
@immutable
class ReframeResponse<S> {
  final Optional<S> state;
  final SideEffect effect;

  const ReframeResponse(
      {this.state = const Optional.absent(), this.effect = noopEffect});

  static Future<List<Event>> noopEffect() async => [];

  static ReframeResponse<S> stateUpdate<S>(S newState) =>
      ReframeResponse<S>(state: Optional.of(newState));

  static ReframeResponse<S> sideEffect<S>(SideEffect sideEffect) =>
      ReframeResponse<S>(effect: sideEffect);

  ReframeResponse<B> map<B>(B Function(S) f) =>
      ReframeResponse<B>(state: state.transform(f), effect: effect);

  @override
  String toString() {
    return 'ReframeResponse{state: $state, effect: $effect}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReframeResponse &&
          runtimeType == other.runtimeType &&
          state == other.state &&
          effect == other.effect;

  @override
  int get hashCode => state.hashCode ^ effect.hashCode;
}

typedef Middleware = void Function(Store<AppState>, dynamic, NextDispatcher);

/* Reframe uses a single middleware,
 which runs the descriptions of state-updates and side-effects
 returned by an event's handler. */
Middleware reframeMiddleware(Effects effects) =>
    (Store store, dynamic event, NextDispatcher next) {
      if (event is Event)
        // Handle the event and run resulting state-update and/or side-effects
        event.handle(store.state, effects)
          // StateUpdate will bring the new-state to the reframe-style reducer
          ..state.ifPresent((newState) => store.dispatch(StateUpdate(newState)))
          ..effect().then((events) => events.forEach(store.dispatch));

      // pass (1) the event to next middleware (e.g. 3rd party middleware)
      // and (2) a StateUpdate to the reducer
      next(event);
    };

/* Reframe uses a single reducer,
 which exchanges the app's old state for the new state.
 Typical Redux reducers (logic for pure state updates) is instead part of
 an Event's handle method. */
AppState reframeReducer(AppState state, dynamic event) =>
    event is StateUpdate ? event.state : state;

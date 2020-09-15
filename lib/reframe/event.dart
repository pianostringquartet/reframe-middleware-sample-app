import 'package:flutter_reframe_sample_app/counter/counter_state.dart';
import 'package:flutter_reframe_sample_app/reframe/side_effects.dart';
import 'package:flutter_reframe_sample_app/reframe/state.dart';
import 'package:meta/meta.dart';

import 'handler.dart';

/* A Redux 'Action' is a Reframe 'Event'.
 Every Event must have a 'handler', where we describe the
 state-change and side-effects produced by the Event.*/
//@immutable
//abstract class Event {
//  const Event();
//
//  ReframeResponse<AppState> handle(AppState state, Effects effects);
//}

@immutable
abstract class Event<S, E> {
  const Event();

  ReframeResponse<S> handle(S state, E effects);
}

// A 'special event' whose only job is to ferry new state to the reframe-reducer.
// (The only redux-action/reframe-event that our reframe-reducer recognizes.)
@immutable
class StateUpdate<S> {
  final S state;

  const StateUpdate(this.state);
}

/* UTILITY AND HELPERS

Often we want to work with some sub-state, rather than the entire application state.
* */
typedef Handler<T, E> = ReframeResponse<T> Function(T, E);

@immutable
abstract class HandlerWrapper<S, T, E> {
  const HandlerWrapper();

  ReframeResponse<S> handlerWrapper(
      S state,
      E effects,
      Handler<T, E> handler,
      );
}

/* EXAMPLE: DEFINING A HANDLER WRAPPER FOR A SPECIFIC SUBSTATE, 'CounterState':

// (1) Define a mixin that implements HandlerWrapper for the specific substate:
// e.g. counter_event.dart:

@immutable
mixin CounterHandlerWrapper implements HandlerWrapper<AppState, CounterState> {
  @override
  ReframeResponse<AppState> handlerWrapper(
    AppState state,
    Handler<CounterState> handler,
  ) =>
      handler(state.counter).map(
          (CounterState counterState) => state.copy(counter: counterState));
}

// (2) Add the mixin to the Event and use the mixin's method:

@immutable
class IncrementEvent extends Event<AppState> with CounterHandlerWrapper {
  @override
  ReframeResponse<AppState> handle(AppState state) =>
      handlerWrapper(
        state,
        effects,
        (CounterState counter) =>
           ReframeResponse.stateUpdate(counter.copy(count: state.count + 1)));
}
/ */
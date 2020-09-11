import 'package:flutter_reframe_sample_app/app.dart';
import 'package:flutter_reframe_sample_app/counter/counter_state.dart';
import 'package:flutter_reframe_sample_app/reframe/event.dart';
import 'package:flutter_reframe_sample_app/reframe/handler.dart';
import 'package:flutter_reframe_sample_app/reframe/side_effects.dart';
import 'package:flutter_reframe_sample_app/reframe/state.dart';
import 'package:http/http.dart';
import 'package:meta/meta.dart';

//typedef CounterHandler = ReframeResponse<CounterState> Function(
//  CounterState,
//  Effects,
//);

/* We often need only a sub-state (e.g. CounterState),
 rather than the full-state (e.g. AppState).


//This mixin handles the transition between CounterState <-> AppState.*/
@immutable
mixin CounterHandlerWrapper implements HandlerWrapper<AppState, CounterState, Effects> {
  @override
  ReframeResponse<AppState> handlerWrapper(
    AppState state,
    Effects effects,
    Handler<CounterState, Effects> handler,
  ) =>
      handler(state.counter, effects).map(
          (CounterState counterState) => state.copy(counter: counterState));
}

// A simple, synchronous action without a payload.
@immutable
class IncrementEvent extends Event<AppState, Effects> with CounterHandlerWrapper {
  @override
  ReframeResponse<AppState> handle(AppState state, Effects effects) =>
      handlerWrapper(state, effects, _handle);

/*  Note: Without mixin and private _handle method, we would have:
    ..., Effects effect) => HandlerResponse.stateUpdate(
     state.copy(counter: state.counter.copy(count: state.counter.count + 1)));*/

  ReframeResponse<CounterState> _handle(CounterState state, Effects effects) =>
      ReframeResponse.stateUpdate(
        state.copy(count: state.count + 1),
      );
}


// A synchronous action with a payload (as an instance variable).
@immutable
class SetCountEvent extends Event<AppState, Effects> with CounterHandlerWrapper {
  final int number;

  const SetCountEvent(this.number);

  @override
  ReframeResponse<AppState> handle(AppState state, Effects effects) =>
      handlerWrapper(
          state,
          effects,
          // Can also define handlers in-line:
          (CounterState counter, Effects effects) =>
              // Here we access the payload:
              ReframeResponse.stateUpdate(counter.copy(count: number)));
}

// An asynchronous action which uses one of our Effects.
@immutable
class AsyncSetCountEvent extends Event<AppState, Effects> {
  @override
  ReframeResponse<AppState> handle(AppState state, Effects effects) {
    final List<Event> onFailure = [IncrementEvent()];

    // A side-effect is an async zero-arity function which resolves to a
    // list of additional actions.
    SideEffect effect = () async {
      try {
        final String url = 'https://jsonplaceholder.typicode.com/posts/1';
        final Response response = await effects.client.get(url);
        return response.statusCode == 200 ? [SetCountEvent(200)] : onFailure;
      } on Exception catch (exception, _) {
        return onFailure;
      }
    };

    return ReframeResponse(effect: effect);
  }
}

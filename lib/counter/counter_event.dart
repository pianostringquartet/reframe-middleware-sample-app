import 'package:flutter_reframe_sample_app/app.dart';
import 'package:flutter_reframe_sample_app/counter/counter_state.dart';
import 'package:flutter_reframe_sample_app/reframe/effects.dart';
import 'package:flutter_reframe_sample_app/reframe/state.dart';
import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:reframe_middleware/reframe_middleware.dart';

typedef CounterHandler = ReframeResponse<CounterState> Function(
  CounterState,
  Effects,
);

/* We often need only a sub-state (e.g. CounterState),
 rather than the full-state (e.g. AppState).

 This mixin handles the transition between CounterState <-> AppState.*/
mixin HandlerWrapper {
  ReframeResponse<AppState> handleCounterAction(
    AppState state,
    Effects effects,
    CounterHandler counterHandler,
  ) =>
      counterHandler(state.counter, effects).map(
          (CounterState counterState) => state.copy(counter: counterState));
}

// A simple, synchronous action without a payload.
@immutable
class IncrementAction extends ReframeAction<AppState, Effects>
    with HandlerWrapper {
  @override
  ReframeResponse<AppState> handle(AppState state, Effects effects) =>
      handleCounterAction(state, effects, _handle);

/*  Note: Without mixin and private handle method, we would have:
    ..., Effects effect) => HandlerResponse.stateUpdate(
     state.copy(counter: state.counter.copy(count: state.counter.count + 1)));*/

  ReframeResponse<CounterState> _handle(CounterState state, Effects effects) =>
      ReframeResponse.stateUpdate(
        state.copy(count: state.count + 1),
      );
}

// A synchronous action with a payload (as an instance variable).
@immutable
class SetCountAction extends ReframeAction<AppState, Effects>
    with HandlerWrapper {
  final int number;

  const SetCountAction(this.number);

  @override
  ReframeResponse<AppState> handle(AppState state, Effects effects) =>
      handleCounterAction(
          state,
          effects,
          // Can also define handlers in-line like this:
          (CounterState counter, Effects effects) =>
              // Here we access the payload:
              ReframeResponse.stateUpdate(counter.copy(count: number)));
}

// An asynchronous action which uses one of our Effects.
@immutable
class AsyncSetCountAction extends ReframeAction<AppState, Effects> {
  @override
  ReframeResponse<AppState> handle(AppState state, Effects effects) {
    final List<ReframeAction> onFailure = [IncrementAction()];

    // A side-effect is an async zero-arity function which resolves to a
    // list of additional actions.
    SideEffect effect = () async {
      try {
        final String url = 'https://jsonplaceholder.typicode.com/posts/1';
        final Response response = await effects.client.get(url);
        return response.statusCode == 200 ? [SetCountAction(200)] : onFailure;
      } on Exception catch (exception, _) {
        return onFailure;
      }
    };

    return ReframeResponse(effect: effect);
  }
}

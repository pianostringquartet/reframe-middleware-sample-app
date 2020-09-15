# Flutter Re-frame

# Reframe-middleware Flutter demo

A small Flutter app showing how to use [reframe-middleware](https://github.com/pianostringquartet/reframe-middleware) for redux.dart.

# State structure
```dart
// reframe/state.dart
@immutable
class AppState {
  final CounterState counter;

  const AppState({
    this.counter = const CounterState(),
  });
}
```

# Actions and their action handlers
### Action without a payload

See below for the of `with HandlerWrapper`, a mixin to more easily work with nested state. 

```dart
@immutable
class IncrementAction extends ReframeAction<AppState, Effects> with HandlerWrapper {
  @override
  ReframeResponse<AppState> handle(AppState state, Effects effects) =>
      handleCounterAction(state, effects, _handle);

  ReframeResponse<CounterState> _handle(CounterState state, Effects effects) =>
      ReframeResponse.stateUpdate(
        state.copy(count: state.count + 1),
      );
}
```

### Action with a payload 

```dart
@immutable
class SetCountAction extends ReframeAction<AppState, Effects> with HandlerWrapper {
  final int number;

  const SetCountAction(this.number);

  @override
  ReframeResponse<AppState> handle(AppState state, Effects effects) =>
      handleCounterAction(
          state,
          effects,
          // Can also define handlers in-line like this:
          (CounterState counter, Effects effects) => 
				ReframeResponse.stateUpdate(counter.copy(count: number)));
}
```


### Async Action

```dart
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
```


# Helper for nested state updates: HandlerWrapper mixin
### Defining a HandlerWrapper to wrap a particular part of your state

Dart doesn’t have lenses for type-design nested access, so we need to get more creative ;-)

```dart
// define a type signature for sub-state handlers
typedef CounterHandler = ReframeResponse<CounterState> Function(
  CounterState,
  Effects,
);

// define a mixin that knows how to traverse from substate to AppState (fullstate)
mixin HandlerWrapper {
  ReframeResponse<AppState> handleCounterAction(
    AppState state,
    Effects effects,
    CounterHandler counterHandler,
  ) =>
      counterHandler(state.counter, effects).map(
          (CounterState counterState) => state.copy(counter: counterState));
}
```


### Using HandlerWrapper

```dart
@immutable
class IncrementAction2 extends ReframeAction<AppState, Effects>
    with HandlerWrapper {
  @override
  ReframeResponse<AppState> handle(AppState state, Effects effects) =>
      handleCounterAction(
        state,
        effects,
        (CounterState state, Effects effects) =>
            ReframeResponse.stateUpdate(state.copy(count: state.count + 1)),
      );
}
```

This same action + action handler without HandlerWrapper:

```dart
@immutable
class IncrementAction extends ReframeAction<AppState, Effects> with HandlerWrapper {
  @override
  ReframeResponse<AppState> handle(AppState state, Effects effects) =>
      ReframeResponse.stateUpdate(
          state.copy(counter: state.counter.copy(count: state.counter.count + 1)));
}
```

HandlerWrappers become more useful as state becomes more nested. 

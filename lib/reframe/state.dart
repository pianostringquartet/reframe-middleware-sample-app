import 'package:flutter_reframe_sample_app/counter/counter_state.dart';
import 'package:meta/meta.dart';

@immutable
class AppState {
  final CounterState counter;

  const AppState({
    this.counter = const CounterState(),
  });

  AppState copy({
    CounterState counter,
  }) =>
      AppState(
        counter: counter ?? this.counter,
      );

  @override
  String toString() {
    return 'AppState{counter: $counter}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppState &&
          runtimeType == other.runtimeType &&
          counter == other.counter;

  @override
  int get hashCode => counter.hashCode;
}

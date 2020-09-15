import 'package:meta/meta.dart';

@immutable
class CounterState {
  final int count;

  const CounterState({this.count = 0});

  CounterState copy({int count}) => CounterState(count: count ?? this.count);

  @override
  String toString() {
    return 'CounterState{count: $count}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CounterState &&
          runtimeType == other.runtimeType &&
          count == other.count;

  @override
  int get hashCode => count.hashCode;
}

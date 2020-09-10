import 'package:flutter_reframe_sample_app/reframe/side_effects.dart';
import 'package:flutter_reframe_sample_app/reframe/state.dart';
import 'package:meta/meta.dart';

import 'handler.dart';

/* A Redux 'Action' is a Reframe 'Event'.
 Every Event must have a 'handler', where we describe the
 state-change and side-effects produced by the Event.*/
@immutable
abstract class Event {
  const Event();

  ReframeResponse<AppState> handle(AppState state, Effects effects);
}

// A 'special event' whose only job is to ferry new state to the reframe-reducer.
// (The only redux-action/reframe-event that our reframe-reducer recognizes.)
@immutable
class StateUpdate<S> {
  final S state;

  const StateUpdate(this.state);
}

import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs.dart';

class AnimateEntranceBloc
    extends Bloc<AnimateEntranceEvent, AnimateEntranceState> {
  AnimateEntranceBloc() : super(const AnimateEntranceState.unknown());
  @override
  Stream<AnimateEntranceState> mapEventToState(
      AnimateEntranceEvent event) async* {
    if (event is SignalEndAnimation) {
      yield AnimateEntranceState.stopping();
    }
    if (event is EnteringPage) {
      yield AnimateEntranceState.starting();
    }
    if (event is LeavingPage) {
      yield AnimateEntranceState.reversing();
    }
  }

  @override
  void onChange(Change<AnimateEntranceState> change) {
    print(change);
    super.onChange(change);
  }

  @override
  void onEvent(AnimateEntranceEvent event) {
    print(event);
    super.onEvent(event);
  }

  @override
  void onTransition(
      Transition<AnimateEntranceEvent, AnimateEntranceState> transition) {
    print(transition);
    super.onTransition(transition);
  }
}

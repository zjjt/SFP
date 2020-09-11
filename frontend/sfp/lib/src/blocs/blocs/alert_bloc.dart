import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sfp/src/blocs/state/state.dart';

import '../blocs.dart';

class AlertBloc extends Bloc<AlertEvent, AlertState> {
  AlertBloc() : super(const AlertState.closed());
  @override
  Stream<AlertState> mapEventToState(AlertEvent event) async* {
    if (event is ShowAlert) {
      var widget = event.whatToShow;
      yield AlertState.opened(
          widget, event.title, event.actions, event.alignement);
    }
    if (event is CloseAlert) {
      yield AlertState.closed();
    }
  }
}

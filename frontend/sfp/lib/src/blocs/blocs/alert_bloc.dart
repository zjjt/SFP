import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sfp/src/blocs/state/state.dart';
import 'package:sfp/utils.dart';

import '../blocs.dart';

class AlertBloc extends Bloc<AlertEvent, AlertState> {
  AlertBloc() : super(const AlertState.closed());
  @override
  Stream<AlertState> mapEventToState(AlertEvent event) async* {
    if (event is ShowAlert) {
      var currentWidget = event.whatToShow;
      Utils.log(currentWidget);
      yield AlertState.opened(currentWidget, event.isDoc, event.doc,
          event.title, event.actions, event.alignement);
    }
    if (event is CloseAlert) {
      yield AlertState.closed();
    }
  }
}

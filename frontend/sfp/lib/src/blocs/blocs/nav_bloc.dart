import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sfp/src/blocs/state/state.dart';

import '../blocs.dart';

class NavBloc extends Bloc<NavEvent, NavState> {
  NavBloc() : super(LoginState());
  @override
  Stream<NavState> mapEventToState(NavEvent event) async* {
    if (event is GoLogin) {
      yield LoginState();
    } else if (event is GoAdmin) {
      yield AdminState();
    } else if (event is GoConfig) {
      yield SelectConfigState();
    } else if (event is GoFupload) {
      yield FuploadState();
    } else if (event is GoResult) {
      yield ResultState();
    } else if (event is GoTo) {
      yield WhereTo(event.where);
    } else if (event is GoValidate) {
      yield ValidationState();
    }
  }

  @override
  void onChange(Change<NavState> change) {
    print(change);
    super.onChange(change);
  }

  @override
  void onEvent(NavEvent event) {
    print(event);
    super.onEvent(event);
  }

  @override
  void onTransition(Transition<NavEvent, NavState> transition) {
    print(transition);
    super.onTransition(transition);
  }
}

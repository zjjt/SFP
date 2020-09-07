import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sfp/src/models/user_model.dart';
import 'package:sfp/src/resources/repository.dart';

import '../blocs.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Repository repo;
  UserModel user;
  AuthBloc(this.repo) : super(const AuthState.unknown());

  @override
  Stream<AuthState> mapEventToState(AuthEvent event) async* {
    if (event is LoggingIn) {
      print(
          'trying to login with username:${event.username} and ${event.password}');
      yield AuthState.loading();
      try {
        final result = await repo.fetchUsers(event.username, event.password);
        //we check if we have some errors return from the api
        if (!result['errors']) {
          user = UserModel.fromJSON(result['users'][0]);
          yield AuthState.authenticated(user);
        } else {
          yield AuthState.unauthenticated(errorMsg: result['message']);
        }
      } on NetWorkException {}
    }
    //if(event is )
  }

  @override
  void onEvent(AuthEvent event) {
    print(event);
    super.onEvent(event);
  }

  @override
  void onChange(Change<AuthState> change) {
    print(change);
    super.onChange(change);
  }

  @override
  void onTransition(Transition<AuthEvent, AuthState> transition) {
    print(transition);
    super.onTransition(transition);
  }
}
